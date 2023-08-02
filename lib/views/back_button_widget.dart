import 'package:derslig/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget(
      {Key? key,
      this.iconColor = const Color(0xFFE50069),
      this.backgroundColor = const Color(0xFF7E50069),
      this.onPressed})
      : super(key: key);
  final Color iconColor;
  final Color backgroundColor;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidthSize(context, 35),
      height: deviceHeightSize(context, 35),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        splashColor: iconColor.withOpacity(0.4),
        onTap: () {
          if (onPressed != null) {
            onPressed!();
          } else {
            SystemNavigator.pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 5.5),
          child: Icon(
            Icons.arrow_back_ios,
            color: iconColor,
            size: deviceFontSize(context, 16),
          ),
        ),
      ),
    );
  }
}
