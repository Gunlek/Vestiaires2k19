import 'package:app_vestiaires/MainDrawer.dart';
import 'package:app_vestiaires/components/ViewCloakroom.dart';
import 'package:flutter/material.dart';

/*
  This is the class for the main menu
  It handles cloakroom listing, providing a menu to access cloakrooms
 */
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
        _generateLockerButton(context, Cloakroom.RED),
        _generateLockerButton(context, Cloakroom.GREEN),
        _generateLockerButton(context, Cloakroom.BLUE),
        _generateLockerButton(context, Cloakroom.YELLOW)
      ]
    );
  }

  Widget _generateLockerButton(BuildContext context, Cloakroom cloakroom){
    String btnText = "";
    Color btnColor = Colors.black;
    switch(cloakroom){
      case Cloakroom.RED:
        btnText = "Vestiaire rouge";
        btnColor = Colors.red;
        break;

      case Cloakroom.GREEN:
        btnText = "Vestiaire vert";
        btnColor = Colors.green;
        break;

      case Cloakroom.BLUE:
        btnText = "Vestiaire bleu";
        btnColor = Colors.blue;
        break;

      case Cloakroom.YELLOW:
        btnText = "Vestiaire jaune";
        btnColor = Colors.amber;
        break;
    }

    return Container(
      width: double.infinity,
      color: Colors.black12,
      child: FlatButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCloakroom(cloakroom)));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_forward),
              tooltip: btnText,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCloakroom(cloakroom)));
              },
            ),
            Text(btnText, style: TextStyle(color: btnColor))
          ]
        )
      )
    );
  }
}