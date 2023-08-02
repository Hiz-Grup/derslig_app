import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:derslig/views/back_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key, this.url = "https://www.derslig.com/uyelik"})
      : super(key: key);
  final String url;
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController controller = WebViewController();

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            print("onPageStarted: $url");
          },
          onPageFinished: (String url) {
            print("onPageFinished: $url");
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error.
            print("error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) async {
            print("request.url: ${request.url}");
            if (request.url.contains("https://www.derslig.com/profilim")) {
              return NavigationDecision.navigate;
            } else if (request.url.contains("https://www.derslig.com/pro")) {
              context.read<PageProvider>().currentIndex = 2;
              //dont navigate to url
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
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
