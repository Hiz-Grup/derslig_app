import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/models/page_model.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/views/back_button_widget.dart';
import 'package:derslig/views/derslig_pro_page.dart';
import 'package:derslig/views/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Anasayfa, Profilim, Derslig Pro, Dersler
  List<PageModel> pages = [
    PageModel(
      title: "Ana Sayfa",
      icon: const Icon(Icons.home_rounded),
      selectedIcon: const Icon(Icons.home_rounded),
      page: const WebViewPage(
        url: "https://www.derslig.com/uyelik",
      ),
    ),
    PageModel(
      title: "Profilim",
      icon: const Icon(Icons.person_rounded),
      selectedIcon: const Icon(Icons.person_rounded),
      page: const WebViewPage(
        url: "https://www.derslig.com/profilim",
      ),
    ),
    PageModel(
      title: "Derslig Pro",
      icon: const Icon(Icons.workspace_premium_rounded),
      selectedIcon: const Icon(Icons.workspace_premium_rounded),
      page: const DersligProPage(),
    ),
    PageModel(
      title: "Dersler",
      icon: const Icon(Icons.menu_book_rounded),
      selectedIcon: const Icon(Icons.menu_book_rounded),
      page: const WebViewPage(
        url: "https://www.derslig.com/dersler",
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavigation(),
      body: IndexedStack(
        index: context.watch<PageProvider>().currentIndex,
        children: pages.map((e) => e.page).toList(),
      ),
    );
  }

  BottomNavigationBar bottomNavigation() {
    return BottomNavigationBar(
      onTap: (index) {
        context.read<PageProvider>().currentIndex = index;
      },
      type: BottomNavigationBarType.fixed,
      //active colro of bottom navigation bar
      selectedItemColor: AppTheme.pink,
      currentIndex: context.watch<PageProvider>().currentIndex,
      selectedLabelStyle: AppTheme.boldTextStyle(context, 16),
      unselectedLabelStyle: AppTheme.normalTextStyle(context, 12),
      iconSize: deviceFontSize(context, 30),
      selectedIconTheme: IconThemeData(size: deviceFontSize(context, 32)),
      unselectedItemColor: AppTheme.black.withOpacity(0.5),
      items: pages
          .map(
            (e) => BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                  top: deviceHeightSize(context, 10),
                  bottom: deviceHeightSize(context, 1),
                ),
                child: e.icon,
              ),
              label: e.title,
              activeIcon: Padding(
                padding: EdgeInsets.only(
                  top: deviceHeightSize(context, 10),
                  bottom: deviceHeightSize(context, 5),
                ),
                child: e.selectedIcon,
              ),
            ),
          )
          .toList(),
    );
  }
}
