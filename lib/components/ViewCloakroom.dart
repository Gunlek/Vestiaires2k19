import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:app_vestiaires/components/Dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_vestiaires/utils/database_helper.dart';

enum Cloakroom {RED, GREEN, BLUE, YELLOW}

class ViewCloakroom extends StatelessWidget {

  String cloakroomTitle;
  String cloakroomKey;
  Color cloakroomColor;

  ViewCloakroom(String cloakroomKey, String cloakroomName, Color cloakroomColor){
    this.cloakroomKey = cloakroomKey;
    this.cloakroomTitle = cloakroomName;
    this.cloakroomColor = cloakroomColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: this.cloakroomColor,
        title: Text(this.cloakroomTitle)
      ),

      body: BelongingsListing(this.cloakroomKey)

    );
  }
}

class BelongingsListing extends StatefulWidget {

  String cloakroomKey;

  BelongingsListing(String ckk){
    this.cloakroomKey = ckk;
  }

  @override
  State<StatefulWidget> createState() {
    return BelongingsListingState(cloakroomKey);
  }

}

class BelongingsListingState extends State<BelongingsListing> {

  DatabaseHelper db = DatabaseHelper();

  List<String> belongings;
  String cloakroomKey;
  bool progressActive = true;

  String _currentUser;
  String _currentUserProms;

  BelongingsListingState(String ckk){
    this.cloakroomKey = ckk;
  }

  void onPress(String id) {
    print('pressed $id');
    _gatherBelongingsData(id);
  }
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getBelongings();
  }

  Future<String> _getBelongings() async {
    this.progressActive = true;
    List<String> currentBelongings = new List();
    var conn = await db.database;
    var results = await conn.query("SELECT * FROM belongings INNER JOIN cloakrooms ON belongings.belongings_cloakroom = cloakrooms.cloakroom_key WHERE cloakrooms.cloakroom_key=? ORDER BY belongings_number", [this.cloakroomKey]);
    for(var row in results){
      String rowStr = row[3]; // belongings_number
      rowStr += " - ";        // Separator
      rowStr += row[1];       // belongings_type
      rowStr += " - ";        // Separator
      rowStr += row[4];       // belonging_location
      rowStr += row[5] == "" ? "" : " - ";        // Separator
      rowStr += row[5];       // belongings_info
      currentBelongings.add(rowStr);
    }

    if(this.mounted) {
      this.setState(() {
        this.progressActive = false;
        this.belongings = currentBelongings;
      });
    }

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    if(this.progressActive){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: CircularProgressIndicator()
          )
        ]
      );
    }
    else {
      return ListView.builder(
          padding: EdgeInsets.all(0.0),
          itemExtent: 35.0,
          itemCount: this.belongings == null ? 0 : this.belongings.length,
          itemBuilder: (BuildContext context, int index){
            return Container(
                width: double.infinity,
                decoration: new BoxDecoration(
                    border: new Border(bottom: BorderSide(color: Colors.black))
                ),
                child: FlatButton(
                    child: Container(width: double.infinity, child:Center(child:Text(this.belongings[index]))),
                    onPressed: () {
                      String currentNumber;
                      currentNumber = this.belongings[index].split("-")[0];
                      onPress(currentNumber);}
                )
            );
          }
      );
    }
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
      //rowList.add(_currentUser);
      //rowList.add(_currentUserProms);
      print(_currentUser.toString() + _currentUserProms.toString());
      await conn.query('INSERT INTO logger(log_timestamp, log_info) VALUES(?, ?)', [DateTime.now().toString(), " an user" + " searched for belongings with id_tag: #" + code]);
      FocusScope.of(context).requestFocus(new FocusNode());
      Dialogs().information(context, rowList, null);
      Scaffold.of(context).hideCurrentSnackBar();
    }
    else {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Code inccnnu"), backgroundColor: Colors.red));
    }
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