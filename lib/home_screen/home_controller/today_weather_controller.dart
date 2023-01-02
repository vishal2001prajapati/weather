import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';

import 'package:geocoding/geocoding.dart' hide Location;
import 'package:weather/home_screen/home_controller/forcast_controller.dart';
import 'package:weather/home_screen/model/base_service.dart';
import 'package:weather/utils/get_location.dart';
import '../../database/db.dart';

import 'package:location/location.dart' hide LocationAccuracy;
import '../../utils/const_string/const_string.dart';
import '../model/daily_weather_data.dart';
import '../model/today_weather_data_model.dart';
import '../model/weekly_weather_data.dart';
import 'package:flutter/material.dart';
import 'package:place_picker/place_picker.dart';

class TodayWeatherController extends GetxController {
  BaseService service = BaseService();

  var longitude = 0.0.obs;
  var latitude = 0.0.obs;

  var locationList = <Map<String, dynamic>>[].obs;

  var weatherList = <Weather>[].obs;
  List<WeatherList>? dailyWeatherList = <WeatherList>[].obs;
  List<WeeklyWeatherList>? weeklyWeatherList = <WeeklyWeatherList>[].obs;
  List<WeeklyWeatherList>? weeklyWeatherListFilter = <WeeklyWeatherList>[].obs;
  List<WeeklyWeatherList>? weeklyWeatherListFilterInner = <WeeklyWeatherList>[].obs;
  List<List<WeeklyWeatherList>> hourList = [];

  BaseService baseService = BaseService();
  ForCastController forCastController = Get.put(ForCastController());
  var isLoading = false.obs;
  var temp = 0.0.obs;
  var minTemp = 0.0.obs;
  var maxTemp = 0.0.obs;
  var wind = 0.0.obs;
  var dailyWind = 0.0.obs;
  var city = ''.obs;
  var dbCity = ''.obs;
  RxInt humidity = 0.obs;
  RxInt sunset = 0.obs;
  RxInt sunrise = 0.obs;
  RxDouble feels = 0.0.obs;
  var time = ''.obs;
  var visibility = 0.0.obs;

  @override
  void onInit() async {
    super.onInit();
  }

  // Add Data in SQLFITE
  Future<void> dbLocationStore() async {
    dbLocationDisplay();
    await SQLHelper.createItem(
        city.value, temp.value.toStringAsFixed(0), weatherList[0].main.toString() ?? '');
    print('City name is:-->${city.value}');
    update();
  }

  // Display Data in SQLFITE
  Future<void> dbLocationDisplay() async {
    final data = await SQLHelper.getItems();
    locationList.value = data;
    locationList.refresh();
    update();
    debugPrint('locationList:-->${locationList.length}');
  }

