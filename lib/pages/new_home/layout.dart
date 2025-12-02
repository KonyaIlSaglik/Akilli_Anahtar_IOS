import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/main/notification_filter_controller.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/favorite_page.dart';
import 'package:akilli_anahtar/pages/new_home/device/device_list_page.dart';
import 'package:akilli_anahtar/pages/new_home/notification/notification_page.dart';
import 'package:akilli_anahtar/pages/new_home/plan/plan_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/settings_page.dart';
import 'package:akilli_anahtar/pages/profile/profile_page.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/back_container.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'dart:ui' show ImageFilter;
import 'package:akilli_anahtar/pages/new_home/appbar.dart' as custom_appbar;

class Layout extends StatefulWidget {
  const Layout({super.key});
  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  MqttController mqttController = Get.put(MqttController());
  HomeController homeController = Get.put(HomeController());
  AuthController authController = Get.find<AuthController>();
  final user = Get.find<AuthController>().user.value;
  NotificationFilterController filterController =
      Get.put(NotificationFilterController());
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    print("Layout Created");

    Get.put(this, tag: 'layoutState', permanent: true);
    init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
    });
  }

  Future<void> _checkNotificationPermission() async {
    final alreadyAsked = await LocalDb.get(notificationPermissionKey);

    if (alreadyAsked != "true") {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print(' Bildirim izni verildi.');
      } else {
        print(' Bildirim izni reddedildi.');
      }

      await LocalDb.add(notificationPermissionKey, "true");
    }
  }

  Future<void> _updateNotificationCount(String userId) async {
    final ref = FirebaseDatabase.instance.ref('notifications/$userId');

    int unread = 0;
    const int fetchSize = 100;
    const int maxLoops = 10;

    String? endAtKey;

    for (int i = 0; i < maxLoops; i++) {
      Query query = ref.orderByKey().limitToLast(fetchSize);
      if (endAtKey != null) query = query.endBefore(endAtKey);

      final snapshot = await query.get();
      if (!snapshot.exists || snapshot.value is! Map) break;

      final items = Map<String, dynamic>.from(snapshot.value as Map)
        ..removeWhere((key, value) => value is! Map);

      final sorted = items.entries.toList()
        ..sort((a, b) => int.parse(b.key).compareTo(int.parse(a.key)));

      for (final entry in sorted) {
        final isRead = entry.value['isRead'];
        if (isRead == null || isRead != 1) {
          unread++;
        }
      }

      endAtKey = sorted.last.key;
    }

    filterController.unreadCount.value = unread > 99 ? 100 : unread;
  }

  Future<void> init() async {
    await mqttController.initClient();
    await homeController.getDevices();
    await refreshNotificationCount();
    await ManagementService.getUserDevices();
  }

  Future<void> refreshNotificationCount() async {
    final userId = Get.find<AuthController>().user.value.id.toString();
    await _updateNotificationCount(userId);
    await authController.fetchAndAssignUserRoles();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceCount = homeController.groupedDevices.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (tabController.index == 0) {
          exitApp(context);
        } else {
          tabController.index = 0;
        }
      },
      child: Scaffold(
        appBar: custom_appbar.AppBar(
          title: Image.asset(
            'assets/anahtar7.png',
            height: 27,
          ),
          unread: filterController.unreadCount.value,
          onBellTap: () {
            Get.to(() => NotificationPage())
                ?.then((_) => refreshNotificationCount());
          },
          onProfileTap: () => Get.to(() => ProfilePage()),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: refreshNotificationCount,
                child: PersistentTabView(
                  controller: tabController,
                  handleAndroidBackButtonPress: false,
                  backgroundColor: Colors.brown[50]!,
                  navBarHeight: height(context) * 0.07,
                  padding: EdgeInsets.all(height(context) * 0.01),
                  navBarStyle: NavBarStyle.simple,
                  context,
                  screens: [
                    BackContainer(child: FavoritePage()),
                    BackContainer(child: DeviceListPage()),
                    BackContainer(child: PlanPage()),
                    BackContainer(child: SettingsPage()),
                  ],
                  items: [
                    customPersistentBottomNavBarItem(
                      FontAwesomeIcons.solidHeart,
                      title: "Favoriler",
                    ),
                    customPersistentBottomNavBarItem(
                      FontAwesomeIcons.boxesStacked,
                      title: "Cihazlar",
                      badgeCount: deviceCount > 99 ? 99 : deviceCount,
                    ),
                    customPersistentBottomNavBarItem(
                      FontAwesomeIcons.solidClock,
                      title: "Planlar",
                    ),
                    customPersistentBottomNavBarItem(
                      FontAwesomeIcons.gear,
                      title: "Ayarlar",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PersistentBottomNavBarItem customPersistentBottomNavBarItem(
    IconData iconData, {
    String? title,
    int? badgeCount,
  }) {
    return PersistentBottomNavBarItem(
      icon: SizedBox(
        width: 40,
        height: 30,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(iconData, size: 24),
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 99 ? "99+" : "$badgeCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      title: title,
      activeColorPrimary: goldColor,
      activeColorSecondary: goldColor,
      inactiveColorPrimary: Colors.black54,
      inactiveColorSecondary: Colors.black54,
    );
  }
}

class NamedIcon extends StatelessWidget {
  final IconData iconData;
  final String? text;
  final VoidCallback? onTap;
  final int notificationCount;
  final double? size;

  const NamedIcon({
    super.key,
    this.onTap,
    this.text,
    required this.iconData,
    this.notificationCount = 0,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData, size: size ?? 24),
                if (text != null) Text(text!, overflow: TextOverflow.ellipsis),
              ],
            ),
            if (notificationCount > 0)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  alignment: Alignment.center,
                  child: Text(
                    notificationCount < 100 ? "$notificationCount" : "99+",
                    style: textTheme(context).labelMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
