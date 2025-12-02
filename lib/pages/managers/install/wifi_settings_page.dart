import 'dart:async';
import 'dart:convert';
import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:akilli_anahtar/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WifiMqttFormPage extends StatefulWidget {
  const WifiMqttFormPage({super.key});

  @override
  State<WifiMqttFormPage> createState() => _WifiMqttFormPageState();
}

class _WifiMqttFormPageState extends State<WifiMqttFormPage> {
  late final MqttController mqtt;
  late final HomeController home;
  late final BoxManagementController bmc;

  final _formKey = GlobalKey<FormState>();
  final _mSsid = TextEditingController();
  final _mPass = TextEditingController();
  final _bSsid = TextEditingController();
  final _bPass = TextEditingController();

  final selectedBox = Rx<_BoxItem?>(null);
  final boxes = <_BoxItem>[].obs;
  final status = RxString("");
  final wifiStatus = Rx<Map<String, dynamic>?>(null);
  final isLoading = RxBool(false);

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    mqtt = Get.find<MqttController>();
    home = Get.find<HomeController>();
    bmc = Get.find<BoxManagementController>();
    _initialize();
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    try {
      if (!mqtt.isConnected.value && !mqtt.connecting.value) {
        await mqtt.initClient();
      }

      if (bmc.boxes.isEmpty) {
        await bmc.getBoxes();
      }

      await _loadBoxes();

      mqtt.onMessage((topic, message) {
        final sel = selectedBox.value;
        if (sel == null || topic != sel.res) return;

        if (message == "wifi_saved" || message == "pair_saved") {
          status.value = "Kaydedildi. Cihaz ağ bağlantısını yeniliyor.";
          return;
        }
        if (message.startsWith("wifi_error:") ||
            message.startsWith("pair_error:")) {
          status.value = "Hata: $message";
          return;
        }

        try {
          final j = jsonDecode(message);
          if (j is Map && j.containsKey("connected")) {
            wifiStatus.value = Map<String, dynamic>.from(j);
            status.value = "Durum alındı.";
          }
        } catch (_) {/* JSON değilse geç */}
      });
    } catch (e) {
      status.value = "Hata: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBoxes() async {
    final uniq = <String, _BoxItem>{};

    for (final bx in bmc.boxes) {
      if (bx.topicRec.isNotEmpty && bx.topicRes.isNotEmpty) {
        uniq['${bx.id}|${bx.topicRec}|${bx.topicRes}'] = _BoxItem(
          id: bx.id.toString(),
          name: bx.name.isNotEmpty ? bx.name : 'Kutu',
          rec: bx.topicRec,
          res: bx.topicRes,
        );
      }
    }

    if (bmc.boxList.isEmpty) {
      await bmc.getBoxList();
    }
    for (final dto in bmc.boxList) {
      final rec = (dto.topicRec ?? '');
      final res = (dto.topicRes ?? '');
      if (rec.isEmpty || res.isEmpty) continue;
      uniq['${dto.id}|$rec|$res'] = _BoxItem(
        id: (dto.id ?? 0).toString(),
        name: dto.name ?? 'Kutu',
        rec: rec,
        res: res,
      );
    }

    if (uniq.isEmpty && home.homeDevices.isEmpty) {
      await home.getDevices();
    }

    boxes.assignAll(uniq.values);
  }

  void _selectBox(_BoxItem box) {
    selectedBox.value = box;
    wifiStatus.value = null;
    status.value = "";
    mqtt.subscribeToTopic(box.res);
  }

  void _saveWifiSettings() {
    if (selectedBox.value == null) return;

    final mSsid = _mSsid.text.trim();
    final mPass = _mPass.text;
    final bSsid = _bSsid.text.trim();
    final bPass = _bPass.text;

    if (mSsid.isEmpty && bSsid.isEmpty) {
      errorSnackbar("Eksik bilgi",
          "En az bir Wi‑Fi ağı (Master veya Yedek) doldurulmalı.");
      return;
    }

    if (mSsid.isNotEmpty && mPass.isEmpty) {
      errorSnackbar("Eksik bilgi", "Master için şifre gerekli.");
      return;
    }
    if (bSsid.isNotEmpty && bPass.isEmpty) {
      errorSnackbar("Eksik bilgi", "Yedek için şifre gerekli.");
      return;
    }

    final wifiConfig = <String, dynamic>{};
    if (mSsid.isNotEmpty) {
      wifiConfig["master"] = {"ssid": mSsid, "pass": mPass};
    }
    if (bSsid.isNotEmpty) {
      wifiConfig["backup"] = {"ssid": bSsid, "pass": bPass};
    }

    final body = {"wifi": wifiConfig, "mode": 1};
    final message = jsonEncode(body);

    mqtt.publishMessage(selectedBox.value!.rec, message);
    status.value = "Wi‑Fi bilgileri gönderildi...";
  }

