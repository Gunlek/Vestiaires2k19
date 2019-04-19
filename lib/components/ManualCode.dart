import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class BarCode extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text('Système BarCode')
        ),
        body: BarCodeForm()
    );
  }

}

class BarCodeForm extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return BarCodeFormState();
  }

}

class BarCodeFormState extends State<BarCodeForm> {

  TextEditingController BarCodeController = new TextEditingController();
  TextEditingController LocationController = new TextEditingController();
  TextEditingController DescController = new TextEditingController();
  TextEditingController CloakroomController = new TextEditingController();
  TextEditingController InfoController = new TextEditingController();
  Future<String> _barcodeString;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Barcode:'),
                  FutureBuilder<String>(
                      future: _barcodeString,
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                        this.BarCodeController.text = snapshot.data != null ? snapshot.data : '';
                        return TextFormField(
                            controller: this.BarCodeController,
                            enabled: false
                        );
                      }
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    child: Container(
                        width: double.infinity,
                        child: Center(child: Text('Scanner un code barre', style: TextStyle(color: Colors.white)))
                    ),
                    onPressed: (){
                      setState(() async {
                        String _barcodeString = await BarcodeScanner.scan();
                        this.BarCodeController.text = _barcodeString;
                      });
                    },
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  Text('Description de l\'objet:'),
                  TextFormField(
                    controller: DescController,
                    validator: (value){
                      if(value.isEmpty)
                        return "Spécifiez une description valide";
                    },
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  Text('Vestiaire: '),
                  // FIXME: Vestiaire is not a TextFormField, it's a list
                  TextFormField(
                    controller: CloakroomController,
                    validator: (value){
                      if(value.isEmpty)
                        return "Spécifiez un vestiaire";
                    },
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  Text('Emplacement:'),
                  // FIXME: Location could be a List too...
                  TextFormField(
                    controller: LocationController,
                    validator: (value){
                      if(value.isEmpty)
                        return "Spécifiez un emplacement";
                    },
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  Text('Informations supplémentaires:'),
                  TextFormField(
                    controller: InfoController,
                    validator: (value){},
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  RaisedButton(
                      color: Colors.green,
                      onPressed: () async {
                        if(_formKey.currentState.validate()){
                          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Ajout en cours...')));
                          var settings = new mysql.ConnectionSettings(
                              host: '91.121.135.77',
                              port: 3306,
                              user: 'vestiaires_2k19',
                              password: 'emL3xC7jKCx7Nb5n',
                              db: 'vestiaires_2k19'
                          );
                          var conn = await mysql.MySqlConnection.connect(settings);
                          var results = await conn.query("SELECT cloakroom_key FROM cloakrooms WHERE cloakroom_name = ?", [CloakroomController.text]);
                          if(results.length > 0){
                            var resultRow = results.elementAt(0);
                            String cloakroomKey = resultRow[0];
                            var checkIfOccupied = await conn.query('SELECT * FROM belongings WHERE belongings_cloakroom = ? AND belongings_location = ?', [cloakroomKey, LocationController.text]);
                            if(checkIfOccupied.length > 0) {
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Emplacement déjà enregistré'), backgroundColor: Colors.red));
                            }
                            else {
                              await conn.query('INSERT INTO belongings(belongings_type, belongings_cloakroom, belongings_number, belongings_location, belongings_info) VALUES(?, ?, ?, ?, ?)', [DescController.text, cloakroomKey, BarCodeController.text, LocationController.text, InfoController.text]);
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Objet ajouté'), backgroundColor: Colors.green));
                            }
                          }
                          else {
                            Scaffold.of(context).hideCurrentSnackBar();
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Vestiaire inconnu'), backgroundColor: Colors.red));
                          }
                        }
                      },
                      child: Container(width: double.infinity, child: Center(child: Text('Ajouter au vestiaire', style: TextStyle(color: Colors.white))))
                  )

                ]
            )
        )
    );
  }

}