import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/app_input_field.dart';
import 'package:akilli_anahtar/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/dtos/organisation_dto.dart';
import 'package:akilli_anahtar/services/api/box_management_service.dart';

class OrganisationSettingsUpdatePage extends StatefulWidget {
  final int organisationId;
  final String? organisationName;

  const OrganisationSettingsUpdatePage({
    super.key,
    required this.organisationId,
    this.organisationName,
  });

  @override
  State<OrganisationSettingsUpdatePage> createState() =>
      _OrganisationSettingsUpdatePageState();
}

class _OrganisationSettingsUpdatePageState
    extends State<OrganisationSettingsUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _type = TextEditingController();
  final _maxUserCount = TextEditingController();
  final _maxSessionCount = TextEditingController();

  List<dynamic> _cities = [];
  List<dynamic> _allDistricts = [];
  List<dynamic> _districts = [];
  int? _selectedCityId;
  int? _selectedDistrictId;
  int? _selectedType;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  int idOf(dynamic d) => _asInt(d?.id ?? d?.Id);
  int cityIdOf(dynamic d) => _asInt(d?.cityId ?? d?.CityId);

  List<dynamic> _uniqById(List<dynamic> list) {
    final seen = <int>{};
    final out = <dynamic>[];
    for (final e in list) {
      final id = idOf(e);
      if (!seen.contains(id)) {
        seen.add(id);
        out.add(e);
      }
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  static const _typeItems = [
    DropdownMenuItem(value: 1, child: Text('Kurumsal')),
    DropdownMenuItem(value: 2, child: Text('Bireysel')),
  ];

  Future<void> _bootstrap() async {
    try {
      final cities = await HomeService.getAllCity();
      final districts = await HomeService.getAllDistrict();
      final detail =
          await BoxManagementService.getOrganisation(widget.organisationId);

      if (detail != null) {
        _name.text = detail.name;
        _address.text = detail.address ?? '';
        _type.text = detail.type?.toString() ?? '';
        _maxUserCount.text = detail.maxUserCount?.toString() ?? '';
        _maxSessionCount.text = detail.maxSessionCount?.toString() ?? '';
        _selectedCityId = detail.cityId;
        _selectedDistrictId = detail.districtId;
      } else {
        _name.text = widget.organisationName ?? '';
      }
      _selectedType =
          (detail?.type == 1 || detail?.type == 2) ? detail!.type : null;
      _cities = cities ?? [];
      _allDistricts = districts ?? [];

      if (_selectedCityId != null) {
        _districts = _allDistricts
            .where((d) => (d.cityId ?? d.CityId) == _selectedCityId)
            .toList();
      } else {
        _districts = [];
      }

      _cities = _uniqById(_cities);
      _districts = _uniqById(_districts);

      if (_selectedCityId != null &&
          !_cities.any((c) => idOf(c) == _selectedCityId)) {
        _selectedCityId = null;
      }
      if (_selectedDistrictId != null &&
          !_districts.any((d) => idOf(d) == _selectedDistrictId)) {
        _selectedDistrictId = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int? _toInt(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final dto = OrganisationDto(
        id: widget.organisationId,
        name: _name.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        cityId: _selectedCityId,
        districtId: _selectedDistrictId,
        type: _selectedType,
        maxUserCount: _toInt(_maxUserCount.text),
        maxSessionCount: _toInt(_maxSessionCount.text),
      );

      await BoxManagementService.updateOrganisation(dto);

      if (!mounted) return;
      successSnackbar('Başarılı', 'Organizasyon güncellendi');

      Navigator.of(context).pop(true);
    } catch (e) {
      errorSnackbar("Hata", "Organizasyon Güncellenemedi");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _type.dispose();
    _maxUserCount.dispose();
    _maxSessionCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizasyon Güncelle'),
        backgroundColor: sheetBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                color: Colors.white,
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
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        controller: _address,
                        icon: Icons.location_on,
                        label: "Adres",
                        inputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
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
                        items: _cities.map((c) {
                          final id = (c.id ?? c.Id) as int;
                          final name =
                              (c.name ?? c.Name ?? c.cityName) as String;
                          return DropdownMenuItem(
                            value: id,
                            child: Text(name),
                          );
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
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField(
                        value: _selectedDistrictId,
                        label: "İlçe",
                        icon: Icons.maps_home_work,
                        items: _districts.map<DropdownMenuItem<int>>((d) {
                          final id = (d.id ?? d.Id) as int;
                          final name = (d.name ?? d.Name) as String;
                          return DropdownMenuItem(
                            value: id,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDistrictId = val),
                      )
                    ],
                  ),
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
                        'Kısıtlamalar',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                      ),
                      const SizedBox(height: 12),
                      AppDropdownField<int>(
                        value: _selectedType,
                        label: "Tür",
                        icon: Icons.category,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Kurumsal")),
                          DropdownMenuItem(value: 2, child: Text("Bireysel")),
                        ],
                        onChanged: (v) => setState(() => _selectedType = v),
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
                              inputAction: TextInputAction.next,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _saving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Kaydediliyor...'),
                          ],
                        )
                      : const Text(
                          'Güncelle',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
