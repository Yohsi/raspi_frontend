import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:raspi_temp/settings/settings_saving/theme_saver.dart';
import 'package:raspi_temp/settings/ui/settings_page.dart';
import 'package:raspi_temp/temperature_plot/ui/plot.dart';
import 'package:raspi_temp/theme/colors.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import 'api/api.dart';
import 'model/series.dart';
import 'settings/settings_saving/settings_savings.dart';

Future<void> main() async {
  await initializeDateFormatting(null, null);
  var locale = await findSystemLocale();
  Intl.systemLocale = locale;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeModeHandler(
      manager: ThemeSaver(),
      defaultTheme: ThemeMode.system,
      builder: (themeMode) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: RaspiColors.SEED,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: RaspiColors.SEED,
          brightness: Brightness.dark,
        ),
        themeMode: themeMode,
        home:
            const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Api api;
  List<Series> series = [];
  DateTime start = DateTime.now().subtract(const Duration(days: 2));
  DateTime end = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchSeries();
  }

  Future<void> fetchSeries() async {
    var host = await SettingsSaving.loadServerUrl() ?? "";
    var credentials = await SettingsSaving.loadServerCredentials();
    api = Api(host: host, credentials: credentials);
    series = await api.fetchSeries();
    var records = await api.fetchRecords(
        start, end, series.map((s) => s.id).toList(growable: false));
    setState(() {
      for (int i = 0; i < records.length; i++) {
        series[i].records = records[i];
      }
    });
  }
  
  Future<void> updateSeries() async {
    DateTime start = DateTime.now().subtract(const Duration(days: 2));
    DateTime end = DateTime.now();

    var records = await api.fetchRecords(
        start, end, series.map((s) => s.id).toList(growable: false));
    setState(() {
      for (int i = 0; i < records.length; i++) {
        series[i].records = records[i];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var units = series.map((s) => s.unit).toSet();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Température"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.zoom_in_map_rounded),
          //   onPressed: () {
          //     context
          //         .read<TemperatureBloc>()
          //         .add(TemperatureRangeResetRequested());
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              updateSeries();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          children: units
              .map(
                (unit) => Card(
                  clipBehavior: Clip.none,
                  child: Plot(
                      series: series.where((s) => s.unit == unit),
                      start: start,
                      end: end),
                ),
              )
              .toList(growable: false)),
    );
  }
}
