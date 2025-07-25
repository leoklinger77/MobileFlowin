import 'package:flutter/material.dart';

class AvailableColors {
  static const List<Color> allColors = [
    Colors.red,
    Colors.redAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.blue,
    Colors.blueAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.purple,
    Colors.purpleAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.brown,
    Colors.grey,
    Colors.teal,
    Colors.tealAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.amber,
    Colors.amberAccent,
    Colors.indigo,
    Colors.indigoAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.blueGrey,
    Colors.black,
  ];

  static Color fromInt(int colorIndex) {
    if (colorIndex >= 0 && colorIndex < allColors.length) {
      return allColors[colorIndex];
    }
    return Colors.blueGrey;
  }

  static int toInt(Color color) {
    return allColors.indexWhere((c) => c.value == color.value);
  }

  static int? getColorIndexFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // adiciona alpha se necessário
    final intColor = int.tryParse(hex, radix: 16);
    if (intColor == null) return null;
    return allColors.indexWhere((color) => color.value == intColor);
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
