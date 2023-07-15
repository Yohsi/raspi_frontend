import 'dart:ui';

import 'package:raspi_temp/model/record.dart';

class Series {
  Series(this.id, this.name, this.color, this.unit);

  Series.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        color = colorFromHexString(json["color"]),
        unit = json["unit"];

  final String id;
  final String name;
  final Color color;
  final String unit;
  List<Record> records = [];
}

Color colorFromHexString(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
