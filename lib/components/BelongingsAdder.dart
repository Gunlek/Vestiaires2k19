import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';


class User {
  const User(this.name);

  final String name;
}


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

class BelongingsAdderFormState extends State<BelongingsAdderForm> {

  TextEditingController CodeController = new TextEditingController();
  TextEditingController LocationController = new TextEditingController();
  TextEditingController DescController = new TextEditingController();
  TextEditingController CloakroomController = new TextEditingController();
  TextEditingController InfoController = new TextEditingController();

  User selectedUser;
  List<User> users = <User>[const User('rouge'), const User('vert'), const User('bleu'), const User('jaune')];

  final _formKey = GlobalKey<FormState>();

  String _currentUser;
  String _currentUserProms;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Code:'),
                  TextFormField(
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


                  DropdownButton<User>(
                    hint: new Text("Select a Vestiaire"),
                    value: selectedUser,
                    onChanged: (User newValue) {
                      setState(() {
                        selectedUser = newValue;
                      });
                    },
                    items: users.map((User user) {
                      return new DropdownMenuItem<User>(
                        value: user,
                        child: new Text(
                          user.name,
                          style: new TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),



                  Padding(padding: EdgeInsets.all(10.0)),

                  Text('Emplacement:'),
                  // FIXME: Location could be a List too...
                  //NO: keep keyboard with uppercase
                  TextFormField(
                    controller: LocationController,
                    textCapitalization: TextCapitalization.characters,
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
                              host: 'ftp.simple-duino.com',
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
                              await conn.query('INSERT INTO belongings(belongings_type, belongings_cloakroom, belongings_number, belongings_location, belongings_info) VALUES(?, ?, ?, ?, ?)', [DescController.text, cloakroomKey, CodeController.text, LocationController.text, InfoController.text]);
                              await conn.query('INSERT INTO logger(log_timestamp, log_info) VALUES(?, ?)', [DateTime.now().toString(), _currentUser + " from prom's " + _currentUserProms + " added belongings on " + CloakroomController.text + " id_tag: #" + CodeController.text]);
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

  _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUser = prefs.getString("currentUser");
    String currentUserProms = prefs.getString("currentUserProms");
    setState(() {
      _currentUser = currentUser;
      _currentUserProms = currentUserProms;
    });
  }

}