import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget(
    BuildContext context, {
    super.key,
    required this.controller,
    required this.title,
    this.inputFormatters,
    this.validator,
    this.fontSize = 12,
    this.hintText = "",
    this.isRequired = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.isNumber = false,
    this.ontap,
    this.leading = const SizedBox(),
  });
  final TextEditingController controller;
  final String title;
  final Widget leading;
  final String hintText;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int minLines;
  final Function()? ontap;
  final String? Function(String?)? validator;
  final bool isNumber;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != "")
          Row(
            children: [
              Text(
                title,
                style: AppTheme.semiBoldTextStyle(context, 16),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: AppTheme.semiBoldTextStyle(context, 16,
                      color: AppTheme.red),
                ),
            ],
          ),
        SizedBox(height: deviceHeightSize(context, 10)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: deviceWidthSize(context, 10),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.black.withOpacity(0.1))),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: deviceHeightSize(context, 2)),
                child: leading,
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  onTap: ontap,
                  maxLines: maxLines,
                  minLines: minLines,
                  cursorColor: AppTheme.black,
                  textInputAction: maxLines > 2
                      ? TextInputAction.newline
                      : TextInputAction.done,
                  style: AppTheme.normalTextStyle(context, fontSize),
                  validator: validator,
                  inputFormatters: inputFormatters,
                  decoration: AppTheme.noneBorderInputDecoration(
                    hintText: hintText,
                  ),
                  keyboardType: isNumber ? TextInputType.number : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