  // Location picker
  void showPlacePicker(BuildContext context) async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              "",
            )));
    latitude.value = result.latLng?.latitude ?? 0.0;
    longitude.value = (result.latLng?.longitude ?? 0.0);

    city.value =
        ('${result.city?.name.toString()}${','}${result.administrativeAreaLevel1?.name.toString()}');
    update();

    // apiCall(context);

    // Handle the result in your way
    // print('City name is:-->${city.value}');
    print('longitude is:-->${result.latLng?.longitude.toString()}');
    print('latitude is:-->${result.latLng?.latitude.toString()}');
    // print(result);
  }

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

  // Current Weather API Call
  Future<CurrentWeather> buildCurrentWeather(BuildContext context) async {
    isLoading.value = true;
    String testCity = await _getCurrentLocation();
    city.value = testCity;
    // debugPrint("Test City is --> $testCity");
    debugPrint("City is --> $city");
    debugPrint('longitude--> $longitude');
    debugPrint('latitude--> $latitude');
    weatherList.clear();

    var result = await baseService.request(
        '${Strings.baseUrl}data/2.5/weather?lat=${latitude.value}&lon=${longitude.value}&appid=${Strings.apiKey}');
    var weatherData = CurrentWeather.fromJson(result.data);
    if (result.statusCode == 200) {
      for (var i in weatherData.weather!) {
        weatherList.add(i);
      }
    } else {
      debugPrint('api code:-->${result.statusCode}');
    }

    debugPrint('resultNew -->${jsonEncode(weatherData)}');
    // weatherList.refresh();
    temp.value = weatherData.main?.temp ?? 0;
    double c = temp.value - 273.15;
    temp.value = c;
    humidity.value = (weatherData.main?.humidity ?? 0);
    wind.value = double.parse(weatherData.wind!.speed.toString());
    sunset.value = weatherData.sys?.sunset ?? 0;
    debugPrint('sunset value is:--> ${sunset.value.toStringAsFixed(2)}');
    feels.value = weatherData.main?.feelsLike ?? 10.0;
    double d2 = feels.value - 273.15;
    feels.value = d2;
    visibility.value = double.parse(weatherData.visibility.toString());
    visibility.value = visibility.value / 1000;
    sunrise.value = weatherData.sys?.sunrise ?? 0;
    debugPrint('sunrise value: --> ${sunrise.value}');
    debugPrint('image:-->${'${weatherList[0].icon}'}');
    debugPrint('desc:-->${'${weatherList[0].main.toString()}'}');

    update();
    isLoading.value = false;

    // dbLocationStore();
    return weatherData;
  }

  // Daily Weather API Call
  Future<DailyWeatherData> buildDailyWeather(BuildContext context) async {
    isLoading.value = true;

    _getCurrentLocation();
    var result = await service.request(
        "${Strings.baseUrl}data/2.5/forecast?lat=${latitude.value}&lon=${longitude.value}&appid=${Strings.apiKey}");
    var weatherData = DailyWeatherData.fromJson(result.data);
    // Daily Data of Horizontal List
    dailyWeatherList?.clear();
    for (var i in weatherData.list!) {
      dailyWeatherList?.add(i);
    }
    time.value = weatherData.list?[0].dtTxt ?? "No Data";
    // debugPrint("DailyWeather Data->${jsonEncode(weatherData)}");
    // debugPrint("DailyWeather length->${dailyWeatherList?.length}");
    update();
    isLoading.value = false;

    return weatherData;
  }

  // Weekly Weather API Call
  Future<WeeklyWeatherData> buildWeeklyWeather(BuildContext context) async {
    isLoading.value = true;

    var result = await service.request(
        "${Strings.baseUrl}data/2.5/forecast?lat=${latitude.value}&lon=${longitude.value}&cnt=40&appid=${Strings.apiKey}");
    var weatherWeeklyData = WeeklyWeatherData.fromJson(result.data);
    debugPrint('WeeklyWeatherData -->${jsonEncode(weatherWeeklyData)}');

    weeklyWeatherList?.clear();
    for (var k in weatherWeeklyData.list!) {
      weeklyWeatherList?.add(k);
    }
    // filter Days Name(Expand Header Code)
    var dateFilter = weatherWeeklyData.list!;
    weeklyWeatherListFilter?.clear();
    for (var i = 0; i < dateFilter.length; i++) {
      if (weeklyWeatherListFilter != null && weeklyWeatherListFilter!.isNotEmpty) {
        if (weeklyWeatherListFilter?.last.dtTxt?.substring(0, 10) !=
            dateFilter[i].dtTxt?.substring(0, 10)) {
          weeklyWeatherListFilter?.add(dateFilter[i]);
        }
      } else {
        weeklyWeatherListFilter?.add(dateFilter[i]);
      }
    }
    debugPrint('weeklyWeatherListFilter:--> ${weeklyWeatherListFilter?.length}');

    // Hours wise Filter Code(Expand List)
    for (int k = 0; k < weeklyWeatherListFilter!.length; k++) {
      List<WeeklyWeatherList>? local = [];

      weeklyWeatherList
          ?.where((i) =>
              i.dtTxt?.substring(0, 10) == weeklyWeatherListFilter?[k].dtTxt?.substring(0, 10))
          .map((e) {
        local.add(e);
      }).toList();
      hourList.add(local);
    }

    update();
    isLoading.value = false;

    return weatherWeeklyData;
  }

  // Method Call
  apiCall(BuildContext context) async {
    isLoading.value = true;
    await buildCurrentWeather(context);
    await buildDailyWeather(context);
    await buildWeeklyWeather(context);
    isLoading.value = false;
  }
}
