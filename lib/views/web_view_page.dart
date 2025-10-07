import 'dart:developer';

import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/page_model.dart';
import 'package:derslig/models/user_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/views/derslig_pro_page.dart';
import 'package:derslig/views/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

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
  bool isLoggedIn = false;

  List<WebViewCookie> cookies = [];
  List<PageModel> pages = [];

  @override
  void initState() {
    //SECTION - WebView

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    cookies.add(const WebViewCookie(
        name: "derslig_webview", value: "1", domain: ".derslig.com"));
    cookies.add(const WebViewCookie(
        name: "derslig_app_version", value: "1", domain: ".derslig.com"));
    cookies.add(const WebViewCookie(
        name: "cookieBarOK", value: "1", domain: ".derslig.com"));

    setWebViewController(params);
    
    // Login durumunu kontrol et
    LoginResponseModel? loginModel = HiveHelpers.getLoginModel();
    if (loginModel != null) {
      isLoggedIn = true;
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    LoginResponseModel? loginResponseModel = HiveHelpers.getLoginModel();
    
    // Login durumunu güncelle
    if (loginResponseModel != null && !isLoggedIn) {
      print("Login modeli bulundu, isLoggedIn true yapılıyor");
      setState(() {
        isLoggedIn = true;
      });
    } else if (loginResponseModel == null && isLoggedIn) {
      print("Login modeli bulunamadı, isLoggedIn false yapılıyor");
      setState(() {
        isLoggedIn = false;
      });
    }
    
    print("Build - isLoggedIn: $isLoggedIn, loginModel: ${loginResponseModel != null}");

    if (loginResponseModel == null) {
      HiveHelpers.saveUserStatus(false);
      setState(() {
        isLoggedIn = false;
      });
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   SplashPage.routeName,
      //   (route) => false,
      // );
    } else if (isWork == false) {
      // Login durumunu doğru şekilde set et
      HiveHelpers.saveUserStatus(true);
      setState(() {
        isLoggedIn = true;
      });
      
      cookies = [
        WebViewCookie(
          name: "XSRF-TOKEN",
          value: loginResponseModel.xsrfToken,
          domain: ".derslig.com",
          path: "/",
        ),
        WebViewCookie(
          name: "derslig_cookie",
          value: loginResponseModel.dersligCookie,
          domain: ".derslig.com",
          path: "/",
        ),
      ];
      cookies.add(const WebViewCookie(
          name: "derslig_webview", value: "1", domain: ".derslig.com"));
      cookies.add(const WebViewCookie(
          name: "derslig_app_version", value: "1", domain: ".derslig.com"));
      cookies.add(const WebViewCookie(
          name: "cookieBarOK", value: "1", domain: ".derslig.com"));

      // Modern webview_flutter ile cookie'leri header olarak gönderme
      controller.loadRequest(
        Uri.parse(widget.url),
        headers: {
          "Cookie": cookies.map((e) => "${e.name}=${e.value}").join("; "),
          "User-Agent": "DersligMobileApp/1.0",
        },
      );
      isWork = true;
    }

    // log("loginRoute: ${context.read<LoginRegisterPageProvider>().loginRoute}");
    // log("url: $url");

    if (context.read<LoginRegisterPageProvider>().loginRoute == true &&
        url == "https://www.derslig.com/ogrenci") {
      print("Login route aktif, öğrenci sayfasına yönlendirildi");
      
      LoginResponseModel? existingModel = HiveHelpers.getLoginModel();
      if (existingModel != null) {
        print("Mevcut login modeli bulundu, login durumu güncelleniyor");
        HiveHelpers.saveUserStatus(true);
        setState(() {
          isLoggedIn = true;
        });
      } else {
        LoginResponseModel dummyModel = LoginResponseModel(
          xsrfToken: "dummy_token_${DateTime.now().millisecondsSinceEpoch}",
          dersligCookie: "dummy_cookie_${DateTime.now().millisecondsSinceEpoch}",
          expireDate: DateTime.now().add(const Duration(days: 60)),
        );
        HiveHelpers.saveLoginModel(dummyModel);
        HiveHelpers.saveUserStatus(true);
        setState(() {
          isLoggedIn = true;
        });
      }
      
      context.read<LoginRegisterPageProvider>().controlUser().then(
        (value) {
          oneSignalTags();
        },
      );
      context.read<LoginRegisterPageProvider>().loginRoute = false;
    }

    setPages(context);
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: deviceHeight(context) > 500 && isLoggedIn
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
          if (context.watch<LoginRegisterPageProvider>().isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.pink,
              ),
            ),
        ],
        ),
      ),
    );
  }

  void setPages(BuildContext context) {
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
  }

  BottomNavigationBar bottomNavigation() {
    return BottomNavigationBar(
      onTap: (index) {
        context.read<PageProvider>().currentIndex = index;
        print("index: $index");
        if (pages[index].title != "Derslig Pro") {
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

  void setWebViewController(PlatformWebViewControllerCreationParams params) {
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
            context.read<LoginRegisterPageProvider>().isLoading = false;
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
            context.read<LoginRegisterPageProvider>().isLoading = true;
            setState(() {
              url = request.url;
            });

            // if (request.url.contains("?user_signed_in") ||
            //     request.url.contains("?user_signed_up")) {
            if (request.url.contains("https://www.derslig.com/giris") ||
                request.url.contains("https://www.derslig.com/kayit")) {
              context.read<LoginRegisterPageProvider>().loginRoute = true;
            }
            // }

            return controlRoutes(request);
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  NavigationDecision controlRoutes(NavigationRequest request) {
    if (request.url.contains("https://www.derslig.com/profilim")) {
      context.read<PageProvider>().currentIndex = 1;
      return NavigationDecision.navigate;
    } else if (request.url.contains("https://www.derslig.com/dersler")) {
      context.read<PageProvider>().currentIndex = pages.length - 1;
      return NavigationDecision.navigate;
    } else if (request.url == "https://www.derslig.com/ogrenci") {
      context.read<PageProvider>().currentIndex = 0;
      return NavigationDecision.navigate;
    } else if (request.url == "https://www.derslig.com/pro" ||
        request.url.contains("https://www.derslig.com/siparis")) {
      if (isLoggedIn || context.read<LoginRegisterPageProvider>().isLogin) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DersligProPage(),
            fullscreenDialog: true,
          ),
        );
        //dont navigate to url
        return NavigationDecision.prevent;
      } else {
        return NavigationDecision.navigate;
      }
    } else if (request.url.contains("https://www.derslig.com/cikis")) {
      HiveHelpers.logout(context);
      setState(() {
        isLoggedIn = false;
      });

      return NavigationDecision.navigate;
    } else if (request.url.contains("https://www.derslig.com/kurumsal") ||
        request.url.contains("https://www.derslig.com/pro/lgs") ||
        request.url.contains("https://www.derslig.com/pro/yks")) {
      return NavigationDecision.prevent;
    } else {
      return NavigationDecision.navigate;
    }
  }

  Future<void> oneSignalTags() async {
    if (context.read<LoginRegisterPageProvider>().isLogin) {
      UserModel userModel =
          context.read<LoginRegisterPageProvider>().userModel!;
      bool isPro = userModel.isPremium == 1;
      int userClass = userModel.gradeId ?? 0;

      await OneSignal.login(userModel.id.toString());
      String phone = (userModel.phone ?? "")
          .replaceAll("+9", "")
          .replaceAll(" ", "")
          .replaceAll("(", "")
          .replaceAll(")", "")
          .replaceAll("-", "");
      if (phone.length == 10) {
        phone = "0$phone";
      }
      phone = "+9$phone";
      log("phone: $phone");
      OneSignal.User.addSms(phone);
      OneSignal.User.addEmail(userModel.email ?? "");
      OneSignal.User.removeTags(["class", "isPremium"]);
      OneSignal.User.addTagWithKey("class", userClass);
      OneSignal.User.addTagWithKey("isPremium", isPro.toString());
    }
  }
}
