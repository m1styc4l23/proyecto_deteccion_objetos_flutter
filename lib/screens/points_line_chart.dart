/// Line chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../provider/grafica_provider.dart';

_getSeriesData() {
  List<charts.Series<SalesData, DateTime>> series = [
    charts.Series(
        id: "Conteo",
        data: data,
        domainFn: (SalesData series, _) => series.year,
        measureFn: (SalesData series, _) => series.conteo,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault
    )
  ];
  return series;
}


class PointsLineChartScreen extends StatelessWidget {

  String messageTopic;

  PointsLineChartScreen({Key? key, required this.messageTopic}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final conteoProvider = Provider.of<GraficaProvider>(context);

    return FutureBuilder(
      future: conteoProvider.insertDatabase(messageTopic),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if ( snapshot.hasData && snapshot.connectionState == ConnectionState.done ) {

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.9,
            child: charts.TimeSeriesChart(_getSeriesData(),
                animate: true,
                defaultRenderer: charts.LineRendererConfig(),
                dateTimeFactory: const charts.LocalDateTimeFactory(),),

          );
        } else {
          return const CircularProgressIndicator();
        }

      }
    );
  }
}