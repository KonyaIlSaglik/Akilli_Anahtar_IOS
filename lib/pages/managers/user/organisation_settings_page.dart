import 'package:akilli_anahtar/dtos/organisation_dto.dart';
import 'package:akilli_anahtar/pages/managers/user/add_organisation_page.dart';
import 'package:akilli_anahtar/pages/managers/user/organisation_settings_update_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/dtos/bm_organisation_dto.dart';
import 'package:akilli_anahtar/services/api/box_management_service.dart';

const coffeeDark = Colors.brown;
const coffee = Color(0xFF6D4C41);
const coffeeLite = Color(0xFF8D6E63);

class OrganisationListPage extends StatefulWidget {
  const OrganisationListPage({super.key});

  @override
  State<OrganisationListPage> createState() => _OrganisationListPageState();
}

class _OrganisationListPageState extends State<OrganisationListPage> {
  final authController = Get.find<AuthController>();
  final _searchCtrl = TextEditingController();

  List<BmOrganisationDto> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = authController.user.value.id;
      if (userId == null) {
        setState(() => _error = "Kullanıcı ID bulunamadı (null).");
        return;
      }
      final res = await BoxManagementService.getOrganisations(userId);
      setState(() => _items = res ?? []);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<BmOrganisationDto> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((o) {
      final title = (o.name ?? '').toLowerCase();
      final idText = (o.id?.toString() ?? '');
      return title.contains(q) || idText.contains(q);
    }).toList();
  }

  Future<void> _goAdd() async {
    final ok = await Get.to(() => OrganisationCreatePage());
    if (ok == true) _load();
  }

  void _goUpdate(BmOrganisationDto org) {
    final id = org.id;
    if (id == null) {
      errorSnackbar("Hata", "Organizasyon ID bulunamadı.");
      return;
    }
    Get.to(() => OrganisationSettingsUpdatePage(
          organisationId: id,
          organisationName: org.name,
        ))?.then((ok) {
      if (ok == true) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sheetBackground,
      appBar: AppBar(
        backgroundColor: sheetBackground,
        elevation: 2,
        titleSpacing: 10,
        title: Container(
          height: 46,
          decoration: BoxDecoration(
            color: coffeeDark.withOpacity(0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: coffeeDark.withOpacity(0.15)),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _searchCtrl,
            cursorColor: coffee,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: "Organizasyon Ara...",
              hintStyle: const TextStyle(color: coffeeLite),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: coffee),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      color: coffeeLite,
                      onPressed: () {
                        _searchCtrl.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(color: coffeeDark),
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Organizasyon ekle",
            icon: const Icon(Icons.add_box, color: coffee),
            onPressed: _goAdd,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: coffee,
        backgroundColor: Colors.white,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (_, __) => const _ShimmerTile(),
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: coffee),
                const SizedBox(height: 12),
                Text(
                  "Bir hata oluştu:\n$_error",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: coffeeDark),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coffee,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Tekrar Dene"),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (_filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              "Kayıt bulunamadı.",
              style: TextStyle(color: coffeeLite),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) =>
          Divider(height: 10, color: coffeeDark.withOpacity(0.10)),
      itemBuilder: (_, i) {
        final org = _filtered[i];
        final title = org.name ?? 'İsimsiz Organizasyon';
        final idLabel = org.id?.toString() ?? '?';

        return Card(
          color: Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: coffeeDark.withOpacity(0.50)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _goUpdate(org),
            splashColor: coffee.withOpacity(0.10),
            highlightColor: coffee.withOpacity(0.04),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: goldColor,
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      idLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right, color: coffeeDark),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: coffeeDark.withOpacity(0.06)),
      ),
      child: const ListTile(
        leading: CircleAvatar(backgroundColor: sheetBackground),
        title: _GrayBox(width: 160),
        subtitle: _GrayBox(width: 100),
      ),
    );
  }
}

class _GrayBox extends StatelessWidget {
  final double width;
  const _GrayBox({required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: width,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
