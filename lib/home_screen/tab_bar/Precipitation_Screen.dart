import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:weather/home_screen/home_controller/forcast_controller.dart';
import 'package:weather/utils/app_colors/AppColors.dart';

class PrecipitationScreen extends StatefulWidget {
  const PrecipitationScreen({Key? key}) : super(key: key);

  @override
  State<PrecipitationScreen> createState() => _PrecipitationScreenState();
}

class _PrecipitationScreenState extends State<PrecipitationScreen>
    with AutomaticKeepAliveClientMixin {
  ForCastController forCastController = Get.put(ForCastController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    forCastController.apiCall(context);
    super.initState();
  }

  List forecastListData = [
    {
      "id": 1,
      "day": "SUN",
      "date": "SEPT 12",
      "imgForecast": 'assets/images/ic_cl.png',
      "ssw": "ssw 11 km/h",
      "temperature": "33 / 28",
      "percent": "30%"
    },
  ];

  _onLoading() async {
    // your api here
    _refreshController.loadComplete();
  }

  _refresh() {
    forCastController.precipitationApiCall(context);
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Precipitation',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins-Bold.ttf',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                      axisLine: const AxisLine(
                        width: 1,
                      ),
                      isVisible: true,
                      labelStyle: const TextStyle(color: Colors.white)),
                  primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: 100,
                      interval: 20,
                      isVisible: true,
                      labelStyle: TextStyle(color: Colors.white)),
                  series: <ChartSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                        dataSource: forCastController.data,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Colors.grey)
                  ]),
              SizedBox(
                height: 30.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                child: Text(
                  'Precipitation',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins-Bold.ttf',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: forecastListData.length,
                  itemBuilder: (context, int index) {
                    return InkWell(onTap: () {}, child: forecastList(index: index));
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget forecastList({required int index}) {
    return Container(
      padding: EdgeInsets.all(12.r),
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
                text: '${forecastListData[index]['day']}\n',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    color: Colors.grey),
                children: <TextSpan>[
                  TextSpan(
                    text: forecastListData[index]['date'],
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
            child: Image.asset(
              forecastListData[index]['imgForecast'],
              height: 40.h,
              width: 30.w,
            ),
          ),
          RichText(
            text: TextSpan(
                text: 'Thunderstorms\n',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    color: Colors.grey),
                children: <TextSpan>[
                  TextSpan(
                    text: forecastListData[index]['ssw'],
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        color: Colors.grey),
                  ),
                ]),
          ),
          Expanded(
            child: Column(
              children: [
                Text('86${'\u00B0'}/80${'\u00B0'}',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        color: Colors.white)),
                Text.rich(
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      color: Colors.white),
                  TextSpan(
                    children: [
                      const WidgetSpan(
                          child: Icon(
                        Icons.water_drop,
                        color: Colors.white,
                      )),
                      TextSpan(
                        text: forecastListData[index]['percent'],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}