import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareCodePage extends StatefulWidget {
  final int? deviceId;
  const ShareCodePage({super.key, this.deviceId});

  @override
  State<ShareCodePage> createState() => _ShareCodePageState();
}

class _ShareCodePageState extends State<ShareCodePage> {
  final Set<int> _selected = <int>{};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _generateShareCode() async {
    if (_selected.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);
    String? code;
    try {
      final ids = _selected.whereType<int>().toList(growable: false);
      debugPrint('Selected IDs -> $ids');

      if (ids.length == 1) {
        code = await ManagementService.generateShareCode(ids.first);
      } else {
        code = await ManagementService.generateShareCodeMulti(ids);
      }
    } catch (e) {
      debugPrint("Share code error: $e");
      code = null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (code == null || code.isEmpty) {
      errorSnackbar("Hata", "Kod oluşturulamadı.");
      return;
    }

    _showCodeDialog(code);
  }

  void _showCodeDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, color: Colors.brown, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Oluşturulan Kod",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: SelectableText(
                      code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.brown,
                          side: BorderSide(
                              color: Colors.brown.shade300, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.copy),
                        label: const Text("Kopyala"),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: code));
                          if (ctx.mounted) {
                            successSnackbar(
                                "Kopyalandı", "Kod panoya kopyalandı.");
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text("Paylaş"),
                        onPressed: () async {
                          await Share.share(
                            "Akıllı Anahtar Yönetici Kodu: $code",
                            subject: "Paylaşım Kodu",
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    "Kapat",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final auth = Get.find<AuthController>();

    final adminDevices = home.homeDevices
        .where((d) => d.id != null && auth.adminDeviceIds.contains(d.id))
        .toList();

    final Map<String, List<dynamic>> orgGroups = {};
    for (final d in adminDevices) {
      final key = (d.boxName ?? 'Kutu yok').trim();
      (orgGroups[key] ??= []).add(d);
    }

    final allDeviceIds = adminDevices.map((d) => d.id as int).toList();
    final allSelected =
        _selected.length == allDeviceIds.length && _selected.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yönetici Kodu Oluştur"),
        elevation: 0,
        backgroundColor: sheetBackground,
      ),
      body: adminDevices.isEmpty
          ? const Center(child: Text("Yönetici olduğunuz cihaz bulunamadı."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _GlobalHeader(
                    selectedCount: _selected.length,
                    totalCount: allDeviceIds.length,
                    allSelected: allSelected,
                    onToggleAll: () {
                      setState(() {
                        if (allSelected) {
                          _selected.clear();
                        } else {
                          _selected
                            ..clear()
                            ..addAll(allDeviceIds);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ...orgGroups.entries.map((entry) {
                    final orgName = entry.key;
                    final devices = entry.value;
                    final idsInCard = devices.map((e) => e.id as int).toList();

                    final cardAllSelected = idsInCard.every(_selected.contains);
                    final cardSomeSelected =
                        idsInCard.any(_selected.contains) && !cardAllSelected;

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    orgName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[800],
                                        ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      if (cardAllSelected) {
                                        _selected.removeAll(idsInCard);
                                      } else {
                                        _selected.addAll(idsInCard);
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    cardAllSelected
                                        ? Icons.check_box
                                        : (cardSomeSelected
                                            ? Icons.indeterminate_check_box
                                            : Icons.check_box_outline_blank),
                                  ),
                                  label: Text(
                                    cardAllSelected
                                        ? "Tümünü bırak"
                                        : "Tümünü seç",
                                  ),
                                )
                              ],
                            ),
                            const Divider(height: 8),
                            ...devices.map((d) {
                              final id = d.id as int;
                              final selected = _selected.contains(id);
                              final deviceLabel =
                                  "${d.name ?? 'Cihaz'} • ${d.boxName ?? '-'}";
                              return CheckboxListTile(
                                value: selected,
                                activeColor: primaryDarkBlue,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selected.add(id);
                                    } else {
                                      _selected.remove(id);
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(deviceLabel),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _GenerateFab(
        isLoading: _isLoading,
        selectedCount: _selected.length,
        onPressed:
            (_selected.isEmpty || _isLoading) ? null : _generateShareCode,
      ),
    );
  }
}

class _GlobalHeader extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final bool allSelected;
  final VoidCallback onToggleAll;

  const _GlobalHeader({
    required this.selectedCount,
    required this.totalCount,
    required this.allSelected,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sheetBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Seçilen: $selectedCount / $totalCount",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton.icon(
            onPressed: onToggleAll,
            icon: Icon(allSelected ? Icons.select_all : Icons.checklist),
            label: Text(allSelected ? "Tümünü bırak" : "Tümünü seç"),
          ),
        ],
      ),
    );
  }
}

class _GenerateFab extends StatelessWidget {
  final bool isLoading;
  final int selectedCount;
  final VoidCallback? onPressed;

  const _GenerateFab({
    required this.isLoading,
    required this.selectedCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey.shade400 : goldColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.white),
              )
            : Text(
                selectedCount <= 1
                    ? "SEÇİLEN CİHAZ İÇİN KOD OLUŞTUR"
                    : "SEÇİLEN $selectedCount CİHAZ İÇİN KOD OLUŞTUR",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
