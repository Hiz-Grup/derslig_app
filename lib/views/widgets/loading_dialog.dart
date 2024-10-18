import 'package:derslig/constants/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  final BuildContext context;
  LoadingDialog(this.context);

  bool isShowing = false;

  Future<void> show() {
    isShowing = true;
    return showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.pink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dismiss() {
    if (isShowing) {
      isShowing = false;
      Navigator.of(context).pop();
    }
  }
}
