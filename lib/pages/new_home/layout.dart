import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/main/notification_filter_controller.dart';
import 'package:akilli_anahtar/pages/new_home/drawer_page.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/favorite_page.dart';
import 'package:akilli_anahtar/pages/new_home/device/device_list_page.dart';
import 'package:akilli_anahtar/pages/new_home/notification/notification_page.dart';
import 'package:akilli_anahtar/pages/new_home/plan/plan_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/settings_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/back_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  MqttController mqttController = Get.put(MqttController());
  HomeController homeController = Get.put(HomeController());
  NotificationFilterController filterController =
      Get.put(NotificationFilterController());
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 0);
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    print("Layout Created");
    init();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final userId = Get.find<AuthController>().user.value.id.toString();

    final userRef = _database.child('notifications/$userId');

    userRef.onChildAdded.listen((_) => _updateNotificationCount(userId));
    userRef.onChildChanged.listen((_) => _updateNotificationCount(userId));
    userRef.onChildRemoved.listen((_) => _updateNotificationCount(userId));

    _updateNotificationCount(userId);
  }

  Future<void> _updateNotificationCount(String userId) async {
    final ref = _database.child('notifications/$userId');

    try {
      final snapshot = await ref.get();

      List<Map<String, dynamic>> allNotifications = [];

      if (snapshot.exists && snapshot.value is Map) {
        final dateGroups = Map<String, dynamic>.from(snapshot.value as Map);

        for (final dateMap in dateGroups.values) {
          if (dateMap is Map) {
            for (final item in dateMap.entries) {
              final data = item.value;
              if (data is Map) {
                allNotifications.add(Map<String, dynamic>.from(data));
              }
            }
          }
        }

        allNotifications.sort((a, b) => (b['received_at_epoch'] ?? 0)
            .compareTo(a['received_at_epoch'] ?? 0));

        final latest100 = allNotifications.take(100);
        final unreadCount = latest100.where((n) => n['isRead'] != 1).length;

        filterController.unreadCount.value = unreadCount;
      } else {
        filterController.unreadCount.value = 0;
      }
    } catch (e) {
      print('Unread count error: $e');
      filterController.unreadCount.value = 0;
    }
  }

  init() async {
    await mqttController.initClient();
    await homeController.getDevices();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: Colors.brown[50]!,
          foregroundColor: Colors.brown[50]!,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(
            size: 30,
          ),
          title: Text(
            "AKILLI ANAHTAR",
            style: width(context) < minWidth
                ? (textTheme(context).titleMedium ??
                    const TextStyle(fontSize: 20))
                : (textTheme(context).titleLarge ??
                    const TextStyle(fontSize: 24)),
          ),
          actions: [
            Obx(() => NamedIcon(
                  iconData: FontAwesomeIcons.solidBell,
                  notificationCount: filterController.unreadCount.value,
                  onTap: () {
                    Get.to(() => NotificationPage());
                  },
                ))
          ],
        ),
        drawer: DrawerPage(),
        body: PersistentTabView(
          controller: tabController,
          handleAndroidBackButtonPress: false,
          backgroundColor: Colors.brown[50]!,
          navBarHeight: height(context) * 0.07,
          padding: EdgeInsets.all(height(context) * 0.01),
          navBarStyle: NavBarStyle.style6,
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
    );
  }

  PersistentBottomNavBarItem customPersistentBottomNavBarItem(
    IconData iconData, {
    String? title,
  }) {
    return PersistentBottomNavBarItem(
      icon: Icon(iconData),
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

  const NamedIcon({
    super.key,
    this.onTap,
    this.text,
    required this.iconData,
    this.notificationCount = 0,
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
                Icon(iconData),
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
