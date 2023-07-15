import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raspi_temp/model/record.dart';

import '../model/series.dart';
import '../settings/settings_saving/settings_savings.dart';

class Api {
  http.Client client = http.Client();
  String host;
  Credentials? credentials;

  Api({required this.host, required this.credentials});

  Future<Map<String, Record>> fetchLatestRecord(
      List<String> seriesNames) async {
    List<Future<http.Response>> futures = [];
    for (var seriesName in seriesNames) {
      futures.add(client.get(
        Uri.parse('$host/series/$seriesName/latest'),
        headers: credentials?.generateAuthorizationHeader(),
      ));
    }
    var resps = await Future.wait(futures);
    Map<String, Record> values = {};
    for (int i = 0; i < resps.length; i++) {
      var resp = resps[i];
      var seriesName = seriesNames[i];
      if (resp.statusCode != 200) {
        var code = resp.statusCode;
        var body = resp.body;
        throw Exception('Failed to fetch series $seriesName: $code ($body)');
      }

      var record = jsonDecode(resp.body);
      var t = record["timestamp"];
      var v = record["value"];
      values[seriesName] = Record(timestamp: t, value: v);
    }
    return values;
  }

  Future<List<List<Record>>> fetchRecords(
      DateTime from, DateTime to, List<String> seriesNames) async {
    var fromS = (from.millisecondsSinceEpoch / 1000).round();
    var toS = (to.millisecondsSinceEpoch / 1000).round();

    List<Future<http.Response>> futures = [];
    for (var seriesName in seriesNames) {
      futures.add(client.get(
        Uri.parse('$host/series/$seriesName?from=$fromS&to=$toS'),
        headers: credentials?.generateAuthorizationHeader(),
      ));
    }
    var resps = await Future.wait(futures);
    List<List<Record>> values = [];

    for (int i = 0; i < resps.length; i++) {
      var resp = resps[i];
      var seriesName = seriesNames[i];

      if (resp.statusCode != 200) {
        var code = resp.statusCode;
        var body = resp.body;
        throw Exception('Failed to fetch series $seriesName: $code ($body)');
      }

      values.add([]);
      for (var record in jsonDecode(resp.body)) {
        var t = record["timestamp"];
        var v = record["value"];
        values[i].add(Record(timestamp: t, value: v));
      }
    }
    return values;
  }

  Future<List<Series>> fetchSeries() async {
    var resp = await client.get(
      Uri.parse('$host/series_def'),
      headers: credentials?.generateAuthorizationHeader(),
    );

    if (resp.statusCode != 200) {
      var code = resp.statusCode;
      var body = resp.body;
      throw Exception('Failed to fetch series names: $code ($body)');
    }

    Iterable decoded = jsonDecode(resp.body);
    return decoded.map((e) => Series.fromJson(e)).toList(growable: false);
  }
}
