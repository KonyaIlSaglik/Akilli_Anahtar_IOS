import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:akilli_anahtar/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/dtos/organisation_dto.dart';
import 'package:akilli_anahtar/services/api/box_management_service.dart';

class OrganisationCreatePage extends StatefulWidget {
  const OrganisationCreatePage({super.key});

  @override
  State<OrganisationCreatePage> createState() => _OrganisationCreatePageState();
}

class _OrganisationCreatePageState extends State<OrganisationCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _address = TextEditingController();
  final _maxUserCount = TextEditingController();
  final _maxSessionCount = TextEditingController();

  List<dynamic> _cities = [];
  List<dynamic> _allDistricts = [];
  List<dynamic> _districts = [];
  int? _selectedCityId;
  int? _selectedDistrictId;
  int? _selectedType; // 1=Kurumsal, 2=Bireysel

  bool _loading = true;
  bool _saving = false;

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  int idOf(dynamic d) => _asInt(d?.id ?? d?.Id);
  int cityIdOf(dynamic d) => _asInt(d?.cityId ?? d?.CityId);
  String cityNameOf(dynamic c) =>
      (c?.name ?? c?.Name ?? c?.cityName ?? '').toString();
  String districtNameOf(dynamic d) => (d?.name ?? d?.Name ?? '').toString();

  List<T> uniqById<T>(Iterable<T> list, int Function(T) keyOf) {
    final seen = <int>{};
    final out = <T>[];
    for (final e in list) {
      final k = keyOf(e);
      if (seen.add(k)) out.add(e);
    }
    return out;
  }

  static const _typeItems = [
    DropdownMenuItem(value: 1, child: Text('Kurumsal')),
    DropdownMenuItem(value: 2, child: Text('Bireysel')),
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final cities = await HomeService.getAllCity() ?? [];
      final districts = await HomeService.getAllDistrict() ?? [];

      final uniqCities = uniqById<dynamic>(cities, idOf);
      final uniqAllDist = uniqById<dynamic>(districts, idOf);

      if (!mounted) return;
      setState(() {
        _cities = uniqCities;
        _allDistricts = uniqAllDist;
        _districts = const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  int? _toInt(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final dto = OrganisationDto(
        name: _name.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        cityId: _selectedCityId,
        districtId: _selectedDistrictId,
        type: _selectedType,
        maxUserCount: _toInt(_maxUserCount.text),
        maxSessionCount: _toInt(_maxSessionCount.text),
      );

      await BoxManagementService.createOrganisation(dto);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      print('Organizasyon oluşturulamadı.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _maxUserCount.dispose();
    _maxSessionCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Organizasyon Ekle'), backgroundColor: sheetBackground),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temel Bilgiler',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                      ),
                      const SizedBox(height: 12),
                      AppInputField(
                        controller: _name,
                        icon: Icons.business,
                        label: "Organizasyon Adı *",
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Zorunlu alan"
                            : null,
                        nextFocus: null,
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        controller: _address,
                        icon: Icons.location_on,
                        label: "Adres",
                        keyboardType: TextInputType.text,
                      ),
                    ]),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konum Bilgileri',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                      ),
                      const SizedBox(height: 12),
                      AppDropdownField<int>(
                        value: _selectedCityId,
                        label: "Şehir",
                        icon: Icons.location_city,
                        items: _cities.map<DropdownMenuItem<int>>((c) {
                          final id = idOf(c);
                          return DropdownMenuItem(
                              value: id, child: Text(cityNameOf(c)));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCityId = val;
                            _selectedDistrictId = null;
                            _districts = (val == null)
                                ? []
                                : _allDistricts
                                    .where((d) => cityIdOf(d) == val)
                                    .toList();
                            _districts = uniqById<dynamic>(_districts, idOf);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        value: _selectedDistrictId,
                        label: "İlçe",
                        icon: Icons.map,
                        items: _districts.map<DropdownMenuItem<int>>((d) {
                          final id = idOf(d);
                          return DropdownMenuItem(
                              value: id, child: Text(districtNameOf(d)));
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDistrictId = val),
                      ),
                    ]),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tür & Kısıtlamalar',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                      ),
                      const SizedBox(height: 12),
                      AppDropdownField<int>(
                        value: (_selectedType == 1 || _selectedType == 2)
                            ? _selectedType
                            : null,
                        label: "Tür",
                        icon: Icons.category,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Kurumsal")),
                          DropdownMenuItem(value: 2, child: Text("Bireysel")),
                        ],
                        onChanged: (v) => setState(() => _selectedType = v),
                        validator: (v) => v == null ? "Tür seçiniz" : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppInputField(
                              controller: _maxUserCount,
                              icon: Icons.people,
                              label: "Maks. Kullanıcı",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInputField(
                              controller: _maxSessionCount,
                              icon: Icons.event,
                              label: "Maks. Oturum",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _saving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text('Kaydediliyor...'),
                        ],
                      )
                    : const Text('Oluştur',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