  void _requestStatus() {
    final sel = selectedBox.value;
    if (sel == null) return;
    wifiStatus.value = null;
    status.value = "Durum isteniyor...";
    mqtt.publishMessage(sel.rec, "wifistatus");
  }

  void _openStatusSheet() {
    final sel = selectedBox.value;
    if (sel == null) return;

    final sheetData = Rx<Map<String, dynamic>?>(null);

    ever(wifiStatus, (data) {
      sheetData.value = data as Map<String, dynamic>?;
    });

    wifiStatus.value = null;
    status.value = "Durum isteniyor...";
    mqtt.publishMessage(sel.rec, "wifistatus");

    Get.bottomSheet(
      Obx(() {
        final d = sheetData.value;
        return _WifiStatusSheet(
          data: d,
          onRefresh: () {
            wifiStatus.value = null;
            mqtt.publishMessage(sel.rec, "wifistatus");
          },
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
    );
  }

  void _sendWifiReset() async {
    final sel = selectedBox.value;
    if (sel == null) {
      Get.snackbar("Uyarı", "Önce bir kutu seçin.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Wi-Fi Sıfırlama"),
        content: const Text(
            "Cihazın Wi-Fi ayarları sıfırlanacak ve yeniden başlayabilir.\nDevam edilsin mi?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Vazgeç")),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: goldColor, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Evet, sıfırla"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    mqtt.publishMessage(sel.rec, "wifireset");
    status.value = "Wi-Fi sıfırlama komutu gönderildi...";
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _mSsid.dispose();
    _mPass.dispose();
    _bSsid.dispose();
    _bPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wi-Fi Ayarları"),
        backgroundColor: sheetBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Wi-Fi Sıfırla",
            onPressed: _sendWifiReset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() => AppDropdownField(
                  value: selectedBox.value,
                  label: "Kutu Seçin",
                  icon: Icons.check_box_outline_blank,
                  items: boxes
                      .map((b) => DropdownMenuItem(
                          value: b, child: Text("${b.name} (${b.id})")))
                      .toList(),
                  onChanged: (b) => b != null ? _selectBox(b) : null,
                  validator: (v) => v == null ? "Lütfen bir kutu seçin" : null,
                )),
            const SizedBox(height: 8),
            Obx(() {
              final sel = selectedBox.value;
              if (sel == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("REC: ${sel.rec}\nRES: ${sel.res}",
                  //     style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  // const SizedBox(height: 8),
                  if (status.value.isNotEmpty)
                    Text(
                      status.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: status.value.contains("Hata")
                            ? Colors.red
                            : goldColor,
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 10),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildNetworkFormSection(
                      title: "ANA Wi-Fi",
                      ssidController: _mSsid,
                      passController: _mPass,
                      isRequired: false,
                    ),
                    const SizedBox(height: 10),
                    _buildNetworkFormSection(
                      title: "YEDEK Wi-Fi (Opsiyonel)",
                      ssidController: _bSsid,
                      passController: _bPass,
                      isRequired: false,
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final isConnected = mqtt.isConnected.value;
                      final hasSelectedBox = selectedBox.value != null;

                      return Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.save, size: 20),
                              label: const Text("Kaydet"),
                              onPressed: (isConnected &&
                                      hasSelectedBox &&
                                      !isLoading.value)
                                  ? () => _saveWifiSettings()
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green),
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text("Durum"),
                            onPressed: (isConnected &&
                                    hasSelectedBox &&
                                    !isLoading.value)
                                ? _openStatusSheet
                                : null,
                          ),
                        ],
                      );
                    }),
                    // const SizedBox(height: 16),
                    // Obx(() {
                    //   final data = wifiStatus.value;
                    //   if (data == null) return const SizedBox.shrink();
                    //   return _WifiStatusCard(data: data);
                    // }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkFormSection({
    required String title,
    required TextEditingController ssidController,
    required TextEditingController passController,
    required bool isRequired,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            AppInputField(
              controller: ssidController,
              icon: Icons.wifi,
              label: "SSID",
              validator: isRequired
                  ? (v) => (v == null || v.trim().isEmpty) ? "Gerekli" : null
                  : null,
              inputAction: TextInputAction.next,
            ),
            AppInputField(
              controller: passController,
              icon: Icons.lock,
              label: "Şifre",
              validator: isRequired
                  ? (v) => (v == null || v.trim().isEmpty) ? "Gerekli" : null
                  : null,
              inputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
    );
  }
}

class _BoxItem {
  final String id;
  final String name;
  final String rec;
  final String res;
  _BoxItem(
      {required this.id,
      required this.name,
      required this.rec,
      required this.res});
  @override
  String toString() => '$name ($id)';
}

