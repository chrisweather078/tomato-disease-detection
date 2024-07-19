import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './home_page.dart';

class IntroScreen extends StatelessWidget {
  IntroScreen({super.key});

  final List<PageViewModel> pages = [
    PageViewModel(
        title: 'Welcome!',
        body:
            'Tomato Clinic will assist you to detect leaf diseases in tomato plants\n Hop on!',
        image: Center(
          child: Image.asset('assets/logo-no.png', fit: BoxFit.cover),
        ),
        decoration: const PageDecoration(
            titleTextStyle: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ))),
    PageViewModel(
        title: 'Step 1',
        body:
            'Use the buttons to take a picture or upload from gallery\n Use the detect button to begin scanning for diseases',
        image: Center(
          child: Image.asset('assets/step_2.png'),
        ),
        decoration: const PageDecoration(
            titleTextStyle: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ))),
    PageViewModel(
        title: 'Step 2',
        body:
            'Long press on the detect button to show color codes after detection\nThats it!\n Have fun, Learn, Enjoy! ',
        image: Center(
          child: Image.asset('assets/color_code.png'),
        ),
        decoration: const PageDecoration(
            titleTextStyle: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 80, 12, 12),
        child: IntroductionScreen(
          pages: pages,
          dotsDecorator: const DotsDecorator(
            size: Size(15, 15),
            color: Color(0xFF4D8C57),
            activeSize: Size.square(20),
            activeColor: Color(0xFF4D8C57),
          ),
          showDoneButton: true,
          done: const Text(
            'Done',
            style: TextStyle(fontSize: 20, color: Color(0xFF4D8C57)),
          ),
          showSkipButton: true,
          skip: const Text(
            'Skip',
            style: TextStyle(fontSize: 20, color: Color(0xFF4D8C57)),
          ),
          showNextButton: true,
          next: const Icon(
            Icons.arrow_forward,
            size: 25,
            color: Color(0xFF4D8C57),
          ),
          onDone: () => onDone(context),
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  void onDone(context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ON_BOARDING', false); // change to false
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }
}
