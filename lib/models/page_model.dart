import 'package:akilli_anahtar/pages/new_home/favorite/zz_favorite_edit_page_old.dart';
import 'package:akilli_anahtar/pages/new_home/favorite/favorite_page.dart';
import 'package:akilli_anahtar/pages/new_home/grouped/grouped_page.dart';
import 'package:akilli_anahtar/pages/new_home/profile/profile_page.dart';
import 'package:flutter/material.dart';

class PageModel {
  String route;
  Widget page;

  PageModel({
    required this.route,
    required this.page,
  });

  static const String groupedPage = "grouped";
  static const String favoritePage = "favorites";
  static const String favoriteEditPage = "favoriteEdit";
  static const String profilePage = "profile";

  static List<PageModel> pagesList = <PageModel>[
    PageModel(route: groupedPage, page: GroupedPage()),
    PageModel(route: favoritePage, page: FavoritePage()),
    PageModel(route: favoriteEditPage, page: FavoriteEditPageOld()),
    PageModel(route: profilePage, page: ProfilePage()),
  ];

  static PageModel? get(String name) {
    return pagesList.singleWhere((p) => p.route == name);
  }

  static bool exist(page) {
    return pagesList.any((p) => p.route == page);
  }
}
