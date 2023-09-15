import 'package:derslig/models/page_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/views/derslig_pro_page.dart';
import 'package:derslig/views/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  var isDeviceConnected = false;

  // Anasayfa, Profilim, Derslig Pro, Dersler

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      // bottomNavigationBar: context.watch<LoginRegisterPageProvider>().isLogin &&
      //         deviceHeight(context) > 500
      //     ? bottomNavigation()
      //     : null,
      // body: IndexedStack(
      //   index: context.watch<PageProvider>().pageIndex,
      //   children: pages.map((e) => e.page).toList(),
      // ),
    );
  }

  // BottomNavigationBar bottomNavigation() {
  //   return BottomNavigationBar(
  //     onTap: (index) {
  //       context.read<PageProvider>().currentIndex = index;
  //     },
  //     type: BottomNavigationBarType.fixed,
  //     //active colro of bottom navigation bar
  //     selectedItemColor: AppTheme.pink,
  //     currentIndex: context.watch<PageProvider>().currentIndex,
  //     selectedLabelStyle: AppTheme.boldTextStyle(context, 16),
  //     unselectedLabelStyle: AppTheme.normalTextStyle(context, 12),
  //     iconSize: deviceFontSize(context, 30),
  //     selectedIconTheme: IconThemeData(size: deviceFontSize(context, 32)),
  //     unselectedItemColor: AppTheme.black.withOpacity(0.5),
  //     items: pages
  //         .map(
  //           (e) => BottomNavigationBarItem(
  //             icon: Padding(
  //               padding: EdgeInsets.only(
  //                 top: deviceHeightSize(context, 10),
  //                 bottom: deviceHeightSize(context, 1),
  //               ),
  //               child: e.icon,
  //             ),
  //             label: e.title,
  //             activeIcon: Padding(
  //               padding: EdgeInsets.only(
  //                 top: deviceHeightSize(context, 10),
  //                 bottom: deviceHeightSize(context, 5),
  //               ),
  //               child: e.selectedIcon,
  //             ),
  //           ),
  //         )
  //         .toList(),
  //   );
  // }
}
