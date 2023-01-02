import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:weather/home_screen/tab_bar/MySeparator.dart';
import 'package:weather/utils/app_colors/AppColors.dart';

import '../../utils/get_location.dart';
import '../home_controller/today_weather_controller.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  TodayWeatherController todayWeatherController = Get.put(TodayWeatherController());
  GetUserLocation getUserLocation = GetUserLocation();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  String currentDate = DateFormat("EEEE, dd MMM").format(DateTime.now());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getUserLocation.getPermissionOfLocation(context);
/*    debugPrint('Temperature data is:-->${todayWeatherController.temp.value}');
    debugPrint('Wind data is:-->${todayWeatherController.wind.toString()}');
    debugPrint('Time data is:-->${ todayWeatherController.time.value}');*/
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getUserLocation.getPermissionOfLocation(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _onLoading() async {
    _refreshController.loadComplete();
  }

  _refresh() {
    todayWeatherController.apiCall(context);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onLoading: _onLoading,
        onRefresh: _refresh,
        child: Obx(() => todayWeatherController.isLoading.value == false
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 11.h,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 28.h,
                        width: 135.w,
                        decoration: BoxDecoration(
                            color: AppColors.backgroundContainer,
                            borderRadius: BorderRadius.circular(16.r)),
                        child: Center(
                          child: Text(
                            currentDate,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.dateColor,
                                fontFamily: 'Poppins-SemiBold.ttf',
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 7.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Obx(() => todayWeatherController.weatherList.isNotEmpty == true
                                ? Obx(() => Image.network(
                                    'https://openweathermap.org/img/wn/${todayWeatherController.weatherList[0].icon}@2x.png'))
                                : Image.asset(
                                    'assets/images/ic_cl.png',
                                    fit: BoxFit.fill,
                                  )
                            //Image.asset(
                            //     'assets/images/ic_cl.png',
                            //     fit: BoxFit.fill,
                            //   ),
                            ),
                        SizedBox(
                          width: 77.w,
                        ),
                        Obx(
                          () => Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return AppColors()
                                      .gradient
                                      .createShader(Offset.zero & bounds.size);
                                },
                                child: todayWeatherController.temp.value == 0
                                    ? Text(
                                        'No Data',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        '${(todayWeatherController.temp.value).toStringAsFixed(0)}${"\u00B0"}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 50.0.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              todayWeatherController.weatherList.isNotEmpty == true
                                  ? Text(
                                      todayWeatherController.weatherList[0].main.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Poppins-Regular.ttf'),
                                    )
                                  : Text(
                                      'No Data',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Poppins-Regular.ttf'),
                                    )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25.w),
                      child: Row(
                        children: [
                          Obx(
                            () => RichText(
                              text: TextSpan(
                                text: '29°/27° | Feels like ',
                                style: const TextStyle(fontSize: 14.0, color: AppColors.dateColor),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        '${todayWeatherController.feels.value.toStringAsFixed(0)}${'\u00B0'}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.sp,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          const Text(
                            '|',
                            style: TextStyle(color: AppColors.dateColor),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          Expanded(
                            child: Obx(
                              () => RichText(
                                text: TextSpan(
                                  text: 'Wind: ',
                                  style: TextStyle(fontSize: 14.0.sp, color: AppColors.dateColor),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '${todayWeatherController.wind.toString()} ${'km'}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            fontSize: 14.0.sp)),
                                    TextSpan(
                                      text: '/ H WSW',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          color: AppColors.dateColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 21.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: const MySeparator(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25.w, right: 10.w),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/ic_Precipitation.png',
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(
                            width: 10.5.w,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Precipitation: ',
                              style: TextStyle(fontSize: 14.0.sp, color: AppColors.dateColor),
                              children: <TextSpan>[
                                TextSpan(
                                    text: '50%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontSize: 14.0.sp)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 50.5.w,
                          ),
                          Image.asset(
                            'assets/images/ic_Precipitation.png',
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(
                            width: 10.5.w,
                          ),
                          Obx(
                            () => RichText(
                              text: TextSpan(
                                text: 'Humidity: ',
                                style: TextStyle(fontSize: 14.0.sp, color: AppColors.dateColor),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          '${todayWeatherController.humidity.value.toString()}${'%'}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontSize: 14.0.sp)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25.w),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/ic_wind.png',
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(
                            width: 10.5.w,
                          ),
                          Obx(
                            () => RichText(
                              text: TextSpan(
                                text: 'Wind: ',
                                style: TextStyle(fontSize: 14.0.sp, color: AppColors.dateColor),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '${todayWeatherController.wind.toString()} ${'km/h'}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontSize: 14.0.sp)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60.5.w,
                          ),
                          Image.asset(
                            'assets/images/ic_sunset.png',
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(
                            width: 10.5.w,
                          ),
                          Obx(
                            () => RichText(
                              text: TextSpan(
                                text: 'Sunset: ',
                                style: TextStyle(fontSize: 14.0.sp, color: AppColors.dateColor),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          ' ${(DateTime.now().hour * 100 / (DateTime.fromMillisecondsSinceEpoch(todayWeatherController.sunset.value * 1000).hour)).toStringAsFixed(2)}'
                                          '${'%'}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontSize: 14.0.sp)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 29.h,
                    ),
                    Container(
                        height: 140.h,
                        child: Obx(
                          () => todayWeatherController.dailyWeatherList?.isNotEmpty == true
                              ? ListView.builder(
                                  itemBuilder: (context, index) {
                                    return xyzTest(index: index);
                                  },
                                  scrollDirection: Axis.horizontal,
                                  itemCount: todayWeatherController.dailyWeatherList?.length,
                                  physics: const BouncingScrollPhysics(),
                                )
                              : Center(
                                  child: Text(
                                  'No Data',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins-Regular.ttf'),
                                )),
                        )),
                    SizedBox(
                      height: 27.h,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff2F313A), Color(0xff232329)],
                          ),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 30.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'High',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins-Regular.ttf',
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Text(
                                  '|',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins-Regular.ttf',
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(
                                  'Low',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins-Regular.ttf',
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(
                            () => todayWeatherController.weeklyWeatherListFilter?.isNotEmpty == true
                                ? ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount:
                                        todayWeatherController.weeklyWeatherListFilter?.length,
                                    itemBuilder: (context, index) {
                                      return ListTileTheme(
                                        horizontalTitleGap: 0.0,
                                        dense: true,
                                        child: ExpansionTile(
                                          iconColor: Colors.grey,
                                          trailing: const SizedBox.shrink(),
                                          controlAffinity: ListTileControlAffinity.leading,
                                          collapsedIconColor: Colors.grey,
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 0.3.sw,
                                                  child: Obx(
                                                    () => Text(
                                                        DateFormat('EEEE').format(
                                                            DateFormat("yyyy-MM-DD").parse(
                                                                '${(todayWeatherController.weeklyWeatherListFilter?[index].dtTxt)?.substring(0, 10)}')),
                                                        style: TextStyle(
                                                            color: Colors.white, fontSize: 15.sp)),
                                                  )),
                                              Obx(
                                                () => Image.network(
                                                  'https://openweathermap.org/img/wn/${todayWeatherController.weeklyWeatherListFilter?[index].weather?[0].icon}@2x.png',
                                                  height: 40.h,
                                                  width: 40.w,
                                                ),
                                              ),
                                              Obx(() => Text(
                                                  '${((todayWeatherController.weeklyWeatherListFilter?[index].main?.tempMax) - 273.15).toStringAsFixed(0)}${'\u00B0'}',
                                                  style: TextStyle(
                                                      color: Colors.white, fontSize: 15.sp))),
                                              Obx(() => Text(
                                                  '${((todayWeatherController.weeklyWeatherListFilter?[index].main?.tempMin) - 273.15).toStringAsFixed(0)}${'\u00B0'}',
                                                  style: TextStyle(
                                                      color: Colors.white, fontSize: 15.sp))),
                                            ],
                                          ),
                                          children: [
                                            Container(
                                              height: 150.h,
                                              margin: EdgeInsets.only(bottom: 10.h, top: 5.h),
                                              child: ListView.builder(
                                                physics: const BouncingScrollPhysics(),
                                                itemBuilder: (context, hourIndex) {
                                                  return test(
                                                      dayIndex: index, hourIndex: hourIndex);
                                                },
                                                itemCount:
                                                    todayWeatherController.hourList[index]?.length,
                                                scrollDirection: Axis.horizontal,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                    'No Data',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins-Regular.ttf'),
                                  )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff2F313A), Color(0xff232329)],
                          ),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 22.w, top: 10.h),
                            child: Text(
                              'Details',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins-SemiBold.ttf'),
                            ),
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          Row(
                            children: [
                              Obx(
                                () => todayWeatherController.weatherList!.isNotEmpty == true
                                    ? Obx(() => Image.network(
                                        width: 150.w,
                                        'https://openweathermap.org/img/wn/${todayWeatherController.weatherList?[0].icon}@2x.png'))
                                    : Image.asset(
                                        'assets/images/ic_cl.png',
                                        fit: BoxFit.fill,
                                      ),
                              ),
                              SizedBox(
                                width: 25.w,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 25.w),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Feels like',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                fontSize: 13.sp,
                                                color: Colors.grey),
                                          ),
                                          Obx(
                                            () => Text(
                                              '${todayWeatherController.feels.value.toStringAsFixed(0)}${'\u00B0'}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 13.sp,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Humidity',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                fontSize: 13.sp,
                                                color: Colors.grey),
                                          ),
                                          Obx(
                                            () => Text(
                                              '${todayWeatherController.humidity.value.toString()}${'%'}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 13.sp,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Visibility',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                fontSize: 13.sp,
                                                color: Colors.grey),
                                          ),
                                          Obx(
                                            () => Text(
                                              '${todayWeatherController.visibility.value} ${'km'}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 13.sp,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'UV Index',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                fontSize: 13.sp,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            '56\u00B0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                fontSize: 13.sp,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Dew point',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                fontSize: 13.sp,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            '56\u00B0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                fontSize: 13.sp,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22.w, right: 28.w, bottom: 25.h),
                            child: Text(
                              'Tonight - Clear. Winds from SW to SSW at 10 to 11 mph (16.1 to 17.7 kph). The overnight low will be 69° F (20.0 ° C)',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Poppins-Regular.ttf',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff2F313A), Color(0xff232329)],
                          ),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 22.w, top: 10.h, right: 21.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Air Quality',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins-Medium.ttf'),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 18.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 80.h,
                                width: 0.3.sw,
                                child: SfRadialGauge(axes: <RadialAxis>[
                                  RadialAxis(
                                    annotations: [
                                      GaugeAnnotation(
                                          positionFactor: 0.1,
                                          angle: 90,
                                          widget: Padding(
                                            padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              '31\nModerate',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            ),
                                          ))
                                    ],
                                    minimum: 0,
                                    maximum: 100,
                                    showLabels: false,
                                    showTicks: false,
                                    axisLineStyle: const AxisLineStyle(
                                      thickness: 0.1,
                                      cornerStyle: CornerStyle.bothCurve,
                                      color: Color(0xFFFE1D1D),
                                      gradient: SweepGradient(colors: <Color>[
                                        Color(0xFF22FFE0),
                                        Color(0xFFFEDE35),
                                        Color(0xFFFE381D),
                                        Color(0xFFFE1D1D),
                                      ], stops: <double>[
                                        0.15,
                                        0.40,
                                        0.60,
                                        0.80
                                      ]),
                                      thicknessUnit: GaugeSizeUnit.factor,
                                    ),
                                  )
                                ]),
                              ),
                              Expanded(
                                child: Text(
                                  'You have good air quality - enjoy your outdoor activities.',
                                  style: TextStyle(
                                      color: AppColors.dateColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Poppins-Regular.ttf'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                            child: const MySeparator(color: Colors.grey),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    text: 'US EPA AQI ',
                                    style: TextStyle(
                                        fontFamily: 'Poppins-Regular.ttf',
                                        fontSize: 14.0,
                                        color: AppColors.dateColor),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '49/500',
                                          style: TextStyle(
                                              fontFamily: 'Poppins-Regular.ttf',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0)),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: const TextSpan(
                                    text: 'Dominant pollutant ',
                                    style: TextStyle(
                                        fontFamily: 'Poppins-Regular.ttf',
                                        fontSize: 14.0,
                                        color: AppColors.dateColor),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'PM 10',
                                          style: TextStyle(
                                              fontFamily: 'Poppins-Regular.ttf',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      height: 170.h,
                      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff2F313A), Color(0xff232329)],
                          ),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Coronavirus Latest',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins-SemiBold.ttf'),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tamil Nadu, Chennai',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins-Regular.ttf'),
                                ),
                                Text(
                                  'Total',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Poppins-Regular.ttf'),
                                ),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Poppins-Regular.ttf'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Confirmed Cases',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins-Regular.ttf'),
                                ),
                                Container(
                                  height: 25.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: Color(0xff32333E),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                    child: Center(
                                      child: Text(
                                        '10,51354',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontFamily: 'Poppins-Regular.ttf',
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 25.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: Colors.red,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                    child: Center(
                                      child: Text(
                                        '${'+'}${1051}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontFamily: 'Poppins-Regular.ttf',
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 28.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                            child: const MySeparator(color: Colors.grey),
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 22.w,
                              ),
                              child: Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "More detail",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      height: 150.h,
                      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff2F313A), Color(0xff232329)],
                          ),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 22.w, top: 10.h),
                            child: Text(
                              'Sun & Moon',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins-SemiBold.ttf'),
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 22.w,
                                ),
                                child: Column(
                                  children: [
                                    Obx(
                                      () => Text(
                                        ('${DateFormat.Hm().format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              todayWeatherController.sunrise.value * 1000),
                                        )} ${'AM'}'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins-Regular.ttf',
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    Text(
                                      'Sunrise',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins-Regular.ttf',
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: Stack(alignment: Alignment.topLeft, children: [
                                  SizedBox(
                                    height: 70.h,
                                    width: 0.3.sw,
                                    child: SfRadialGauge(axes: <RadialAxis>[
                                      RadialAxis(
                                        showLabels: false,
                                        showTicks: false,
                                        axisLineStyle: const AxisLineStyle(
                                          thickness: 0.03,
                                          color: Colors.grey,
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        startAngle: 180,
                                        endAngle: 360,
                                      ),
                                    ]),
                                  ),
                                  Positioned(
                                      top: 0.h,
                                      right: 20.w,
                                      child: Image.asset(
                                        'assets/images/ic_wind.png',
                                        height: 26.h,
                                      ))
                                ]),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.w),
                                child: Column(
                                  children: [
                                    Obx(
                                      () => Text(
                                        ('${DateFormat.Hm().format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              todayWeatherController.sunset.value * 1000),
                                        )} ${'PM'}'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins-Regular.ttf',
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    Text(
                                      'Sunrise',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins-Regular.ttf',
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )),
      ),
    );
  }

  Widget xyzTest({required int index}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
          color: AppColors.bgContainerColor,
          borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(30.r),
              topEnd: Radius.circular(30.r),
              bottomStart: Radius.circular(30.r),
              bottomEnd: Radius.circular(30.r))),
      height: 150.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                todayWeatherController.dailyWeatherList?[index].dtTxt?.substring(11, 16) ?? "",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins-Regular.ttf'),
              ),
            ),
          ),
          Obx(() => todayWeatherController.dailyWeatherList![index].weather!.isNotEmpty
              ? Image.network(
                  'https://openweathermap.org/img/wn/${todayWeatherController.dailyWeatherList?[index].weather?[0].icon}@2x.png',
                  height: 50.h,
                  width: 50.w,
                )
              : Image.asset(
                  'assets/images/ic_cl.png',
                  height: 30.h,
                )),
          Obx(
            () => todayWeatherController.dailyWeatherList?[index].main?.temp != null
                ? Text(
                    '${((todayWeatherController.dailyWeatherList?[index].main?.temp ?? 0.0) - 273.15).toStringAsFixed(0)} ${"\u00B0C"}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins-Bold.ttf'),
                  )
                : const Text('No Data'),
          )
        ],
      ),
    );
  }

  Widget test({required int dayIndex, required int hourIndex}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
          color: AppColors.bgContainerColor,
          borderRadius: BorderRadiusDirectional.all(Radius.circular(8.r))),
      width: 60.w,
      height: 50.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.network(
            'https://openweathermap.org/img/wn/${todayWeatherController.hourList[dayIndex][hourIndex].weather?[0].icon}@2x.png',
            height: 40.h,
          ),
          Text(
            '${((todayWeatherController.hourList[dayIndex][hourIndex].main?.temp) - 273.15).toStringAsFixed(0)}${'\u00B0'}',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600),
          ),
          Text(
            DateFormat('hh a').format(DateTime.parse(DateFormat("HH")
                .parse((todayWeatherController.hourList[dayIndex][hourIndex].dtTxt
                    ?.substring(11, 13))!)
                .toString())),
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}