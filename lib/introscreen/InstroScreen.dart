import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weather/home_screen/Home_Screen.dart';

import 'package:weather/utils/app_colors/AppColors.dart';
import 'package:weather/utils/const_string/const_string.dart';

import 'IntroScreenController.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageController controller = PageController();
  PageController _pageController = PageController();
  double initCount = 0.25;
  IntroScreenController welcomeController = Get.put(IntroScreenController());

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    controller.dispose();
  }

  _storeIntroInfo() {
    int isViewed = 0;
    GetStorage box = GetStorage();
    box.write('onBoard', isViewed);
    box.save();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryColor,
    ));
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(

        children: [
          Padding(
              padding: EdgeInsets.only(right: 10.w, top: 5.h),
              child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                      onPressed: () {
                        debugPrint('Skip Click');
                        _storeIntroInfo();
                          Get.off(const HomeScreen());
                      },
                      child: Text(Strings.skip,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ))))),
          SizedBox(
            height: 10.h,
          ),
          SizedBox(
            height: 200.h,
            child: PageView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              controller: controller,
              children: [
                Image.asset(
                  'assets/images/ic_moon.png',
                ),
                Image.asset(
                  'assets/images/ic_sun.png',
                ),
                Image.asset(
                  'assets/images/ic_weather.png',
                ),
                Image.asset(
                  'assets/images/ic_weather_sun.png',
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
              controller: controller,
              count: 4,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.linearColor,
                dotColor: Colors.white,
                dotHeight: 6.h,
                dotWidth: 6.w,
                spacing: 15,
              )),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Arc(
                arcType: ArcType.CONVEX,
                edge: Edge.TOP,
                height: 80.h,
                clipShadows: [ClipShadow(color: Colors.black)],
                child: Container(
                  height: 0.5.sh,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 110.h,
                      ),
                      Expanded(
                        child: PageView.builder(
                            physics:
                                const BouncingScrollPhysics(parent: NeverScrollableScrollPhysics()),
                            itemCount: demo_data.length,
                            controller: _pageController,
                            itemBuilder: (context, index) => Pages(
                                  mainText: demo_data[index].mainText,
                                  subText: demo_data[index].subText,
                                )),
                      ),
                      SizedBox(height: 30.h),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                                width: 80.h,
                                height: 80.h,
                                child: Obx(
                                  () => CircularProgressIndicator(
                                    color: Color(0xffFF4F80),
                                    value: welcomeController.count.value,
                                    strokeWidth: 5,
                                  ),
                                )),
                            ElevatedButton(
                              onPressed: () {
                                _storeIntroInfo();
                                welcomeController.count.value =
                                    welcomeController.count.value + 0.25;
                                debugPrint("initCount-->${welcomeController.count.value}");
                                if (_pageController.page != demo_data.length - 1 &&
                                    controller.page != demo_data.length - 1) {
                                  _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                  controller.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                } else {
                                  Get.off(const HomeScreen());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: AppColors.linearColor,
                                padding: const EdgeInsets.all(20),
                              ),
                              child: const Icon(
                                Icons.east_outlined,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class Onboard {
  String mainText, subText;

  Onboard({required this.mainText, required this.subText});
}

final List<Onboard> demo_data = [
  Onboard(mainText: 'Detailed Hourly\nForecast', subText: 'Get in - depth weather information.'),
  Onboard(
    mainText: 'Real-Time\nWeather Map',
    subText: 'Watch the progress of the\nprecipitation to stay informed',
  ),
  Onboard(
    mainText: 'Weather Around\nthe World',
    subText: 'Add any location you want and\nswipe easily to chnage.',
  ),
  Onboard(mainText: 'Detailed Hourly\nForecast', subText: 'Get in - depth weather\ninformation.')
];

class Pages extends StatelessWidget {
  Key? key;
  String mainText;
  String subText;

  Pages({Key? key, required this.mainText, required this.subText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          mainText,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Bold.ttf',
            color: AppColors.introTextColorBold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 21.h,
        ),
        Text(
          subText,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Poppins-Bold.ttf',
            color: AppColors.introSubTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
