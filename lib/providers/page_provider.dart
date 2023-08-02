import 'package:derslig/models/page_model.dart';
import 'package:derslig/views/derslig_pro_page.dart';
import 'package:derslig/views/web_view_page.dart';
import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier {
  List<PageModel> pages = [
    PageModel(
      title: "Home",
      icon: const Icon(Icons.home),
      selectedIcon: const Icon(Icons.home),
      page: const WebViewPage(),
    ),
    PageModel(
      title: "Derslig Pro",
      icon: const Icon(Icons.home),
      selectedIcon: const Icon(Icons.home),
      page: DersligProPage(),
    ),
  ];

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  PageModel get currentPage => pages[_currentIndex];
}
