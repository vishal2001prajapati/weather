import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:weather/home_screen/home_controller/today_weather_controller.dart';

class GetUserLocation {

  TodayWeatherController todayWeatherController = Get.put(TodayWeatherController());

  getPermissionOfLocation(BuildContext context) async{
    late bool isServiceEnabled;
    LocationPermission permission;

    isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (!isServiceEnabled) {
      if (Platform.isAndroid) {
        Location location = Location();
        isServiceEnabled = await location.requestService();
        if (isServiceEnabled) {
          //  await getLocationPermission(context);
        }
      } else {
        await Geolocator.openLocationSettings();
      }

      return Future.error('Location services are disabled.');
    }
    // todayWeatherController.getCurrentLoc();
    todayWeatherController.apiCall(context);

  }
}