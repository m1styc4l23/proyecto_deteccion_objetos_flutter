import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DBProvider extends ChangeNotifier{

  DBProvider();

  static Database? _database;

  static final DBProvider db = DBProvider._();
  DBProvider._();

  Future<Database> get database async {

    if ( _database != null ) return _database!;

    return _database = await initDB();

  }

  Future<Database> initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join( documentsDirectory.path, 'yolo_ubosque' );

    return await openDatabase(
      path,
      password: 'ubosque',
      version: 1,
      onOpen: (db) {},
      onCreate: ( Database db, int version ) async {
        await db.execute(""" CREATE TABLE IF NOT EXISTS conteo
                                ( fecha TEXT, conteo TEXT ) """);
      },
      onUpgrade: ( Database db, int oldVersion, int newVersion ) async {

        await db.execute("""
                          DROP TABLE IF EXISTS conteo
                        """);

      }
    );

  }

}