import 'dart:developer';
import 'dart:io';

import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/page_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/views/back_button_widget.dart';
import 'package:derslig/views/derslig_pro_page.dart';
import 'package:derslig/views/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key, this.url = "https://www.derslig.com/giris"})
      : super(key: key);
  final String url;
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController controller = WebViewController();
  String url = "";
  bool isWork = false;

  List<WebViewCookie> cookies = [];
  List<PageModel> pages = [];

  @override
  void initState() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    // SchedulerBinding.instance.addPostFrameCallback((_) async {
    cookies.add(const WebViewCookie(
        name: "derslig_webview", value: "1", domain: "derslig.com"));
    cookies.add(const WebViewCookie(
        name: "cookieBarOK", value: "1", domain: "derslig.com"));

    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            // print("onPageStarted: $url");
          },
          onPageFinished: (String url) {
            // print("onPageFinished: $url");
          },
          onWebResourceError: (WebResourceError error) async {
            // Handle error.
            print("error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) async {
            print("request.url: ${request.url}");

            InternetConnectionChecker().hasConnection.then((isDeviceConnected) {
              if (isDeviceConnected == false) {
                Future.delayed(const Duration(seconds: 1)).then(
                  (value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const NoInternetWidget(),
                    ),
                  ),
                );
              }
            });

            setState(() {
              url = request.url;
            });

            if (request.url.contains("?user_signed_in") ||
                request.url.contains("?user_signed_up")) {
              context.read<LoginRegisterPageProvider>().loginRoute = true;
            }

            if (request.url.contains("https://www.derslig.com/profilim")) {
              context.read<PageProvider>().currentIndex = 1;
              return NavigationDecision.navigate;
            } else if (request.url == "https://www.derslig.com/pro" ||
                request.url.contains("https://www.derslig.com/siparis")) {
              if (context.read<LoginRegisterPageProvider>().isLogin)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DersligProPage(),
                    fullscreenDialog: true,
                  ),
                );
              //dont navigate to url
              return NavigationDecision.prevent;
            } else if (request.url.contains("https://www.derslig.com/cikis")) {
              HiveHelpers.logout(context);

              return NavigationDecision.navigate;
            } else if (request.url
                    .contains("https://www.derslig.com/kurumsal") ||
                request.url.contains("https://www.derslig.com/blog") ||
                request.url.contains("https://www.derslig.com/yardim") ||
                request.url.contains("https://www.derslig.com/pro/lgs") ||
                request.url.contains("https://www.derslig.com/pro/yks")) {
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );

    List<Cookie> cookieList = cookies
        .map((e) => Cookie(
              e.name,
              e.value,
            )
              ..expires = DateTime.now().add(const Duration(days: 365 * 5))
              ..httpOnly = false)
        .toList();
    cookieManager.setCookies(
      cookieList,
      origin: 'https://.derslig.com',
    );

    controller.enableZoom(false);

    super.initState();
  }

  final cookieManager = WebviewCookieManager();
  @override
  Widget build(BuildContext context) {
    LoginResponseModel? loginResponseModel = HiveHelpers.getLoginModel();

    if (loginResponseModel == null) {
      HiveHelpers.saveUserStatus(false);
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   SplashPage.routeName,
      //   (route) => false,
      // );
    } else if (isWork == false) {
      cookies = [
        WebViewCookie(
          name: "XSRF-TOKEN",
          value: loginResponseModel.xsrfToken,
          domain: "derslig.com",
          path: "/",
        ),
        WebViewCookie(
          name: "derslig_cookie",
          value: loginResponseModel.dersligCookie,
          domain: "derslig.com",
          path: "/",
        ),
      ];
      cookies.add(const WebViewCookie(
          name: "derslig_webview", value: "1", domain: "derslig.com"));
      cookies.add(const WebViewCookie(
          name: "cookieBarOK", value: "1", domain: "derslig.com"));

      // controller.loadRequest(
      //   Uri.parse(widget.url),
      //   headers: {
      //     "Cookie": cookies.map((e) => "${e.name}=${e.value}").join("; "),
      //   },
      // );
      List<Cookie> cookieList = cookies
          .map((e) => Cookie(
                e.name,
                e.value,
              )
                ..expires = DateTime.now().add(const Duration(days: 365 * 5))
                ..httpOnly = false)
          .toList();
      cookieManager.setCookies(
        cookieList,
        origin: 'https://.derslig.com',
      );
      isWork = true;
    }
    cookieManager.getCookies('https://derslig.com').then((value) {
      // log("document.cookie:");
      // value.forEach((element) {
      //   print("element: $element");
      // });
    });

    if (context.read<LoginRegisterPageProvider>().loginRoute == true &&
        url == "https://www.derslig.com/ogrenci") {
      cookieManager.getCookies('https://derslig.com').then((value) {
        log("document.cookie: $value");
        RegExp regExpXsrg = RegExp(r'XSRF-TOKEN=(.*?);');
        String xsrfToken = regExpXsrg.firstMatch(value.toString())!.group(1)!;
        RegExp regExpDersligCookie = RegExp(r'derslig_cookie=(.*?);');
        String dersligCookie =
            regExpDersligCookie.firstMatch(value.toString())!.group(1)!;
        LoginResponseModel loginResponseModel = LoginResponseModel(
          xsrfToken: xsrfToken,
          dersligCookie: dersligCookie,
          expireDate: DateTime.now().add(const Duration(days: 60)),
        );
        HiveHelpers.saveLoginModel(loginResponseModel);
        context.read<LoginRegisterPageProvider>().controlUser();
      });
      context.read<LoginRegisterPageProvider>().loginRoute = false;
    }

    pages = [
      PageModel(
        title: "Ana Sayfa",
        icon: const Icon(Icons.home_rounded),
        selectedIcon: const Icon(Icons.home_rounded),
        url: "https://www.derslig.com/",
      ),
      PageModel(
        title: "Profilim",
        icon: const Icon(Icons.person_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        url: "https://www.derslig.com/profilim",
      ),
      if ((context.watch<LoginRegisterPageProvider>().userModel?.isPremium !=
              1 &&
          context.watch<LoginRegisterPageProvider>().userModel?.type != 1))
        PageModel(
          title: "Derslig Pro",
          icon: const Icon(Icons.workspace_premium_rounded),
          selectedIcon: const Icon(Icons.workspace_premium_rounded),
          url: "https://www.derslig.com/",
        ),
      PageModel(
        title: "Dersler",
        icon: const Icon(Icons.menu_book_rounded),
        selectedIcon: const Icon(Icons.menu_book_rounded),
        url: "https://www.derslig.com/dersler",
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: context.watch<LoginRegisterPageProvider>().isLogin &&
              deviceHeight(context) > 500
          ? bottomNavigation()
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                  height: deviceTopPadding(context), color: AppTheme.blue),
              Expanded(
                child: WebViewWidget(
                  controller: controller,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                if (await controller.canGoBack()) {
                  controller.goBack();
                } else {
                  SystemNavigator.pop();
                }
              },
              child: BackButtonWidget(
                onPressed: () async {
                  if (await controller.canGoBack()) {
                    controller.goBack();
                  } else {
                    SystemNavigator.pop();
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  BottomNavigationBar bottomNavigation() {
    return BottomNavigationBar(
      onTap: (index) {
        context.read<PageProvider>().currentIndex = index;
        print("index: $index");
        if (index != 2) {
          context.read<PageProvider>().pageIndex = 0;
          print("pages[index].url: ${pages[index].url}");
          controller.loadRequest(
            Uri.parse(pages[index].url),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DersligProPage(),
              fullscreenDialog: true,
            ),
          );
          context.read<PageProvider>().pageIndex = 2;
        }
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
