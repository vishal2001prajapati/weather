import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather/home_screen/home_controller/today_weather_controller.dart';

import '../../database/db.dart';

class HomeController extends GetxController {
  RxBool visibilitySearch = false.obs;
  var longitude = 0.0.obs;
  var latitude = 0.0.obs;
  RxString cityName = ''.obs;
  TodayWeatherController todayWeatherController = Get.put(TodayWeatherController());
  final TextEditingController searchController = TextEditingController();

  clearTextField() {
    searchController.clear();
  }






/* Future<void> dbLocationStore() async {
    dbLocationDisplay();
    await SQLHelper.createItem(
        todayWeatherController.city.value,
        todayWeatherController.temp.value.toStringAsFixed(0),
        todayWeatherController.weeklyWeatherList?[0].weather?[0].main.toString() ?? '');
  }

  Future<void> dbLocationDisplay() async {
    final data = await SQLHelper.getItems();
    locationList = data;

    update();
  }*/
}
