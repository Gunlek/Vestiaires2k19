import 'dart:async';
import 'package:mysql1/mysql1.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static MySqlConnection _database; // Singleton Database


  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<MySqlConnection> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<MySqlConnection> initializeDatabase() async {
    // Open a connection (testdb should already exist)
    //print(DotEnv().env['DB_HOST']);
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'ftp.simple-duino.com',
        port: 3306,
        user: 'vestiaires_2k19',
        password: 'emL3xC7jKCx7Nb5n',
        db: 'vestiaires_2k19'));
    return conn;
  }

  void dispose() async {
    //todo: call dispose method
    await _database.close();
  }

  String executeQuery() {
    return "Bullshit";
  }

}