// class _WifiStatusCard extends StatelessWidget {
//   final Map<String, dynamic> data;
//   const _WifiStatusCard({required this.data});
//   @override
//   Widget build(BuildContext context) {
//     final targets = (data["targets"] ?? {}) as Map<String, dynamic>;
//     final isConnected = data["connected"] == true;
//     return Card(
//       elevation: 3,
//       color: isConnected ? Colors.green[50] : Colors.orange[50],
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Icon(isConnected ? Icons.wifi : Icons.wifi_off,
//                 color: isConnected ? Colors.green : Colors.orange),
//             const SizedBox(width: 8),
//             Text("Durum: ${isConnected ? "Bağlı" : "Bağlı Değil"}",
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isConnected ? Colors.green : Colors.orange)),
//           ]),
//           const SizedBox(height: 8),
//           _row("Ağ Tipi:", data["type"]?.toString() ?? "-"),
//           _row("SSID:", data["ssid"]?.toString() ?? "-"),
//           _row("IP Adresi:", data["ip"]?.toString() ?? "-"),
//           _row("İnternet:", (data["internet_ok"] == true) ? "Var" : "Yok"),
//           const Divider(),
//           _row("Master Ağ:", targets["master"]?.toString() ?? "-"),
//           _row("Yedek Ağ:", targets["backup"]?.toString() ?? "-"),
//           _row("Varsayılan:", targets["default"]?.toString() ?? "-"),
//           const Divider(),
//           _row("Versiyon:", data["ver"]?.toString() ?? "-"),
//         ]),
//       ),
//     );
//   }

//   Widget _row(String l, String v) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4),
//         child: Row(children: [
//           SizedBox(
//               width: 100,
//               child:
//                   Text(l, style: const TextStyle(fontWeight: FontWeight.bold))),
//           const SizedBox(width: 8),
//           Expanded(child: Text(v)),
//         ]),
//       );
// }

class _WifiStatusSheet extends StatelessWidget {
  final Map<String, dynamic>? data;
  final VoidCallback onRefresh;
  const _WifiStatusSheet({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minHeight: 200,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(99)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Wi‑Fi Durumu",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    tooltip: "Yenile",
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: "Kapat",
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: data == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: _WifiStatusCardCompact(data: data!),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WifiStatusCardCompact extends StatefulWidget {
  final Map<String, dynamic> data;
  const _WifiStatusCardCompact({required this.data});

  @override
  State<_WifiStatusCardCompact> createState() => _WifiStatusCardCompactState();
}

class _WifiStatusCardCompactState extends State<_WifiStatusCardCompact> {
  bool showMaster = false;
  bool showBackup = false;
  bool showDefault = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isConnected = d["connected"] == true;
    final targets = (d["targets"] ?? {}) as Map<String, dynamic>;

    final master = _extractNet(targets["master"]);
    final backup = _extractNet(targets["backup"]);
    final defNet = _extractNet(targets["default"], targets["defaultPass"]);

    return Card(
      elevation: 2,
      color: isConnected ? Colors.green[50] : Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Icon(isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Text(isConnected ? "Bağlı" : "Bağlı değil",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isConnected ? Colors.green : Colors.orange,
                  )),
              const Spacer(),
              if (d["ver"] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.05),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text("v${d["ver"]}",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _row("Tip", d["type"]?.toString() ?? "-"),
          _row("SSID", d["ssid"]?.toString() ?? "-"),
          _row("IP", d["ip"]?.toString() ?? "-"),
          _row("Net", (d["internet_ok"] == true) ? "Var" : "Yok"),
          const Divider(height: 18),
          _row("Master SSID", master.ssid ?? "-"),
          const SizedBox(height: 8),
          _row("Yedek SSID", backup.ssid ?? "-"),
          if (defNet.ssid != null || defNet.pass != null) ...[
            const Divider(height: 18),
            _row("Varsayılan SSID", defNet.ssid ?? "-"),
            _secretRow("Varsayılan Şifre", defNet.pass, showDefault, () {
              setState(() => showDefault = !showDefault);
            }),
          ],
        ]),
      ),
    );
  }

  _Net _extractNet(dynamic target, [dynamic flatPass]) {
    String? ssid;
    String? pass;

    if (target is Map) {
      ssid = (target["ssid"] ?? target["name"] ?? target["target"])?.toString();
      pass = (target["pass"] ?? target["password"])?.toString();
    } else if (target is String) {
      ssid = target;
    }

    pass ??= flatPass?.toString();

    return _Net(ssid: ssid, pass: pass);
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 96,
                child: Text(l,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Expanded(child: Text(v)),
          ],
        ),
      );

  Widget _secretRow(
      String l, String? value, bool visible, VoidCallback onToggle) {
    final masked = (value ?? "").isEmpty ? "-" : (visible ? value! : "•" * 8);
    return Row(
      children: [
        SizedBox(
            width: 96,
            child:
                Text(l, style: const TextStyle(fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Expanded(child: Text(masked)),
        IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
          tooltip: visible ? "Gizle" : "Göster",
        ),
      ],
    );
  }
}

class _Net {
  final String? ssid;
  final String? pass;
  _Net({this.ssid, this.pass});
}
