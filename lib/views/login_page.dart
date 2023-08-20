import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/views/home_page.dart';
import 'package:derslig/views/register_page.dart';
import 'package:derslig/views/widgets/form_field_widget.dart';
import 'package:derslig/views/widgets/general_button_widget.dart';
import 'package:derslig/views/widgets/toast_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const String routeName = '/login';
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController(text: "ahmetozdemir@derslig.com");
  final TextEditingController _passwordController =
      TextEditingController(text: "12345611");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            text: ' giriş yap!',
                            style: AppTheme.boldTextStyle(context, 24,
                                color: AppTheme.black.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Öğrenci veya Öğretmen hesabınız ile giriş yapabilirsiniz.',
                      style: AppTheme.normalTextStyle(context, 12,
                          color: AppTheme.black.withOpacity(0.6)),
                    ),
                    SizedBox(height: deviceHeightSize(context, 10)),
                    FormFieldWidget(
                      context,
                      controller: _emailController,
                      title: "",
                      leading: Icon(
                        Icons.person_rounded,
                        color: AppTheme.black.withOpacity(0.6),
                        size: deviceFontSize(context, 18),
                      ),
                      hintText: "E-posta adresi veya T.C. Kimlik Numarası",
                    ),
                    FormFieldWidget(
                      context,
                      controller: _passwordController,
                      title: "",
                      leading: Icon(
                        Icons.lock_rounded,
                        color: AppTheme.black.withOpacity(0.6),
                        size: deviceFontSize(context, 18),
                      ),
                      hintText: "Şifre",
                    ),
                    SizedBox(height: deviceHeightSize(context, 10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Şifremi Unuttum',
                            style: AppTheme.normalTextStyle(context, 14,
                                    color: AppTheme.black.withOpacity(0.6))
                                .copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: deviceHeightSize(context, 20)),
                    GeneralButtonWidget(
                      text: "Giriş Yap",
                      onPressed: () async {
                        LoginResponseModel? model = await context
                            .read<LoginRegisterPageProvider>()
                            .login(
                              _emailController.text,
                              _passwordController.text,
                            );

                        if (model != null) {
                          Navigator.pushNamed(context, HomePage.routeName);
                        } else {
                          ToastWidgets.errorToast(context, "Giriş Yapılamadı!");
                        }
                      },
                    ),
                    SizedBox(height: deviceHeightSize(context, 8)),
                    Divider(
                      color: AppTheme.black.withOpacity(0.1),
                      thickness: 1,
                    ),
                    SizedBox(height: deviceHeightSize(context, 8)),
                    GeneralButtonWidget(
                      text: "Ücretsiz Üye Ol",
                      onPressed: () {
                        Navigator.pushNamed(context, RegisterPage.routeName);
                      },
                      buttonColor: AppTheme.red,
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
