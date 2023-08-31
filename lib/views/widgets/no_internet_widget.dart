import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/views/widgets/general_button_widget.dart';
import 'package:derslig/views/widgets/toast_widgets.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NoInternetWidget extends StatefulWidget {
  const NoInternetWidget({Key? key}) : super(key: key);

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: SizedBox(
          height: deviceHeight(context),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: deviceWidthSize(context, 24)),
            child: Column(
              children: [
                const Spacer(),
                Icon(
                  Icons.signal_wifi_connected_no_internet_4_rounded,
                  size: deviceFontSize(context, 180),
                  color: AppTheme.pink,
                ),
                SizedBox(
                  height: deviceHeightSize(context, 10),
                ),
                Text(
                  "Lütfen internet bağlantınızı kontrol edin.",
                  textAlign: TextAlign.center,
                  style: AppTheme.semiBoldTextStyle(context, 30),
                ),
                const Spacer(),
                GeneralButtonWidget(
                  onPressed: () async {
                    final isDeviceConnected =
                        await InternetConnectionChecker().hasConnection;
                    if (isDeviceConnected) {
                      Navigator.pop(context);
                    } else {
                      ToastWidgets.errorToast(
                          context, "İnternet bağlantısı yok!");
                    }
                  },
                  text: "Tekrar Dene",
                ),
                SizedBox(
                  height: deviceHeightSize(context, 30),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
