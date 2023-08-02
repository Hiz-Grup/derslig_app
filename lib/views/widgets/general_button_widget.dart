import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:flutter/material.dart';

class GeneralButtonWidget extends StatelessWidget {
  const GeneralButtonWidget({
    Key? key,
    required this.onPressed,
    required this.text,
    this.buttonColor = const Color(0xFF2DB1B8),
    this.textColor = const Color(0xFFFFFFFF),
    this.isLoading = false,
  }) : super(key: key);
  final Function()? onPressed;
  final Color? buttonColor;
  final String text;
  final Color? textColor;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: deviceWidth(context),
      height: deviceHeightSize(context, 52),
      child: MaterialButton(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        color: buttonColor,
        elevation: 0,
        onPressed: onPressed,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: AppTheme.blackTextStyle(context, 16,
                    color: textColor ?? Colors.white),
              ),
      ),
    );
  }
}
