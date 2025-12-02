import 'dart:async';
import 'dart:convert';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/pages/managers/install/smart_config_page.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoCard extends StatefulWidget {
  const InfoCard({super.key});

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  static const _historyKey = 'info_history_v1';
  static const _dismissedKey = 'dismissed_messages';
  static const _maxHistory = 20;
  bool _listenerAttached = false;
  StreamSubscription? _connSub;

  final List<_InfoMsg> _messages = [];
  final List<_InfoMsg> _localMessages = [];
  _InfoMsg? _currentGlobalMessage;

  int _currentIndex = 0;
  Timer? _timer;
  Set<String> _dismissedIds = {};

  MqttController? _mqtt;
  late final void Function(String topic, String message) _mqttListener;

  @override
  void initState() {
    super.initState();
    _mqtt =
        Get.isRegistered<MqttController>() ? Get.find<MqttController>() : null;

    _mqttListener = (topic, message) {
      if (!topic.startsWith('akilliAnahtar/announce/global')) return;

      final trimmed = message.trim();
      if (trimmed.isEmpty || trimmed == 'null') {
        _currentGlobalMessage = null;
        _rebuildMessageList();
        return;
      }

      try {
        final map = jsonDecode(trimmed);
        final m = _InfoMsg.fromMqtt(map, topic: topic);
        if (m.isExpired) return;

        _currentGlobalMessage = m;
        _rebuildMessageList();
      } catch (_) {}
    };

    if (_mqtt?.isConnected.value == true) {
      _attachListenerAndSubscribe();
    }
    _connSub = _mqtt?.isConnected.listen((v) {
      if (v == true) _attachListenerAndSubscribe();
    });

    if (_mqtt?.isConnected.value == true) {
      _subscribeGlobal();
    }
    _connSub = _mqtt?.isConnected.listen((v) {
      if (v == true) _subscribeGlobal();
    });

    _loadAll();
  }

  void _attachListenerAndSubscribe() {
    if (_mqtt == null || _listenerAttached) return;
    _mqtt!.onMessage(_mqttListener);
    _listenerAttached = true;

    try {
      _mqtt!.client
          .subscribe('akilliAnahtar/announce/global', MqttQos.atLeastOnce);
    } catch (_) {}
  }

  void _subscribeGlobal() {
    try {
      _mqtt?.client
          .subscribe('akilliAnahtar/announce/global', MqttQos.atLeastOnce);
    } catch (_) {}
  }

  Future<void> _loadAll() async {
    await _loadDismissedMessages();
    await _loadLocalChecks();
    await _loadHistory();
    _rebuildMessageList();
  }

  Future<void> _loadDismissedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedList = prefs.getStringList(_dismissedKey) ?? [];
    _dismissedIds = dismissedList.toSet();
  }

  Future<void> _saveDismissedMessage(String id) async {
    _dismissedIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedKey, _dismissedIds.toList());
  }

  Future<void> _loadLocalChecks() async {
    final auth = Get.find<AuthController>();
    final emailVerified = auth.user.value.emailVerified == 1;
    final hasPendingWiFi = await LocalDb.get("pendingWiFiChipId") != null;

    _localMessages.clear();

    if (!emailVerified && !_dismissedIds.contains('local-email-verify')) {
      _localMessages.add(_InfoMsg.local(
        id: 'local-email-verify',
        type: 'warning',
        title: 'E-posta doğrulaması gerekli',
        body: 'E-posta adresiniz doğrulanmamış. Lütfen doğrulayın.',
      ));
    }
    if (hasPendingWiFi && !_dismissedIds.contains('local-pending-wifi')) {
      _localMessages.add(_InfoMsg.local(
        id: 'local-pending-wifi',
        type: 'info',
        title: 'Wi-Fi kurulumu bekliyor',
        body: 'Cihaz eklendi ancak Wi-Fi kurulumu tamamlanmadı.',
      ));
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);

    // Sadece MQTT geçmişini yükle, ama şu an için kullanmıyoruz
    // Gerekirse daha sonra ekleyebilirsin
  }

  void _rebuildMessageList() {
    _messages.clear();

    _messages.addAll(_localMessages);
    if (_currentGlobalMessage != null &&
        !_dismissedIds.contains(_currentGlobalMessage!.id)) {
      _messages.add(_currentGlobalMessage!);
    }

    _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_messages.length >= 2) {
      _startRotation();
    } else {
      _timer?.cancel();
    }

    if (mounted) setState(() {});
  }

  void _startRotation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _messages.length < 2) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _messages.length;
      });
    });
  }

  void _closeCurrent() async {
    if (_messages.isEmpty) return;

    final currentMsg = _messages[_currentIndex];

    await _saveDismissedMessage(currentMsg.id);
    if (currentMsg.id == _currentGlobalMessage?.id) {
      _currentGlobalMessage = null;
    }

    _localMessages.removeWhere((m) => m.id == currentMsg.id);

    _rebuildMessageList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _InfoMsg? m = _messages.isNotEmpty ? _messages[_currentIndex] : null;

    final theme = Theme.of(context);
    Color color = theme.colorScheme.primary;
    switch (m?.type) {
      case 'danger':
      case 'warning':
        color = theme.colorScheme.error;
        break;
      case 'success':
        color = theme.colorScheme.primary;
        break;
      case 'info':
      default:
        color = theme.colorScheme.primary;
    }

    String? buttonText;
    VoidCallback? onPressed;
    if (m?.id == 'local-email-verify') {
      buttonText = "Şimdi Doğrula";
      onPressed = () {
        final user = Get.find<AuthController>().user.value;
        Get.toNamed("/sendMail", arguments: user.mail);
      };
    } else if (m?.id == 'local-pending-wifi') {
      buttonText = "Wi-Fi Kurulumu";
      onPressed = () => Get.to(() => const SmartConfigPage());
    }

    final text = m == null
        ? null
        : (m.title?.isNotEmpty == true ? '${m.title}: ${m.body}' : m.body);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _AppLogo(color: color),
          const SizedBox(width: 8),
          if (text != null)
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
          if (text != null && buttonText != null)
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: color,
              ),
              onPressed: onPressed,
              child: Text(buttonText, style: const TextStyle(fontSize: 12)),
            ),
          if (text != null)
            IconButton(
              icon: Icon(Icons.close_rounded,
                  size: 16, color: color.withOpacity(0.7)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: _closeCurrent,
            ),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  final Color color;
  const _AppLogo({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: Image.asset(
        'assets/owl2.webp',
        errorBuilder: (_, __, ___) =>
            Icon(Icons.auto_awesome, size: 20, color: color),
      ),
    );
  }
}

