import 'package:flutter/material.dart';

extension HexColor on String {
  Color toHexColor() {
    String hex = replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }
}

extension ColorHexString on Color {
  String toHex({bool leadingHashSign = true}) {
    final hex = '${red.toRadixString(16).padLeft(2, '0')}'
            '${green.toRadixString(16).padLeft(2, '0')}'
            '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();

    return leadingHashSign ? '#$hex' : hex;
  }
}
