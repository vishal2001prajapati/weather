import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weather/home_screen/home_controller/forcast_controller.dart';
import 'package:weather/home_screen/home_controller/home_controller.dart';
import 'package:weather/home_screen/home_controller/today_weather_controller.dart';
import 'package:weather/home_screen/tab_bar/Forecast_Screen.dart';
import 'package:weather/home_screen/tab_bar/Precipitation_Screen.dart';
import 'package:weather/home_screen/tab_bar/Today_Screen.dart';
import 'package:weather/utils/app_colors/AppColors.dart';

import '../database/db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TodayWeatherController todayWeatherController = Get.put(TodayWeatherController());
  ForCastController forCastController = Get.put(ForCastController());
  HomeController homeController = Get.put(HomeController());
  SQLHelper sqlHelper = SQLHelper();

  @override
  void initState() {
    super.initState();
    // _apiCalls(context);
  }

/*  _apiCalls(BuildContext context) {
    GetUserLocation.getLocation(context);
    todayWeatherController.apiCall(context);
    forCastController.apiCall(context);
  }*/

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryColor,
    ));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: buildDrawer(context),
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          backgroundColor: AppColors.linearColor,
          centerTitle: true,
          title: Obx(() => !homeController.visibilitySearch.value
              ? Text(
                  todayWeatherController.city.value,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 14.sp),
                )
              : Container(
                  width: double.infinity,
                  height: 40,
                  decoration:
                      BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: TextField(
                      onTap: () {
                        /* homeController.showPlacePicker(context);*/
                        // todayWeatherController.apiCall(context);
                        todayWeatherController.showPlacePicker(context);
                      },
                      controller: homeController.searchController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              homeController.visibilitySearch.value = false;
                              homeController.searchController.clear();
                            },
                          ),
                          hintText: 'Search...',
                          border: InputBorder.none),
                    ),
                  ),
                )),
          actions: [
            Obx(() => !homeController.visibilitySearch.value
                ? IconButton(
                    onPressed: () {
                      homeController.visibilitySearch.value = true;
                    },
                    icon: const Icon(Icons.search))
                : Container())
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: false,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Forecast'),
              Tab(text: 'Precipitation') // Tab(text: 'Radar Sun & Moon'),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontFamily: 'Poppins-SemiBold.ttf', fontSize: 14.sp),
            unselectedLabelStyle: TextStyle(fontFamily: 'Poppins-SemiBold.ttf', fontSize: 14.sp),
          ),
        ),
        body: const TabBarView(
          children: [TodayScreen(), ForecastScreen(), PrecipitationScreen()],
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    todayWeatherController.dbLocationDisplay();

    return Drawer(
      backgroundColor: AppColors.primaryColor,
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 22.w, top: 20.h),
                child: Row(
                  children: [
                    const CircleAvatar(),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      "Sign In",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: 16.sp),
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ))),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Divider(
                height: 6.h,
                color: Colors.grey,
                thickness: 1,
              ),
              SizedBox(
                height: 20.h,
              ),
              // Edit & location
              Padding(
                padding: EdgeInsets.only(left: 22.w),
                child: Row(
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins-Bold.ttf'),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      '|',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins-Bold.ttf'),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      onTap: () {},
                      child: Text(
                        'Edit',
                        style: TextStyle(
                            color: const Color(0xff04DDF2),
                            fontSize: 16.sp,
                            fontFamily: 'Poppins-Bold.ttf'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Obx(
                () => ListView.builder(
                    itemCount: todayWeatherController.locationList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                        ),
                        title: Text(
                          todayWeatherController.locationList[index]['title'],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp),
                        ),
                        subtitle: Text(
                          todayWeatherController.locationList[index]['temp'] +
                              '\u00B0' +
                              ',' +
                              ' ' +
                              todayWeatherController.locationList[index]['description'],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp),
                        ),
                      );
                    }),
              ),

              SizedBox(
                height: 36.h,
              ),
              Divider(
                height: 6.h,
                color: Colors.grey,
                thickness: 1,
              ),
              SizedBox(
                height: 10.h,
              ),
              ListTile(
                onTap: () {},
                title: const Text(
                  'Tools',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                title: Text(
                  'Notifications',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                title: Text(
                  'Send feedback',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  Icons.star,
                  color: Colors.white,
                ),
                title: Text(
                  'Rate this app',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                title: Text(
                  'Share your weather',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
