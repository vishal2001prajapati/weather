import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:weather/home_screen/home_controller/forcast_controller.dart';
import 'package:weather/utils/app_colors/AppColors.dart';
import 'package:weather/utils/extension_methods.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({Key? key}) : super(key: key);

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> with AutomaticKeepAliveClientMixin {
  ForCastController forCastController = Get.put(ForCastController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    forCastController.apiCall(context);
  }

  _onLoading() async {
    _refreshController.loadComplete();
  }

  _refresh() {
    forCastController.apiCall(context);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onLoading: _onLoading,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                  height: 110.h,
                  child: Obx(
                    () => ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: forCastController.forCastWeeklyWeatherListFilter?.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: forCastDailyData(index));
                      },
                    ),
                  )),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 18.w),
                child: Row(
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Average: ',
                        style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        children: <TextSpan>[
                          TextSpan(
                              text: ' 28%',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 14.0)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  height: 260.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff2F313A), Color(0xff232329)],
                      ),
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                  height: 65.h,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff2F313A), Color(0xff232329)],
                      ),
                      borderRadius: BorderRadius.circular(30.r)),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Padding(
                          padding: EdgeInsets.only(left: 15.w),
                          child: Text(
                            'See minute-by-minute forecasts Plan',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              fontFamily: 'Poppins-Bold.ttf',
                            ),
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(left: 15.w),
                          child: Text(
                            'Plan for the next 5 hours',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 14.sp,
                              fontFamily: 'Poppins-Bold.ttf',
                            ),
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: AppColors.linearColor,
                            padding: const EdgeInsets.all(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.white,
                            size: 15.h,
                          ),
                        ),
                      )
                    ],
                  )),
              SizedBox(
                height: 10.h,
              ),
              Obx(
                () => ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: forCastController.weeklyWeatherForecastListFilter!.length,
                    itemBuilder: (context, int index) {
                      return forecastList(index: index);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget forecastList({required int index}) {
    return Container(
      padding: EdgeInsets.all(6.r),
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff2F313A), Color(0xff232329)],
          ),
          borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
                text: '${DateFormat('EEE').format(DateTime.now())}\n',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    color: Colors.grey),
                children: <TextSpan>[
                  TextSpan(
                    text: DateFormat('dd MMM').format(DateTime.now()),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      color: Colors.white,
                    ),
                  )
                ]),
          ),
          Expanded(
              child: Obx(
            () => Image.network(
              'https://openweathermap.org/img/wn/${forCastController.weeklyWeatherForecastListFilter?[index].weather?[0].icon}@2x.png',
              width: 40.w,
              height: 40.h,
            ),
          )),
          Obx(
            () => RichText(
              text: TextSpan(
                  text:
                      '${forCastController.weeklyWeatherForecastListFilter?[index].weather?[0].description?.toTitleCase()}\n',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      color: AppColors.thunderstormsColor),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'NA',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp,
                          color: Colors.grey),
                    ),
                  ]),
            ),
          ),
          Expanded(
              child: Obx(
            () => Column(
              children: [
                Text(
                    '${((forCastController.weeklyWeatherForecastListFilter?[index].main?.tempMax) - 273.15).toStringAsFixed(0)}${'\u00B0'} / ${((forCastController.weeklyWeatherForecastListFilter?[index].main?.tempMin) - 273.15).toStringAsFixed(0)}${'\u00B0'}',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: Colors.white)),
                Text.rich(
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: Colors.white),
                  TextSpan(
                    children: [
                      WidgetSpan(
                          child: Padding(
                        padding: EdgeInsets.only(left: 8.r),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                        ),
                      )),
                      TextSpan(
                        text:
                            '${forCastController.weeklyWeatherForecastListFilter?[index].main?.humidity}%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget forCastDailyData(int index) {
    return Column(
      children: [
        Obx(
          () => Image.network(
            'https://openweathermap.org/img/wn/${forCastController.weeklyWeatherList?[index].weather?[0].icon}@2x.png',
            height: 30.h,
            width: 30.w,
          ),
        ),
        SizedBox(
          height: 7.h,
        ),
        Obx(
          () => Text(
              DateFormat('EEEE').format(DateFormat("yyyy-MM-DD").parse(
                  '${(forCastController.forCastWeeklyWeatherListFilter?[index].dtTxt)?.substring(0, 10)}')),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.normal,
                fontFamily: 'Poppins-Bold.ttf',
                color: Colors.grey,
              )),
        ),
        SizedBox(
          height: 11.h,
        ),
        Obx(
          () => Text(
            '${((forCastController.forCastWeeklyWeatherListFilter?[index].main?.temp) - 273.15).toStringAsFixed(0)}${'\u00B0'}',
            style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Poppins-Bold.ttf',
                color: Colors.white,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}