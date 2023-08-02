import 'package:flutter/material.dart';

class PageModel {
  final String title;
  final Widget icon;
  final Widget selectedIcon;
  final Widget page;

  PageModel({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}
