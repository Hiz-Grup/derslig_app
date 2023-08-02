import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:flutter/material.dart';

class DropdownWidget extends StatelessWidget {
  const DropdownWidget(
    BuildContext context, {
    required this.titles,
    this.title,
    required this.selectedIndex,
    this.onChanged,
    this.isRequired = false,
    this.hintText = "Seçiniz",
    this.color = const Color(0xFFFFFFFF),
    this.isBold = false,
    Key? key,
  }) : super(key: key);
  final List<String>? titles;
  final String? title;
  final int selectedIndex;
  final Function(String?)? onChanged;
  final bool isRequired;
  final String hintText;
  final Color? color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> items = [];
    for (var item in titles ?? []) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: AppTheme.normalTextStyle(
              context,
              16,
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null
            ? Row(
                children: [
                  Text(
                    title ?? "",
                    style: AppTheme.semiBoldTextStyle(context, 16),
                  ),
                  if (isRequired)
                    Text(
                      " *",
                      style: AppTheme.semiBoldTextStyle(context, 16,
                          color: AppTheme.red),
                    ),
                ],
              )
            : Container(),
        SizedBox(height: deviceHeightSize(context, 10)),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color,
              border: Border.all(color: AppTheme.black.withOpacity(0.1))),
          padding: EdgeInsets.symmetric(
              horizontal: deviceWidthSize(context, 20),
              vertical: deviceHeightSize(context, 5)),
          width: double.infinity,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              alignment: Alignment.centerLeft,
              dropdownColor: color,
              borderRadius: BorderRadius.circular(10),
              focusColor: color,
              menuMaxHeight: deviceHeightSize(context, 400),
              style: isBold
                  ? AppTheme.semiBoldTextStyle(
                      context,
                      16,
                    )
                  : AppTheme.normalTextStyle(
                      context,
                      16,
                    ),
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppTheme.black,
              ),
              items: items,
              onChanged: onChanged,
              value: selectedIndex == -1 ? null : items[selectedIndex].value,
              hint: Text(
                hintText,
                style: AppTheme.normalTextStyle(context, 12,
                    color: AppTheme.black.withOpacity(0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
