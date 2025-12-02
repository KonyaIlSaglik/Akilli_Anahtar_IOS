import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlanAddEditPage extends StatefulWidget {
  final HomeDeviceDto device;
  const PlanAddEditPage({super.key, required this.device});

  @override
  State<PlanAddEditPage> createState() => _PlanAddEditPageState();
}

class _PlanAddEditPageState extends State<PlanAddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _mqtt = Get.find<MqttController>();

  String _type = 'fixed';
  List<String> _selectedDays = ['Her gun'];
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  int _trigger = 0;
  int _duration = 10;
  bool _enabled = true;

  static const List<String> _days = [
    'Her gun',
    'Pazartesi',
    'Sali',
    'Carsamba',
    'Persembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  List<String> _normalizedDays() {
    return _selectedDays.contains('Her gun')
        ? ['*']
        : List<String>.from(_selectedDays);
  }

  Future<void> _pickDays() async {
    final current = Set<String>.from(_selectedDays);
    final all = List<String>.from(_days);

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            void toggle(String d, bool value) {
              setSt(() {
                if (d == 'Her gun') {
                  if (value) {
                    current
                      ..clear()
                      ..add('Her gun');
                  } else {
                    current.remove('Her gun');
                    if (current.isEmpty) current.add('Her gun');
                  }
                } else {
                  if (value) {
                    current.add(d);
                    current.remove('Her gun');
                  } else {
                    current.remove(d);
                    if (current.isEmpty) current.add('Her gun');
                  }
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text("Gün Seç",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...all.map((d) => CheckboxListTile(
                        value: current.contains(d),
                        onChanged: (v) => toggle(d, v ?? false),
                        title: Text(d == 'Her gun' ? 'Her gün (tümü)' : d),
                      )),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedDays = current.toList());
                      Navigator.pop(ctx);
                    },
                    child: const Text("Tamam"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _daysSummary() {
    if (_selectedDays.contains('Her gun')) return 'Her gün';
    if (_selectedDays.length <= 3) return _selectedDays.join(', ');
    return '${_selectedDays.length} gün seçildi';
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(context: context, initialTime: _time);
    if (res != null) setState(() => _time = res);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final plan = {
      "enabled": _enabled,
      "days": _normalizedDays(),
      if (_type == 'fixed')
        "time":
            "${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}"
      else ...{
        "type": _type,
        "trigger": _trigger,
      },
      "duration": _duration * 60,
    };

    final payload = {
      "command": "set_schedule",
      "device": {
        "device_id": widget.device.id,
      },
      "schedule": [plan]
    };

    final topic = widget.device.topicRec;
    if (topic == null || topic.isEmpty) {
      errorSnackbar("Hata", "Cihazın topicRec bilgisi bulunamadı.");
      return;
    }

    try {
      await _publishPlanJson(topic, payload, false);
      Get.back();
      successSnackbar("Plan", "Plan kaydedildi ve cihaza gönderildi.");
    } catch (e) {
      errorSnackbar("Hata", "Plan gönderilemedi: $e");
    }
  }

  Future<void> _publishPlanJson(
      String topic, Map<String, dynamic> body, bool retain) async {
    final jsonStr = jsonEncode(body);
    _mqtt.publishMessage(topic, jsonStr, retain);
  }

  @override
  Widget build(BuildContext context) {
    const seed = lightBlue;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Theme.of(context).brightness,
    );

    final headline = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface.withOpacity(0.9),
        );

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: scheme,
        appBarTheme: AppBarTheme(
          backgroundColor: sheetBackground,
          elevation: 0,
          foregroundColor: scheme.onSurface,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: scheme.onSurface.withOpacity(.8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 1.6),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Plan Ekle")),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Zamanlama Tipi", style: headline),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'fixed', label: Text('Saat')),
                  ButtonSegment(value: 'sunrise', label: Text('G.Doğumu')),
                  ButtonSegment(value: 'sunset', label: Text('G.Batımı')),
                ],
                selected: {_type},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return scheme.primary;
                    }
                    return scheme.surfaceContainerHighest;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return scheme.onPrimary;
                    }
                    return scheme.onSurface;
                  }),
                  side: WidgetStateProperty.all(
                      BorderSide(color: scheme.outlineVariant)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                ),
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              Text("Gün", style: headline),
              const SizedBox(height: 8),
              Text("Gün(ler)", style: headline),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDays,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_daysSummary())),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: (_selectedDays.contains('Her gun')
                        ? <String>['Her gün']
                        : _selectedDays)
                    .map((d) => Chip(
                          label: Text(d == 'Her gun' ? 'Her gün' : d),
                          backgroundColor: scheme.surfaceContainerHighest,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              if (_type == 'fixed') ...[
                Text("Saat", style: headline),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  tileColor: scheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    "${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  trailing: TextButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: const Text("Seç"),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ] else ...[
                Text("Offset (dk)", style: headline),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor: scheme.primary.withOpacity(.25),
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withOpacity(.1),
                    valueIndicatorColor: scheme.secondary,
                  ),
                  child: Slider(
                    min: -120,
                    max: 120,
                    divisions: 48,
                    value: _trigger.toDouble(),
                    label: "${_trigger >= 0 ? '+' : ''}$_trigger dk",
                    onChanged: (v) => setState(() => _trigger = v.round()),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text("Süre (dk)", style: headline),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: scheme.secondary,
                  inactiveTrackColor: scheme.secondary.withOpacity(.25),
                  thumbColor: scheme.secondary,
                  overlayColor: scheme.secondary.withOpacity(.1),
                  valueIndicatorColor: scheme.secondary,
                ),
                child: Slider(
                  min: 1,
                  max: 120,
                  divisions: 119,
                  value: _duration.toDouble(),
                  label: "$_duration dk",
                  onChanged: (v) => setState(() => _duration = v.round()),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text("Aktif"),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
                activeColor: scheme.primary,
                activeTrackColor: Colors.white,
                tileColor: scheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Kaydet ve Gönder"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
