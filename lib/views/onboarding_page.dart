import 'package:derslig/constants/app_theme.dart';
import 'package:derslig/constants/size.dart';
import 'package:derslig/models/onboarding_model.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);
  static const String routeName = '/onboarding';
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Derslig',
      image: const Icon(Icons.ac_unit),
    ),
    OnboardingModel(
      title: 'Derslig',
      image: const Icon(Icons.ac_unit),
    ),
    OnboardingModel(
      title: 'Derslig',
      image: const Icon(Icons.ac_unit),
    ),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
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
                        child: Column(
                          children: [
                            pages[index].image,
                            const Spacer(),
                            Text(
                              pages[index].title,
                              textAlign: TextAlign.center,
                              style: AppTheme.semiBoldTextStyle(context, 24),
                            ),
                            const Spacer(),
                            SizedBox(height: deviceHeightSize(context, 20)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => buildDot(index: index),
            ),
          ),
          SizedBox(height: deviceHeightSize(context, 20)),
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
        color: currentIndex == index ? AppTheme.blue : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
