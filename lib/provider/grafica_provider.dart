
import 'package:flutter/cupertino.dart';
import 'package:yolo_subs/database/db_provider.dart';

class GraficaProvider extends ChangeNotifier {

  late List<Map<String, dynamic>> dataConteo = [];

  Future insertDatabase(String messageMqtt) async {

    try {
      final db = await DBProvider.db.database;


      var mosquitto = messageMqtt.split(',');

      //insert
      await db.insert('conteo', {
        'fecha': mosquitto[1],
        'conteo': mosquitto[0],
      });

      // db.delete('conteo');

      //select
      final List<Map<String, dynamic>> listaConteo = await db.rawQuery("""
                                                                        SELECT fecha, conteo FROM conteo
                                                                      """);

      print(listaConteo);

      data.clear();

      List.generate(listaConteo.length, (index) {

        String fecha = listaConteo[index]['fecha'].toString();

        DateTime parsedDate = DateTime.parse(fecha.trim());

        data.add(SalesData(
          parsedDate,
          int.parse(listaConteo[index]['conteo']),
        ));

      });

      return listaConteo;

    } catch ( e ) {
      print('lol $e');
      throw('Error insert conteo');
    }

  }

}

class SalesData {
  final DateTime year;
  final int conteo;

  SalesData(this.year, this.conteo);
}

final data = [
  SalesData( DateTime.parse('2022-05-13 00:32:48.942153'), 1),
];