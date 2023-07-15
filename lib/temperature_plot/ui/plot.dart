import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raspi_temp/model/record.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../model/series.dart';

class Plot extends StatefulWidget {
  const Plot(
      {super.key,
      required this.series,
      required this.start,
      required this.end});

  final Iterable<Series> series;
  final DateTime start;
  final DateTime end;

  @override
  State<Plot> createState() => _PlotState();
}

class _PlotState extends State<Plot> {
  // Map<String, ChartSeriesController> seriesControllers = {};
  DateTime axisVisibleMin = DateTime.now().subtract(const Duration(days: 1));
  DateTime axisVisibleMax = DateTime.now();
  bool isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    List<ChartSeries> lineSeries = [];
    for (var s in widget.series.where((s) => s.records.isNotEmpty)) {
      lineSeries.add(FastLineSeries<Record, DateTime>(
        animationDuration: 0,
        dataSource: s.records,
        xValueMapper: (Record record, _) => record.getTime(),
        yValueMapper: (Record record, _) => record.value,
        color: s.color,
        name: s.name,
        width: 2,
        // onRendererCreated: (controller) =>
        //     seriesControllers[s.id] = controller,
      ));
    }

    return SfCartesianChart(
      title: ChartTitle(text: widget.series.map((e) => e.name).join(", ")),
      legend: Legend(
          isVisible: true,
          toggleSeriesVisibility: true,
          position: LegendPosition.bottom),
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.E("fr").add_Hm(),
        visibleMinimum: axisVisibleMin,
        visibleMaximum: axisVisibleMax,
        plotBands: [
          PlotBand(
            isVisible: true,
            isRepeatable: true,
            color: Theme.of(context).colorScheme.surfaceVariant,
            repeatEvery: 24,
            size: 11,
            sizeType: DateTimeIntervalType.hours,
            repeatUntil: DateTime.now(),
            start: widget.start
                .subtract(const Duration(days: 1))
                .copyWith(hour: 21, minute: 0, second: 0),
          ),
        ],
      ),
      primaryYAxis: NumericAxis(
        autoScrollingMode: AutoScrollingMode.start,
        numberFormat: NumberFormat.decimalPatternDigits(
            locale: "fr_FR", decimalDigits: 1),
        labelFormat: "{value} ${widget.series.first.unit}",
      ),
      trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          shouldAlwaysShow: false,
          tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.visible,
          ),
          hideDelay: 1,
          lineWidth: 0.5,
          tooltipSettings: const InteractiveTooltip(
              format: "point.x : point.y", canShowMarker: true)),
      zoomPanBehavior: ZoomPanBehavior(
          enableMouseWheelZooming: true,
          enablePinching: true,
          enableDoubleTapZooming: true,
          enablePanning: true,
          zoomMode: ZoomMode.x),
      onActualRangeChanged: onActualRangeChanged,
      series: lineSeries,
      // loadMoreIndicatorBuilder:
      //     (BuildContext context, ChartSwipeDirection direction) =>
      //         getLoadMoreViewBuilder(context, direction),
    );
  }

  List<PlotBand> generatePlotBands(DateTime end, Duration duration) {
    List<PlotBand> bands = [];
    var start = end.subtract(duration);
    var bandStart = start.subtract(const Duration(days: 1)).copyWith(
        hour: 21, minute: 0, second: 0, microsecond: 0, millisecond: 0);
    var bandEnd = start.copyWith(
        hour: 8, minute: 0, second: 0, microsecond: 0, millisecond: 0);

    while (bandStart.isBefore(end)) {
      bands.add(PlotBand(start: bandStart, end: bandEnd));
      bandStart.add(const Duration(days: 1));
      bandEnd.add(const Duration(days: 1));
    }
    return bands;
  }

  onActualRangeChanged(ActualRangeChangedArgs args) {
    if (args.orientation == AxisOrientation.horizontal) {
      // todo: try removing this condition
      if (!isLoadingMore) {
        axisVisibleMin = DateTime.fromMillisecondsSinceEpoch(args.visibleMin);
        axisVisibleMax = DateTime.fromMillisecondsSinceEpoch(args.visibleMax);
      }
      isLoadingMore = false;
    }
  }

// todo: use FutureBuilder
// Widget getLoadMoreViewBuilder(
//     BuildContext context, ChartSwipeDirection direction) {
//   if (direction == ChartSwipeDirection.start) {
//     isLoadingMore = true;
//     fetchPreviousDay();
//     return const CircularProgressIndicator();
//   }
// }
}