enum _MsgSource { local, mqtt }

class _InfoMsg {
  final String id;
  final String type; // info|success|warning|danger
  final String? title;
  final String body;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int rev;
  final _MsgSource source;
  final String? topic;

  _InfoMsg({
    required this.id,
    required this.type,
    this.title,
    required this.body,
    required this.createdAt,
    this.expiresAt,
    this.rev = 1,
    required this.source,
    this.topic,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().toUtc().isAfter(expiresAt!);

  factory _InfoMsg.local({
    required String id,
    required String type,
    String? title,
    required String body,
  }) {
    return _InfoMsg(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now().toUtc(),
      expiresAt: null,
      rev: 1,
      source: _MsgSource.local,
      topic: null,
    );
  }

  factory _InfoMsg.fromMqtt(Map<String, dynamic> m, {required String topic}) {
    final created = DateTime.tryParse('${m['createdAt'] ?? ''}')?.toUtc() ??
        DateTime.now().toUtc();
    final exp = m['expiresAt'] != null
        ? DateTime.tryParse('${m['expiresAt']}')?.toUtc()
        : null;

    return _InfoMsg(
      id: '${m['id'] ?? 'ann-${created.millisecondsSinceEpoch}'}',
      type: '${m['type'] ?? 'info'}',
      title: (m['title'] as String?)?.trim(),
      body: '${m['body'] ?? ''}'.trim(),
      createdAt: created,
      expiresAt: exp,
      rev: int.tryParse('${m['rev'] ?? 1}') ?? 1,
      source: _MsgSource.mqtt,
      topic: topic,
    );
  }

  Map<String, dynamic> toStorage() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'rev': rev,
        'source': 'mqtt',
        'topic': topic,
      };

  factory _InfoMsg.fromStorage(Map<String, dynamic> m) {
    return _InfoMsg(
      id: '${m['id']}',
      type: '${m['type']}',
      title: m['title'] as String?,
      body: '${m['body']}',
      createdAt: DateTime.tryParse('${m['createdAt']}')?.toUtc() ??
          DateTime.now().toUtc(),
      expiresAt: m['expiresAt'] != null
          ? DateTime.tryParse('${m['expiresAt']}')?.toUtc()
          : null,
      rev: int.tryParse('${m['rev'] ?? 1}') ?? 1,
      source: _MsgSource.mqtt,
      topic: m['topic'] as String?,
    );
  }
}
