import 'dart:async';

import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/share_code_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});
  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> users = [];
  Map<String, List<Map<String, dynamic>>> groupedUsers = {};
  final AuthController authController = Get.find();

  int page = 0;
  bool isLoading = false;
  bool hasMore = true;
  String? _loadingKey;

  List<UMItem> get flatItems => _buildFlatItems(groupedUsers);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchUsers();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      page = 0;
      hasMore = true;
      _fetchUsers(reset: true);
    });
  }

  void _groupUsersByOrganisation() {
    groupedUsers = {};
    for (var user in users) {
      final orgName = user['organisationName'] ?? "Bilinmeyen Kurum";
      groupedUsers.putIfAbsent(orgName, () => []).add(user);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String? s) {
    if (s == null) return '';
    final lower = s.toLowerCase();
    return lower
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('i̇', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll('â', 'a')
        .replaceAll('ê', 'e')
        .replaceAll('î', 'i')
        .replaceAll('û', 'u')
        .replaceAll('ô', 'o')
        .trim();
  }

  Future<void> _fetchUsers({bool reset = false}) async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    const pageSize = 20;
    final searchText = _searchController.text.trim();

    final result = await ManagementService.getDeviceUsers2(
          page: reset ? 0 : page,
          pageSize: pageSize,
          query: searchText,
        ) ??
        <Map<String, dynamic>>[];

    List<Map<String, dynamic>> effective = result;
    if (searchText.isNotEmpty) {
      final q = _normalize(searchText);
      effective = result.where((u) {
        final name = _normalize(u['fullName']?.toString() ?? '');
        return name.contains(q);
      }).toList();

      effective.sort((a, b) => _normalize(a['fullName']?.toString())
          .compareTo(_normalize(b['fullName']?.toString())));
    }

    if (reset) {
      users
        ..clear()
        ..addAll(effective);
      page = 0;
    } else {
      users.addAll(effective);
    }

    _groupUsersByOrganisation();

    if (searchText.isNotEmpty) {
      hasMore = false;
    } else {
      hasMore = result.length >= pageSize;
      if (hasMore) page++;
    }

    setState(() => isLoading = false);
  }

  void _toggleUserStatus(int userId, int deviceId, bool nextActive) async {
    final key = "$userId-$deviceId";
    setState(() => _loadingKey = key);

    final newStatus =
        await ManagementService.usersDeviceStatus2(userId, deviceId);

    if (newStatus != null) {
      for (final u in users) {
        if (u["userId"] == userId && u["deviceId"] == deviceId) {
          u["isActive"] = newStatus;
        }
      }
      _groupUsersByOrganisation();

      successSnackbar(
        "Güncellendi",
        newStatus == 1 ? "Kullanıcı aktif." : "Kullanıcı pasif.",
      );
    } else {
      errorSnackbar("Hata", "Durum güncellenemedi. Lütfen tekrar deneyin.");
    }

    setState(() => _loadingKey = null);
  }

  String _obscureUsername(String username) {
    if (username.length <= 2) return '*' * username.length;
    return '${username.substring(0, 2)}${'*' * (username.length - 2)}';
  }

  String formatUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return 'Kullanıcı';
      case 'admin':
        return 'Yönetici';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = authController.adminDeviceIds;

    return Scaffold(
      backgroundColor: sheetBackground,
      appBar: AppBar(
        backgroundColor: sheetBackground,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
        title: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: Colors.brown[100],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: "Kullanıcı ara...",
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.brown),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.brown, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        page = 0;
                        hasMore = true;
                        _fetchUsers(reset: true);
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) {
              page = 0;
              hasMore = true;
              _fetchUsers(reset: true);
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.brown),
            onPressed: () {
              if (users.isNotEmpty) {
                final int? deviceId = users.first["deviceId"];
                if (deviceId != null) {
                  Get.to(() => ShareCodePage(deviceId: deviceId));
                } else {
                  errorSnackbar("Hata", "Cihaz ID'si alınamadı.");
                }
              } else {
                errorSnackbar("Uyarı", "Kullanıcı listesi boş.");
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  final searching = _searchController.text.trim().isNotEmpty;
                  if (!isLoading &&
                      !searching &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 100) {
                    _fetchUsers();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: flatItems.length,
                  cacheExtent: 300,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (_, index) {
                    final item = flatItems[index];

                    if (item is UMHeader) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.brown.shade100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            item.orgName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final u = (item as UMUser).user;
                    final bool isActive = (u["isActive"] ?? 0) == 1;
                    final String role =
                        (u["role"] ?? "").toString().toLowerCase();
                    final key = "${u["userId"]}-${u["deviceId"]}";
                    final isBusy = _loadingKey == key;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.brown.shade100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(u["fullName"] ?? "-",
                            style: const TextStyle(fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_obscureUsername(u["userName"] ?? ""),
                                style: const TextStyle(fontSize: 14)),
                            Text(
                                "${formatUserRole(role)} - Cihaz: ${u["deviceName"]}",
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: SizedBox(
                          height: 34,
                          child: OutlinedButton(
                            onPressed: isBusy
                                ? null
                                : () {
                                    // yüklenirken disable
                                    if (role == "admin") {
                                      Get.defaultDialog(
                                        title: "Uyarı",
                                        middleText:
                                            "Yönetici olan bir kullanıcıyı pasif yapamazsınız.",
                                        textConfirm: "Tamam",
                                        confirmTextColor: Colors.white,
                                        onConfirm: () => Get.back(),
                                      );
                                    } else {
                                      _toggleUserStatus(u["userId"],
                                          u["deviceId"], !isActive);
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: isActive ? Colors.green : Colors.red),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: isBusy
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(
                                    isActive ? "Aktif" : "Pasif",
                                    style: TextStyle(
                                        color: isActive
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

abstract class UMItem {}

class UMHeader implements UMItem {
  final String orgName;
  UMHeader(this.orgName);
}

class UMUser implements UMItem {
  final Map<String, dynamic> user;
  UMUser(this.user);
}

List<UMItem> _buildFlatItems(Map<String, List<Map<String, dynamic>>> grouped) {
  final items = <UMItem>[];
  grouped.forEach((org, list) {
    items.add(UMHeader(org));
    for (final u in list) {
      items.add(UMUser(u));
    }
  });
  return items;
}
