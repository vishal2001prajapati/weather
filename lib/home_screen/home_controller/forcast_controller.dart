import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utils/const_string/const_string.dart';
import '../model/base_service.dart';
import '../model/weekly_weather_data.dart';

class ForCastController extends GetxController {
  BaseService baseService = BaseService();
  BaseService service = BaseService();
  var longitude = 0.0.obs;
  var latitude = 0.0.obs;
  var data = <ChartData>[].obs;
  List<WeeklyWeatherList>? weeklyWeatherList = <WeeklyWeatherList>[].obs;
  List<WeeklyWeatherList>? forCastWeeklyWeatherListFilter = <WeeklyWeatherList>[].obs;
  List<WeeklyWeatherList>? weeklyWeatherForecastListFilter = <WeeklyWeatherList>[].obs;
  List<int>? tempForCastWeeklyWeatherListFilter = <int>[].obs;
  List<String>? dayForCastWeeklyWeatherListFilter = <String>[].obs;

  Future _getCurrentLocation() async {
    await getCurrentLoc();
    List placemarks = await placemarkFromCoordinates(latitude.value, longitude.value);
    Placemark place = placemarks[0];
    String newCity = '${place.locality},${place.administrativeArea}';
    return newCity;
  }

  Future getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    debugPrint("longitude-->${longitude.toString()}");
    debugPrint("latitude-->${latitude.toString()}");
    return position;
  }

  //ForCast Screen
  Future<WeeklyWeatherData> buildForCastWeeklyWeather(BuildContext context) async {
    String test = await _getCurrentLocation();
    var result = await service.request(
        "${Strings.baseUrl}data/2.5/forecast?lat=${latitude.value}&lon=${longitude.value}&cnt=40&appid=${Strings.apiKey}");
    var weatherWeeklyData = WeeklyWeatherData.fromJson(result.data);
    debugPrint('WeeklyWeatherData -->${jsonEncode(weatherWeeklyData)}');
    weeklyWeatherList?.clear();
    for (var k in weatherWeeklyData.list!) {
      weeklyWeatherList?.add(k);
    }
    // filter Days Wise Name
    var dateFilter = weatherWeeklyData.list!;
    forCastWeeklyWeatherListFilter?.clear();
    for (var i = 0; i < dateFilter.length; i++) {
      if (forCastWeeklyWeatherListFilter != null && forCastWeeklyWeatherListFilter!.isNotEmpty) {
        if (forCastWeeklyWeatherListFilter?.last.dtTxt?.substring(0, 10) !=
            dateFilter[i].dtTxt?.substring(0, 10)) {
          forCastWeeklyWeatherListFilter?.add(dateFilter[i]);
        }
      } else {
        forCastWeeklyWeatherListFilter?.add(dateFilter[i]);
      }
    }

    // daily forCast Daily --> 5 Data
    weeklyWeatherForecastListFilter?.clear();
    for (int k = 0; k < dateFilter.length; k++) {
      if (weeklyWeatherList?.first.dtTxt?.substring(0, 10) ==
          dateFilter[k].dtTxt?.substring(0, 10)) {
        weeklyWeatherForecastListFilter?.add(weeklyWeatherList![k]);
      }
    }

    debugPrint('forCastWeeklyWeatherListFilter:--> ${forCastWeeklyWeatherListFilter?.length}');

    // Precipitation Screen API Call
    // y- axis temp display
    tempForCastWeeklyWeatherListFilter?.clear();
    for (int i = 0; i < forCastWeeklyWeatherListFilter!.length; i++) {
      // tempForCastWeeklyWeatherListFilter?.add(i);
      tempForCastWeeklyWeatherListFilter
          ?.add(forCastWeeklyWeatherListFilter?[i].main?.humidity ?? 0);
      //  temp.value = (forCastWeeklyWeatherListFilter?[i].main?.temp - 273.15) / 3.6;
    }

    // x-axis in display days name
    dayForCastWeeklyWeatherListFilter?.clear();
    for (var l = 0; l < forCastWeeklyWeatherListFilter!.length; l++) {
      dayForCastWeeklyWeatherListFilter?.add(DateFormat('EEEE').format(DateFormat("yyyy-MM-DD")
          .parse('${(forCastWeeklyWeatherListFilter?[l].dtTxt)?.substring(0, 10)}')));
    }

    // data display on graph
    for (var o = 0; o < dayForCastWeeklyWeatherListFilter!.length; o++) {
      data.add(ChartData(
          dayForCastWeeklyWeatherListFilter![o], (tempForCastWeeklyWeatherListFilter![o])));
    }

    data.refresh();
    update();
    return weatherWeeklyData;
  }

  //Precipitation Screen
  Future<WeeklyWeatherData> buildPrecipitationWeeklyWeather(BuildContext context) async {
    String test = await _getCurrentLocation();
    var result = await service.request(
        "${Strings.baseUrl}data/2.5/forecast?lat=${latitude.value}&lon=${longitude.value}&cnt=40&appid=${Strings.apiKey}");
    var weatherWeeklyData = WeeklyWeatherData.fromJson(result.data);
    debugPrint('WeeklyWeatherData -->${jsonEncode(weatherWeeklyData)}');
    weeklyWeatherList?.clear();
    for (var k in weatherWeeklyData.list!) {
      weeklyWeatherList?.add(k);
    }

    // Precipitation Screen API Call
    // y- axis temp display
    tempForCastWeeklyWeatherListFilter?.clear();
    for (int i = 0; i < forCastWeeklyWeatherListFilter!.length; i++) {
      // tempForCastWeeklyWeatherListFilter?.add(i);
      tempForCastWeeklyWeatherListFilter
          ?.add(forCastWeeklyWeatherListFilter?[i].main?.humidity ?? 0);
      //  temp.value = (forCastWeeklyWeatherListFilter?[i].main?.temp - 273.15) / 3.6;
    }

    // x-axis in display days name
    dayForCastWeeklyWeatherListFilter?.clear();
    for (var l = 0; l < forCastWeeklyWeatherListFilter!.length; l++) {
      dayForCastWeeklyWeatherListFilter?.add(DateFormat('EEEE').format(DateFormat("yyyy-MM-DD")
          .parse('${(forCastWeeklyWeatherListFilter?[l].dtTxt)?.substring(0, 10)}')));
    }

    // data display on graph
    for (var o = 0; o < dayForCastWeeklyWeatherListFilter!.length; o++) {
      data.add(ChartData(
          dayForCastWeeklyWeatherListFilter![o], (tempForCastWeeklyWeatherListFilter![o])));
    }

    data.refresh();
    update();
    return weatherWeeklyData;
  }

  apiCall(BuildContext context) async {
    await buildForCastWeeklyWeather(context);
  }

  precipitationApiCall(BuildContext context) async {
    await buildPrecipitationWeeklyWeather(context);
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final int y;
}
