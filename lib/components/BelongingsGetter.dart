import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:app_vestiaires/components/Dialogs.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:app_vestiaires/utils/database_helper.dart';

class BelongingsGetter extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Récupérer une affaire"),
        backgroundColor: Colors.green,
      ),
      body: BelongingsGetterForm(),
    );
  }

}

class BelongingsGetterForm extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return BelongingsGetterFormState();
  }

}

class BelongingsGetterFormState extends State<BelongingsGetterForm> {

  DatabaseHelper db = DatabaseHelper();

  final _formkey = GlobalKey<BelongingsGetterFormState>();
  FocusNode codeFocusNode = FocusNode();

  TextEditingController CodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Code:'),
            TextFormField(
                keyboardType: TextInputType.number,
                focusNode: codeFocusNode,
                controller: CodeController,
                validator: (value){
                  if(value.isEmpty)
                    return "Vous devez scanner un code pour récupérer l'objet";
                }
            ),
            RaisedButton(
              color: Colors.blue,
              child: Container(
                width: double.infinity,
                child: Center(child: Text('Scanner un code', style: TextStyle(color: Colors.white)))
              ),
              onPressed: (){
                setState(() async {
                  String _barcodeString = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666",
                      "Cancel",
                      true,
                      ScanMode.BARCODE);
                  this.CodeController.text = _barcodeString;
                });
              },
            ),

            Padding(padding: EdgeInsets.all(10.0)),

            RaisedButton(
              color: Colors.green,
              child: Container(
                width: double.infinity,
                child: Center(child: Text('Récupérer les informations', style: TextStyle(color: Colors.white)))
              ),
              onPressed: (){
                _gatherBelongingsData(this.CodeController.text);
              },
            )
          ]
        )
      )
    );
  }

  _gatherBelongingsData(String code) async {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Recherche en cours")));
    var conn = await db.database;
    var results = await conn.query('SELECT * FROM belongings WHERE belongings_number = ?', [code]);
    if(results.length > 0){
      var row = results.elementAt(0);
      var cloakroom = await conn.query('SELECT cloakroom_name FROM cloakrooms WHERE cloakroom_key = ?', [row[2]]);
      List<String> rowList = new List();
      for(var el in row)
        rowList.add(el.toString());
      rowList.add(cloakroom.elementAt(0)[0]);
      FocusScope.of(context).requestFocus(new FocusNode());
      Dialogs().information(context, rowList, this.codeFocusNode);
      CodeController.clear();
      Scaffold.of(context).hideCurrentSnackBar();
    }
    else {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Code inccnnu"), backgroundColor: Colors.red));
    }
  }

}