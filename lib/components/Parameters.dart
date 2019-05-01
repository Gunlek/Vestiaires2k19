import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Parameters extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Paramètres"),
            backgroundColor: Colors.green
        ),
        body: ParametersForm()
    );
  }

}

class ParametersForm extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ParametersFormState();
  }

}

class ParametersFormState extends State<ParametersForm> {

  bool _darkMode = false;

  initState() {
    super.initState();
    _isDarkMode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Mode sombre '),
              Switch(
                value: _darkMode,
                onChanged: (value){
                  this.setState((){
                    _darkMode = value;
                    _saveDarkModeSetting(_darkMode);
                  });
                }
              )
            ]
          ),
          Text('(prendra effet au redémarrage)'),
          Text('Vestiaire par défaut')
        ]
      )
    );
  }

  _saveDarkModeSetting(_darkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("darkMode", _darkMode);
  }

  _isDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool darkMode = prefs.getBool("darkMode") != null ? prefs.getBool("darkMode") : false;
    this.setState((){
      _darkMode = darkMode;
    });
  }
}