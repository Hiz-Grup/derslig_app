import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/views/login_page.dart';
import 'package:derslig/views/widgets/dropdown_widget.dart';
import 'package:derslig/views/widgets/form_field_widget.dart';
import 'package:derslig/views/widgets/general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  static const String routeName = '/register';
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<String> schoolLevels = ["İlkokul", "Ortaokul", "Lise"];
  //ilkokul
  List<String> primarySchoolClasses = [
    "1. Sınıf",
    "2. Sınıf",
    "3. Sınıf",
    "4. Sınıf"
  ];

  //ortaokul
  List<String> middleSchoolClasses = [
    "5. Sınıf",
    "6. Sınıf",
    "7. Sınıf",
    "8. Sınıf"
  ];

  //lise
  List<String> highSchoolClasses = [
    "9. Sınıf",
    "10. Sınıf",
    "11. Sınıf",
    "12. Sınıf"
  ];

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: deviceHeightSize(context, 400),
                width: double.infinity,
                padding: EdgeInsets.only(
                  top:
                      deviceHeightSize(context, 30) + deviceTopPadding(context),
                  left: deviceWidthSize(context, 20),
                  right: deviceWidthSize(context, 20),
                  bottom: deviceHeightSize(context, 30),
                ),
                color: AppTheme.blue,
                child: Image.asset(
                  'assets/images/login.webp',
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: deviceWidthSize(context, 20),
                  vertical: deviceHeightSize(context, 10),
                ),
                child: Column(
                  children: [
                    SizedBox(height: deviceHeightSize(context, 20)),
                    RichText(
                      text: TextSpan(
                        text: "Derslig'e",
                        style: AppTheme.boldTextStyle(context, 24,
                            color: AppTheme.blue),
                        children: [
                          TextSpan(
                            text: ' Üye Ol!',
                            style: AppTheme.boldTextStyle(context, 24,
                                color: AppTheme.black.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Öğrenci ve öğretmen üyeliği ücretsizdir.',
                      style: AppTheme.normalTextStyle(context, 12,
                          color: AppTheme.black.withOpacity(0.6)),
                    ),
                    SizedBox(height: deviceHeightSize(context, 10)),
                    DropdownWidget(
                      context,
                      titles: schoolLevels,
                      hintText: "Okul Düzeyi Seçin",
                      selectedIndex: context
                          .watch<LoginRegisterPageProvider>()
                          .schoolLevelIndex,
                      onChanged: (value) {
                        context
                                .read<LoginRegisterPageProvider>()
                                .schoolLevelIndex =
                            schoolLevels.indexOf(value ?? "");
                        context
                            .read<LoginRegisterPageProvider>()
                            .schoolClassIndex = -1;
                      },
                    ),
                    DropdownWidget(
                      context,
                      titles: context
                                  .watch<LoginRegisterPageProvider>()
                                  .schoolLevelIndex ==
                              0
                          ? primarySchoolClasses
                          : context
                                      .watch<LoginRegisterPageProvider>()
                                      .schoolLevelIndex ==
                                  1
                              ? middleSchoolClasses
                              : highSchoolClasses,
                      hintText: "2023-2024 Yılında Okuduğunuz Sınıfı Seçin",
                      selectedIndex: context
                          .watch<LoginRegisterPageProvider>()
                          .schoolClassIndex,
                      onChanged: (value) {
                        context
                            .read<LoginRegisterPageProvider>()
                            .schoolClassIndex = context
                                    .read<LoginRegisterPageProvider>()
                                    .schoolLevelIndex ==
                                0
                            ? primarySchoolClasses.indexOf(value ?? "")
                            : context
                                        .read<LoginRegisterPageProvider>()
                                        .schoolLevelIndex ==
                                    1
                                ? middleSchoolClasses.indexOf(value ?? "")
                                : highSchoolClasses.indexOf(value ?? "");
                      },
                    ),
                    FormFieldWidget(
                      context,
                      controller: _nameController,
                      title: "",
                      fontSize: 14,
                      hintText: "Ad",
                    ),
                    FormFieldWidget(
                      context,
                      controller: _surnameController,
                      title: "",
                      fontSize: 14,
                      hintText: "Soyad",
                    ),
                    FormFieldWidget(
                      context,
                      controller: _emailController,
                      title: "",
                      fontSize: 14,
                      hintText: "E-posta adresi",
                    ),
                    FormFieldWidget(
                      context,
                      controller: _passwordController,
                      title: "",
                      fontSize: 14,
                      hintText: "Şifre",
                    ),
                    FormFieldWidget(
                      context,
                      controller: _passwordController2,
                      title: "",
                      fontSize: 14,
                      hintText: "Şifre Tekrarı",
                    ),
                    SizedBox(height: deviceHeightSize(context, 20)),

                    //Çerez politikasını kabul ediyorum.
                    // KVKK aydınlatma metnini okudum ve kabul ediyorum.
                    Row(
                      children: [
                        Checkbox(
                          value: context
                              .watch<LoginRegisterPageProvider>()
                              .coockiePolicy,
                          onChanged: (value) {
                            context
                                .read<LoginRegisterPageProvider>()
                                .coockiePolicy = value;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(color: AppTheme.blue),
                          ),
                          activeColor: AppTheme.blue,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: RichText(
                              text: TextSpan(
                                text: "Çerez politikasını",
                                style: AppTheme.normalTextStyle(context, 14,
                                        color: AppTheme.blue.withOpacity(0.6))
                                    .copyWith(
                                        decoration: TextDecoration.underline),
                                children: [
                                  TextSpan(
                                    text: ' kabul ediyorum.',
                                    style: AppTheme.normalTextStyle(context, 14,
                                            color:
                                                AppTheme.black.withOpacity(0.6))
                                        .copyWith(
                                            decoration: TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: context
                              .watch<LoginRegisterPageProvider>()
                              .privacyPolicy,
                          onChanged: (value) {
                            context
                                .read<LoginRegisterPageProvider>()
                                .privacyPolicy = value;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(color: AppTheme.blue),
                          ),
                          activeColor: AppTheme.blue,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: RichText(
                              text: TextSpan(
                                text: "KVKK aydınlatma metnini",
                                style: AppTheme.normalTextStyle(context, 14,
                                        color: AppTheme.blue.withOpacity(0.6))
                                    .copyWith(
                                        decoration: TextDecoration.underline),
                                children: [
                                  TextSpan(
                                    text: ' okudum ve kabul ediyorum.',
                                    style: AppTheme.normalTextStyle(context, 14,
                                            color:
                                                AppTheme.black.withOpacity(0.6))
                                        .copyWith(
                                            decoration: TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: deviceHeightSize(context, 20)),
                    RichText(
                      text: TextSpan(
                        text: "Üyeliğiniz ",
                        style: AppTheme.semiBoldTextStyle(context, 14,
                                color: AppTheme.black.withOpacity(0.6))
                            .copyWith(fontStyle: FontStyle.italic),
                        children: [
                          TextSpan(
                            text: 'okulunuz tarafından tanımlanmış ise ',
                            style: AppTheme.semiBoldTextStyle(context, 14,
                                color: AppTheme.red),
                          ),
                          TextSpan(
                            text:
                                'tekrar üye olmanıza gerek yoktur. T.C. kimlik numaranız ve okulunuzun size ilettiği şifreniz ile giriş yapınız.',
                            style: AppTheme.semiBoldTextStyle(context, 14,
                                color: AppTheme.black.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: deviceHeightSize(context, 20)),
                    GeneralButtonWidget(
                      text: "Ücretsiz Üye Ol",
                      onPressed: () {},
                    ),
                    SizedBox(height: deviceHeightSize(context, 8)),
                    Divider(
                      color: AppTheme.black.withOpacity(0.1),
                      thickness: 1,
                    ),
                    SizedBox(height: deviceHeightSize(context, 8)),
                    GeneralButtonWidget(
                      text: "Giriş Yap",
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, LoginPage.routeName);
                      },
                      textColor: AppTheme.blue,
                      buttonColor: AppTheme.blue.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: deviceHeightSize(context, 20)),
            ],
          ),
        ),
      ),
    );
  }
}
