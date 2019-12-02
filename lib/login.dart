import 'package:app_vestiaires/MainMenu.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    return LoginPageStateful();
  }

}

class LoginPageStateful extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }

}

class LoginPageState extends State<LoginPageStateful> {

  List<DropdownMenuItem> cloakroomName;
  Map<String, String> cloakroomAssociation;
  String cloakroom;
  bool progressActive = true;

  @override
  void initState() {
    super.initState();
    _gatherCloakroomList();
  }

  @override
  Widget build(BuildContext context) {
    if(this.progressActive)
      return _loadingPage(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffecf0f1), Color(0xffbdc3c7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0]
        )
      ),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/fignoss_alpha.png')
          ),
          Text('Choisissez votre vestiaire: '),
          DropdownButton(
            items: this.cloakroomName,
            value: this.cloakroom,
            onChanged: (value) {
              setState(() {
                this.cloakroom = value;
              });
            },
          ),
          RaisedButton(
            child: Text("Commencer ma rotance", style: TextStyle(color: Color(0xffeeeeee))),
            color: Color(0xff2980b9),
            onPressed: () {
              _loginUser(this.cloakroom);
            }
          )
        ]
      )
    );
  }

  _loginUser(String cloakroomKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currentUserCloakroomKey", cloakroomKey);
    prefs.setString("currentUserCloakroom", this.cloakroomAssociation[cloakroomKey]);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainMenu()));
  }

  Widget _loadingPage(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffecf0f1), Color(0xffbdc3c7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0]
        )
      ),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [CircularProgressIndicator()]
      )
    );
  }

  _gatherCloakroomList() async {
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
    await conn.close();

    this.setState((){
      this.cloakroom = cloakroomList.length > 0 ? cloakroomList[0].value : null;
      this.cloakroomAssociation = cloakroomAssociation;
      this.cloakroomName = cloakroomList;
      this.progressActive = false;
    });
  }

}