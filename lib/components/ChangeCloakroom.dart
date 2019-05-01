import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';

class ChangeCloakroom extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeCloakroomStateful();
  }

}

class ChangeCloakroomStateful extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ChangeCloakroomState();
  }

}

class ChangeCloakroomState extends State<StatefulWidget> {

  Future<String> cloakroomRecoverState;
  List<DropdownMenuItem> cloakroomList;
  Map<String, String> cloakroomAssociation;
  bool progressActive = true;

  String _cloakroom;

  @override
  void initState() {
    super.initState();
    this._gatherCloakroomList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Changer de vestiaire'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xffecf0f1), Color(0xffbdc3c7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0]
          )
        ),
        child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modifier le vestiaire auquel vous êtes affecté: '),
                DropdownButton(
                  items: this.cloakroomList,
                  value: this._cloakroom,
                  onChanged: (value) {
                    setState(() {
                      this._cloakroom = value;
                    });
                  },
                ),
                RaisedButton(
                  color: Colors.blue,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                        children: [
                          Text(
                            'Appliquer la modification',
                            style: TextStyle(color: Color(0xffeeeeee))
                          )
                        ]
                    )
                  ),
                  onPressed: () {
                    this._updateCloakroom(this._cloakroom);
                  },
                )
              ]
            )
        )
      )
    );
  }

  _updateCloakroom(String cloakroomKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currentUserCloakroomKey", cloakroomKey);
    prefs.setString("currentUserCloakroom", this.cloakroomAssociation[cloakroomKey]);
    Navigator.of(context).pop();
  }

  _gatherCloakroomList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentCloakroom = prefs.getString("currentUserCloakroomKey");
    this.progressActive = true;
    var settings = new mysql.ConnectionSettings(
        host: 'ftp.simple-duino.com',
        port: 3306,
        user: 'vestiaires_2k19',
        password: 'emL3xC7jKCx7Nb5n',
        db: 'vestiaires_2k19'
    );
    var conn = await mysql.MySqlConnection.connect(settings);
    var results = await conn.query("SELECT cloakroom_name, cloakroom_key, cloakroom_color FROM cloakrooms");
    List<DropdownMenuItem> cloakroomList = new List();
    Map<String, String> cloakroomAssociation = new Map();
    for(mysql.Row row in results){
      cloakroomList.add(DropdownMenuItem(child: Text(row[0]), value: row[1]));
      cloakroomAssociation.putIfAbsent(row[1], () => row[0]);
    }

    this.setState((){
      this._cloakroom = currentCloakroom;
      this.cloakroomAssociation = cloakroomAssociation;
      this.cloakroomList = cloakroomList;
      this.progressActive = false;
    });
  }

}