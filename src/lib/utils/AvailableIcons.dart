import 'package:flutter/material.dart';

class AvailableIcons {
  static const List<IconData> allIcons = [
    Icons.shopping_cart,
    Icons.home,
    Icons.fastfood,
    Icons.directions_car,
    Icons.school,
    Icons.coffee,
    Icons.sports_esports,
    Icons.phone_android,
    Icons.music_note,
    Icons.local_hospital,
    Icons.train,
    Icons.airplane_ticket,
    Icons.money,
    Icons.business,
    Icons.pets,
    Icons.book,
    Icons.camera_alt,
    Icons.laptop,
    Icons.tv,
    Icons.bike_scooter,
    Icons.wine_bar,
    Icons.eco,
    Icons.wallet,
    Icons.fitness_center,
    Icons.golf_course,
    Icons.park,
    Icons.pedal_bike,
    Icons.child_care,
    Icons.smoking_rooms,
    Icons.store,
    Icons.group,
    Icons.local_gas_station,
    Icons.lightbulb,
    Icons.beach_access,
    Icons.directions_boat,
    Icons.casino,
    Icons.restaurant,
    Icons.bar_chart,
    Icons.cake,
    Icons.build,
    Icons.gesture,
    Icons.houseboat,
    Icons.kitchen,
    Icons.microwave,
    Icons.bubble_chart,
    Icons.brush,
    Icons.extension,
    Icons.face,
  ];

  static IconData? parseIcon(dynamic iconData) {
    if (iconData is int) {
      return IconData(iconData, fontFamily: 'MaterialIcons');
    } else if (iconData is String && int.tryParse(iconData) != null) {
      return IconData(int.parse(iconData), fontFamily: 'MaterialIcons');
    }
    return null;
  }
}
