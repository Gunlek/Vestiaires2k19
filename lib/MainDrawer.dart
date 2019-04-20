import 'package:app_vestiaires/components/BelongingsAdder.dart';
import 'package:app_vestiaires/components/BelongingsGetter.dart';
import 'package:app_vestiaires/components/Parameters.dart';
import 'package:flutter/material.dart';

/*
  This is the MainDrawer class
  It provides a drawer to access QRCode, BarCode and ManualCode links
 */
class MainDrawer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MainDrawerState();
  }

}

class MainDrawerState extends State<MainDrawer> {

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            Image(
                image: AssetImage('assets/fignoss.png'),
                width: 150
            ),
            FlatButton(
              child: Text('Ajouter dans un vestiaire'),
              onPressed: () {
                _openBelongingsAdder(context);
              }
            ),
            FlatButton(
                child: Text('Récupérer depuis un vestiaire'),
                onPressed: () {
                  _openBelongingsGetter(context);
                }
            ),
            FlatButton(
                child: Text('Paramètres'),
                onPressed: () {
                  _openParams(context);
                }
            ),
          ]
      )
    );
  }

  _openBelongingsAdder(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BelongingsAdder()));
  }

  _openBelongingsGetter(context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => BelongingsGetter()));
  }

  _openParams(context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => Parameters()));
  }

}