import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';

class BelongingsAdder extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text('Ajout d\'affaires dans un vestiaire')
        ),
        body: BelongingsAdderForm()
    );
  }

}

class BelongingsAdderForm extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return BelongingsAdderFormState();
  }

}

enum ObjectType { Manteau, Sac }

class BelongingsAdderFormState extends State<BelongingsAdderForm> {

  TextEditingController CodeController = new TextEditingController();
  TextEditingController LocationController = new TextEditingController();
  TextEditingController CloakroomController = new TextEditingController();
  TextEditingController InfoController = new TextEditingController();

  String _description = "Manteau";

  FocusNode codeFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  String _cloakroom;
  String _userCloakroomName;
  Future<String> cloakroomRecoverState;
  List<String> cloakroomList = List();

  @override
  void initState() {
    super.initState();
    this.cloakroomRecoverState = _getCloakroomList();
    _getUserCloakroom();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Code:'),
                    TextFormField(
                      focusNode: this.codeFocusNode,
                      controller: this.CodeController,
                      keyboardType: TextInputType.number,
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
                          String _barcodeString = await BarcodeScanner.scan();
                          this.CodeController.text = _barcodeString;
                        });
                      },
                    ),

                    Padding(padding: EdgeInsets.all(10.0)),

                    Text('Description de l\'objet:'),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: RadioListTile<String>(
                              title: Text('Manteau'),
                              value: "Manteau",
                              groupValue: _description,
                              onChanged: (String value) {
                                setState(() {
                                  _description = value;
                                });
                              }
                            )
                          ),
                          Flexible(
                              child: RadioListTile<String>(
                                  title: Text('Sac'),
                                  value: "Sac",
                                  groupValue: _description,
                                  onChanged: (String value) {
                                    setState(() {
                                      _description = value;
                                    });
                                  }
                              )
                          ),
                        ]
                      )
                    ),

                    Padding(padding: EdgeInsets.all(10.0)),

                    Text('Vestiaire: '),
                    FutureBuilder(
                      future: this.cloakroomRecoverState,
                      builder: (BuildContext context, AsyncSnapshot snapshot){
                        return Container(
                          width: double.infinity,
                            child: DropdownButton(
                              isExpanded: true,
                              hint: new Text("Spécifiez un vestiaire"),
                              value: this._cloakroom,
                              onChanged: (value) {
                                setState(() {
                                  this._cloakroom = value;
                                });
                              },
                              items: this.cloakroomList.map((String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Container(
                                    child: Text(
                                      value
                                    ),
                                  )
                                );
                              }).toList(),
                            )
                        );
                      }
                    ),

                    Padding(padding: EdgeInsets.all(10.0)),

                    Text('Emplacement:'),
                    TextFormField(
                      controller: LocationController,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value){
                        if(value.isEmpty)
                          return "Spécifiez un emplacement";
                      }
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
                                host: 'ftp.simple-duino.com',
                                port: 3306,
                                user: 'vestiaires_2k19',
                                password: 'emL3xC7jKCx7Nb5n',
                                db: 'vestiaires_2k19'
                            );
                            var conn = await mysql.MySqlConnection.connect(settings);
                            var results = await conn.query("SELECT cloakroom_key FROM cloakrooms WHERE cloakroom_name = ?", [this._cloakroom]);
                            if(results.length > 0){
                              var resultRow = results.elementAt(0);
                              String cloakroomKey = resultRow[0];
                              //var checkIfOccupied = await conn.query('SELECT * FROM belongings WHERE belongings_cloakroom = ? AND belongings_location = ?', [cloakroomKey, LocationController.text]);

                              await conn.query('INSERT INTO belongings(belongings_type, belongings_cloakroom, belongings_number, belongings_location, belongings_info) VALUES(?, ?, ?, ?, ?)', [this._description, cloakroomKey, CodeController.text, LocationController.text, InfoController.text]);
                                Scaffold.of(context).hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Objet ajouté'), backgroundColor: Colors.green));

                                //clear on board data
                                this._description = "Manteau";
                                CodeController.clear();
                                LocationController.clear();
                                InfoController.clear();

                                FocusScope.of(context).requestFocus(this.codeFocusNode);

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
              ),
            )
        )
    );
  }

  Future<String> _getCloakroomList() async {
    var settings = new mysql.ConnectionSettings(
        host: 'ftp.simple-duino.com',
        port: 3306,
        user: 'vestiaires_2k19',
        password: 'emL3xC7jKCx7Nb5n',
        db: 'vestiaires_2k19'
    );
    var conn = await mysql.MySqlConnection.connect(settings);
    var results = await conn.query("SELECT cloakroom_name FROM cloakrooms");
    List<String> tempCloakroomList = List();
    for(mysql.Row row in results){
      tempCloakroomList.add(row[0]);
    }
    setState((){
      this.cloakroomList = tempCloakroomList;
    });

    return "Success";
  }

  _getUserCloakroom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserCloakroom = prefs.getString("currentUserCloakroom");
    String currentUserCloakroomKey = prefs.getString("currentUserCloakroomKey");
    setState(() {
      this._userCloakroomName = currentUserCloakroom;
      this._cloakroom = this._userCloakroomName;
    });
  }

}