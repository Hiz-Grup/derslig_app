import 'package:derslig/constants/size.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF616160);
  static const Color blue = Color(0xFF2DB1B8);
  static const Color pink = Color(0xFFE40169);
  static const Color red = Color(0xFFE40169);
  static const Color yellow = Color(0xFFFCD638);

  static const appFontFamily = 'Nunito';

  static TextStyle normalTextStyle(BuildContext context, double size,
          {Color color = black}) =>
      TextStyle(
        fontSize: deviceFontSize(context, size),
        fontFamily: appFontFamily,
        color: color,
      );
  static TextStyle lightTextStyle(BuildContext context, double size,
          {Color color = black}) =>
      TextStyle(
        fontSize: deviceFontSize(context, size),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w300,
        color: color,
      );
  static TextStyle boldTextStyle(BuildContext context, double size,
          {Color color = black}) =>
      TextStyle(
        fontSize: deviceFontSize(context, size),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.bold,
        color: color,
      );
  static TextStyle semiBoldTextStyle(BuildContext context, double size,
          {Color color = black}) =>
      TextStyle(
        fontSize: deviceFontSize(context, size),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w600,
        color: color,
      );
  static TextStyle extraBoldTextStyle(BuildContext context, double size,
          {Color color = black}) =>
      TextStyle(
        fontSize: deviceFontSize(context, size),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w800,
        color: color,
      );
  static TextStyle blackTextStyle(BuildContext context, double size,
          {Color color = black}) =>
      TextStyle(
        fontSize: deviceFontSize(context, size),
        fontFamily: appFontFamily,
        fontWeight: FontWeight.w900,
        color: color,
      );

  static List<BoxShadow> shadowList = [
    BoxShadow(
      color: AppTheme.grey.withOpacity(0.2),
      blurRadius: 11,
      offset: const Offset(0, 5),
    ),
  ];

  static InputDecoration borderInputDecoration({String? hintText}) =>
      InputDecoration(
        hintText: hintText,
        fillColor: blue.withOpacity(0.2),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: black.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: black.withOpacity(0.3),
          ),
        ),
      );

  static InputDecoration noneBorderInputDecoration({String? hintText}) =>
      InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
      );
}
