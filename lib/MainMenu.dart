import 'package:app_vestiaires/MainDrawer.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vestiaire 2019 - Menu'),
        backgroundColor: Colors.green,
      ),
      body: Menu(),
      drawer: Drawer(
        child: MainDrawer()
      ),
    );
  }

}

class Menu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      padding: EdgeInsets.all(20.0),
      children: <Widget>[
        _generateLockerButton('red'),
        _generateLockerButton('green'),
        _generateLockerButton('blue'),
        _generateLockerButton('yellow')
      ]
    );
  }

  Widget _generateLockerButton(String lockerColor){
    String btnText = "";
    Color btnColor = Colors.black;
    switch(lockerColor){
      case 'red':
        btnText = "Vestiaire rouge";
        btnColor = Colors.red;
        break;

      case 'green':
        btnText = "Vestiaire vert";
        btnColor = Colors.green;
        break;

      case 'blue':
        btnText = "Vestiaire bleu";
        btnColor = Colors.blue;
        break;

      case 'yellow':
        btnText = "Vestiaire jaune";
        btnColor = Colors.amber;
        break;
    }

    return Container(
      width: double.infinity,
      color: Colors.black12,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_forward),
              tooltip: btnText,
              onPressed: () {
                _openLocker(lockerColor);
              },
            ),
            Text(btnText, style: TextStyle(color: btnColor))
          ]
      )
    );

    /*return Container(
        width: double.infinity,
        color: Colors.black12,
        child: FlatButton(
            child: Column(
                children: <Widget>[
                  Text(btnText, style: TextStyle(backgroundColor: Colors.amber))
                ]
            ),
            onPressed: () {
              _openLocker(lockerColor);
            }
        )
    );*/
  }

  _openLocker(String lockerColor){

  }
}