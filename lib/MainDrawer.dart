import 'package:app_vestiaires/components/BarCode.dart';
import 'package:app_vestiaires/components/ManualCode.dart';
import 'package:app_vestiaires/components/QRCode.dart';
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
    return Column(
        children: <Widget>[
          Image(
              image: AssetImage('assets/fignoss.png'),
              width: 150
          ),
          FlatButton(
            child: Text('Scanner un QR code'),
            onPressed: () {
              _openQRReader(context);
            }
          ),
          FlatButton(
            child: Text('Scanner un code barre'),
            onPressed: () {
              _openBarCodeReader(context);
            }
          ),
          FlatButton(
              child: Text('Entrer un code manuellement'),
              onPressed: () {
                _openManualCode(context);
              }
          )
        ]
    );
  }

  _openQRReader(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => QRCode()));
  }

  _openBarCodeReader(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BarCode()));
  }

  _openManualCode(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ManualCode()));
  }

}