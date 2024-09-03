import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/models/onboarding_model.dart';
import 'package:derslig/views/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);
  static const String routeName = '/onboarding';
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Dijital Eğitim Platformu',
      description:
          'En çok çalışılması gereken konulara odaklanın, hızlı bir şekilde net ve puan artışı sağlayın.',
      image: "assets/images/onboarding-1.png",
    ),
    OnboardingModel(
      title: 'İnteraktif Animasyonlu Konu Anlatımları',
      description: 'Derslig Pro ile etkileşimli öğrenme deneyimini yaşayın.',
      image: "assets/images/onboarding-2.png",
    ),
    OnboardingModel(
      title: 'Başarı Sıralamanı Anında Öğren',
      description:
          'Genel katılımlı deneme sınavlarına istediğin zaman katılabilir ve binlerce kişi arasındaki sıralamanı anında öğrenebilirsin.',
      image: "assets/images/onboarding-3.png",
    ),
  ];

  int currentIndex = 0;

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (value) => setState(() {
                currentIndex = value;
              }),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: deviceTopPadding(context)),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: deviceWidthSize(context, 20)),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                "assets/images/derslig-logo.svg",
                                width: deviceWidthSize(context, 150),
                                color: AppTheme.pink,
                              ),
                              Expanded(
                                child: Image.asset(
                                  pages[index].image,
                                  height: deviceHeightSize(context, 300),
                                  width: deviceWidthSize(context, 300),
                                ),
                              ),
                              SizedBox(height: deviceHeightSize(context, 20)),
                              Text(
                                pages[index].title,
                                textAlign: TextAlign.center,
                                style: AppTheme.semiBoldTextStyle(context, 24),
                              ),
                              SizedBox(height: deviceHeightSize(context, 4)),
                              Text(
                                pages[index].description,
                                textAlign: TextAlign.center,
                                style: AppTheme.lightTextStyle(context, 20),
                              ),
                              SizedBox(height: deviceHeightSize(context, 20)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: deviceWidthSize(context, 30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => buildDot(index: index),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (currentIndex != pages.length - 1) {
                      setState(() {
                        currentIndex++;
                        _pageController.animateToPage(
                          currentIndex,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        );
                      });
                    } else {
                      Navigator.pushReplacementNamed(
                          context, SplashPage.routeName);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Devam Et",
                        style: AppTheme.semiBoldTextStyle(context, 24).copyWith(
                          height: 1.5,
                        ),
                      ),
                      SizedBox(width: deviceWidthSize(context, 10)),
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.black,
                        size: deviceWidthSize(context, 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: deviceHeightSize(context, 50)),
        ],
      ),
    );
  }

  buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: deviceWidthSize(context, 5)),
      height: deviceHeightSize(context, 10),
      width: deviceWidthSize(context, currentIndex == index ? 20 : 10),
      decoration: BoxDecoration(
        color: currentIndex == index ? AppTheme.pink : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
