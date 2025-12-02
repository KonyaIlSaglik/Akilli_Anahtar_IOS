import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/helpers/notification_helper.dart';
import 'package:akilli_anahtar/pages/managers/box/list.dart';
import 'package:akilli_anahtar/pages/managers/install/smart_config_page.dart';
import 'package:akilli_anahtar/pages/managers/install/wifi_settings_page.dart';
import 'package:akilli_anahtar/pages/managers/user/admin_user_page.dart';
import 'package:akilli_anahtar/pages/managers/user/organisation_settings_page.dart';
import 'package:akilli_anahtar/pages/managers/user/user_list_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_onboarding_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_with_chipId.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/share_code_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/use_code_page.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/pages/new_home/setting/report_management_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  HomeController homeController = Get.find();
  final AuthController authController = Get.find();
  final LoginController loginController = Get.find();
  late List<HomeDeviceDto> sensors;

  bool serviceIsRunning = false;
  String selectedNotificationRange = notificationRanges[0];

  @override
  void initState() {
    super.initState();
    sensors = homeController.homeDevices.where((d) => d.typeId! < 4).toList();
    init();
  }

  void init() async {
    if (serviceIsRunning && !(await isRunning())) {
      await initializeService();
    }

    String? notificationRange = await LocalDb.get(notificationRangeKey);
    if (notificationRange != null) {
      setState(() {
        selectedNotificationRange = notificationRange;
      });
    } else {
      await LocalDb.update(notificationRangeKey, selectedNotificationRange);
    }

    var list = homeController.homeDevices;
    for (var device in list) {
      await LocalDb.get(notificationKey(device.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAdmin = authController.adminDeviceIds;
      final claims = authController.session.value.claims ?? [];

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          _buildGroupTitle("Uygulama Ayarları", darkBlue),
          _buildColoredCard(
            backgroundColor: sheetBackground,
            icon: Icons.notifications,
            iconColor: darkBlue,
            title: "Bildirim",
            subtitle: "Arka planda sensör bildirimleri",
            trailing: TextButton(
              onPressed: () async {
                if (await isRunning()) {
                  stopBackgroundService();
                } else {
                  await initializeService();
                }

                openAppNotificationSettings();
              },
              child: const Text(
                "Aç/Kapat",
                style: TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            backgroundColor: sheetBackground,
            icon: Icons.system_update,
            iconColor: darkBlue,
            title: "Uygulamayı Güncelle",
            onTap: () => checkNewVersion(context, true),
          ),
          if (isAdmin.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildGroupTitle("Yönetici Ayarları", darkBlue),
            _buildSettingsCard(
              backgroundColor: sheetBackground,
              icon: Icons.share,
              iconColor: primaryDarkBlue,
              title: "Yönetici Kodu Oluştur",
              subtitle: "Cihaz paylaşım kodu oluştur",
              onTap: () => Get.to(() => ShareCodePage(deviceId: isAdmin.first)),
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(
              backgroundColor: sheetBackground,
              icon: FontAwesomeIcons.users,
              iconColor: primaryDarkBlue,
              title: " Kullanıcıları listele",
              onTap: () => Get.to(() => UserManagementPage()),
            ),
          ],
          const SizedBox(height: 20),
          _buildGroupTitle("Cihaz Yönetimi", darkBlue),
          _buildSettingsCard(
            backgroundColor: sheetBackground,
            icon: Icons.code,
            iconColor: mediumBlue,
            title: "Yönetici Kodu Giriş",
            onTap: () => Get.to(() => UseCodePage()),
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            backgroundColor: sheetBackground,
            icon: Icons.add_box_rounded,
            iconColor: mediumBlue,
            title: "Cihaz Ekle",
            onTap: () async {
              final seen = await LocalDb.get("AddBoxOnboardingSeen") == "1";
              if (!seen) {
                Get.to(() => const AddBoxOnboardingPage());
              } else {
                Get.to(() => const AddBoxByChipIdPage());
              }
            },
          ),
          if (isAdmin.isNotEmpty || claims.contains("device_install")) ...[
            const SizedBox(height: 20),
            _buildGroupTitle("Kutu Ayarları", darkBlue),
            _buildSettingsCard(
              backgroundColor: sheetBackground,
              icon: Icons.wifi_find,
              iconColor: primaryPinkColor,
              title: "Kutu Kurulum",
              subtitle: "cihazınızın internet bağlantısını kurun",
              onTap: () => Get.to(() => SmartConfigPage()),
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(
              backgroundColor: sheetBackground,
              icon: Icons.wifi,
              iconColor: primaryPinkColor,
              title: "Wifi Bilgilerini Güncelle",
              subtitle: "Ana wifi ve yedek wifi güncelleyin.",
              onTap: () => Get.to(() => WifiMqttFormPage()),
            ),
            const SizedBox(height: 20),
          ],
          if (claims.contains("device_install") ||
              claims.contains("developer")) ...[
            _buildGroupTitle("Yönetim Ayarları", darkBlue),
            if (claims.contains("developer"))
              _buildSettingsCard(
                backgroundColor: sheetBackground,
                icon: Icons.add_box,
                iconColor: grayNeutral,
                title: "Kutu Yönetimi",
                onTap: () => Get.to(() => BoxListPage()),
              ),
            const SizedBox(height: 8),
            _buildSettingsCard(
              backgroundColor: sheetBackground,
              icon: Icons.person,
              iconColor: grayNeutral,
              title: "Kullanıcı Yönetimi",
              onTap: () => Get.to(() => UserListPage()),
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(
                backgroundColor: sheetBackground,
                icon: FontAwesomeIcons.sitemap,
                iconColor: grayNeutral,
                title: "Organizasyon Yönetimi",
                onTap: () => Get.to(() => OrganisationListPage())),
          ],
          const SizedBox(height: 8),
          _buildGroupTitle("Raporlar", darkBlue),
          _buildSettingsCard(
            backgroundColor: sheetBackground,
            icon: Icons.report,
            iconColor: grayNeutral,
            title: "Sensör Raporları",
            onTap: () {
              Get.to(() => SensorReportsPage());
            },
          ),
          const SizedBox(height: 20),
          _buildGroupTitle("Hesap Ayarları", darkBlue),
          _buildSettingsCard(
              backgroundColor: sheetBackground,
              icon: Icons.logout,
              iconColor: Colors.red,
              title: "Oturumdan Çık",
              onTap: () async {
                await authController.logOut2(
                  authController.session.value.id,
                  loginController.deviceId.value,
                );
              }),
        ],
      );
    });
  }

  Widget _buildGroupTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildColoredCard({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: Colors.grey[800])),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: trailing,
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: Colors.grey[800])),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Colors.grey[600]))
            : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
        onTap: onTap,
      ),
    );
  }
}
