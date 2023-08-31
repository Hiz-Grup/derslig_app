import 'dart:developer';

import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/views/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  List<WebViewCookie> cookies = [];

  @override
  void initState() {
    // SchedulerBinding.instance.addPostFrameCallback((_) async {
    LoginResponseModel? loginResponseModel = HiveHelpers.getLoginModel();
    if (loginResponseModel == null) {
      HiveHelpers.saveUserStatus(false);
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   SplashPage.routeName,
      //   (route) => false,
      // );
    } else {
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
    }
    cookies.add(const WebViewCookie(
        name: "derslig_webview", value: "1", domain: "derslig.com"));

    controller = WebViewController()
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
              return NavigationDecision.navigate;
            } else if (request.url.contains("https://www.derslig.com/pro")) {
              context.read<PageProvider>().currentIndex = 2;
              //dont navigate to url
              return NavigationDecision.prevent;
            } else if (request.url.contains("https://www.derslig.com/cikis")) {
              HiveHelpers.logout();
              // Navigator.pushNamedAndRemoveUntil(
              //   context,
              //   SplashPage.routeName,
              //   (route) => false,
              // );
              return NavigationDecision.navigate;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {
          "Cookie": cookies.map((e) => "${e.name}=${e.value}").join("; "),
        },
      );

    //get cooikes
    controller.runJavaScriptReturningResult("document.cookie").then((value) {
      print("document.cookie: $value");
    });
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.runJavaScriptReturningResult("document.cookie").then((value) {
      log("document.cookie: $value");
    });
    if (context.read<LoginRegisterPageProvider>().loginRoute == true &&
        url == "https://www.derslig.com/ogrenci") {
      controller.runJavaScriptReturningResult("document.cookie").then((value) {
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
      });
      context.read<LoginRegisterPageProvider>().loginRoute = false;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   onPressed: () async {
      //     if (await controller.canGoBack()) {
      //       controller.goBack();
      //     } else {
      //       SystemNavigator.pop();
      //     }
      //   },
      //   child: BackButtonWidget(
      //     onPressed: () async {
      //       if (await controller.canGoBack()) {
      //         controller.goBack();
      //       } else {
      //         SystemNavigator.pop();
      //       }
      //     },
      //   ),
      // ),
      body: Column(
        children: [
          Container(height: deviceTopPadding(context), color: AppTheme.blue),
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
