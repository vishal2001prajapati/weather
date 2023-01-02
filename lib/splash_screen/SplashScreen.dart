import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:weather/home_screen/Home_Screen.dart';
import 'package:weather/introscreen/InstroScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int? isViewed;
  @override
  void initState()  {
    super.initState();
    _getData();

  }

  _getData() {
    GetStorage box = GetStorage();
    isViewed = box.read('onBoard');
    print("Is Viewdddd $isViewed");

     Timer(
        const Duration(seconds: 3),
            () => isViewed != 0
                ? Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => IntroScreen()))
        : Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomeScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset("assets/images/splash_screen.png", fit: BoxFit.fill),
      ),
    );
  }
}
