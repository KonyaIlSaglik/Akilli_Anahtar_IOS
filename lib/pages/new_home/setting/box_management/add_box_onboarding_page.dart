import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_with_chipId.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/use_code_page.dart';
import 'package:akilli_anahtar/pages/managers/install/smart_config_page.dart';

class AddBoxOnboardingPage extends StatefulWidget {
  const AddBoxOnboardingPage({super.key, this.allowSkipExit = false});
  final bool allowSkipExit;

  @override
  State<AddBoxOnboardingPage> createState() => _AddBoxOnboardingPageState();
}

class _AddBoxOnboardingPageState extends State<AddBoxOnboardingPage> {
  final _pc = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _markSeen() async => LocalDb.add("AddBoxOnboardingSeen", "1");

  Future<void> _finishTo(Widget page) async {
    await _markSeen();
    Get.off(() => page);
  }

  Future<void> _skipAll() async {
    await _markSeen();
    if (widget.allowSkipExit) {
      Get.back();
    } else {
      Get.off(() => const AddBoxByChipIdPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = <_Slide>[
      const _Slide(
        icon: Icons.confirmation_number,
        title: "Qr ile cihaz ekle",
        desc: "Kutunun üzerindeki/altındaki etiketten QR kodu okutunuz.\n",
      ),
      const _Slide(
        icon: Icons.wifi,
        title: "Kurulum: 2.4 GHz Wi-Fi",
        desc:
            "Cihaz ekleme tamamlandıktan sonra kutuyu ağa bağlarken 2.4 GHz Wi-Fi kullanın (5 GHz desteklenmez).\nTelefonu cihaza yakın tutun ve kurulum bitene kadar uygulamayı kapatmayın.",
      ),
      const _Slide(
        icon: Icons.admin_panel_settings,
        title: "Yönetici",
        desc:
            "Kutunun kurulumu tamamlandıktan sonra 'Ayarlar > Erişim Kodu Paylaş' bölümünden kullanıcılarınızla paylaşabilirsiniz.",
      ),
    ];
    final isLast = _index == slides.length - 1;

    return Scaffold(
      backgroundColor: sheetBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _skipAll, child: const Text("Atla")),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final s = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, size: 96, color: goldColor),
                        const SizedBox(height: 24),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: active ? 22 : 8,
                  height: 8,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  decoration: BoxDecoration(
                    color: active ? goldColor : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: isLast
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _finishTo(const AddBoxByChipIdPage()),
                            child: const Text("Cihaz Ekle",
                                style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: goldColor,
                              foregroundColor: Colors.white,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _finishTo(const UseCodePage()),
                          child: const Text("Paylaşım Koduyla Cihaza Katıl",
                              style: TextStyle(fontSize: 16)),
                          style: TextButton.styleFrom(
                            foregroundColor: goldColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _pc.nextPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        ),
                        child: const Text(
                          "Devam",
                          style: TextStyle(color: goldColor),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String desc;
  const _Slide({required this.icon, required this.title, required this.desc});
}
