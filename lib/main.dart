import 'package:app_vestiaires/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyAppStateful();
  }
}

class MyAppStateful extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }

}

class MyAppState extends State<MyAppStateful> {

  bool _darkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vestiaires 2019',
      theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: _darkMode ? Brightness.dark : Brightness.light
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Vestiaire 2019'),
            backgroundColor: Colors.green,
          ),
          body: LoginPage()
      ),
    );
  }

  _isDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool darkMode = prefs.getBool("darkMode") != null ? prefs.getBool("darkMode") : false;
    this.setState((){
      _darkMode = darkMode;
    });
  }

}