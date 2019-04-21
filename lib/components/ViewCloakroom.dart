import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;

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

  List<String> belongings;
  String cloakroomKey;
  bool progressActive = true;

  BelongingsListingState(String ckk){
    this.cloakroomKey = ckk;
  }

  @override
  void initState() {
    super.initState();
    _getBelongings();
  }

  Future<String> _getBelongings() async {
    this.progressActive = true;
    List<String> currentBelongings = new List();
    var settings = new mysql.ConnectionSettings(
        host: '91.121.135.77',
        port: 3306,
        user: 'vestiaires_2k19',
        password: 'emL3xC7jKCx7Nb5n',
        db: 'vestiaires_2k19'
    );
    var conn = await mysql.MySqlConnection.connect(settings);
    var results = await conn.query("SELECT * FROM belongings INNER JOIN cloakrooms ON belongings.belongings_cloakroom = cloakrooms.cloakroom_key WHERE cloakrooms.cloakroom_key=?", [this.cloakroomKey]);
    for(var row in results){
      String rowStr = row[3]; // belongings_number
      rowStr += " - ";        // Separator
      rowStr += row[1];       // belongings_type
      rowStr += " - ";        // Separator
      rowStr += row[4];       // belonging_location
      rowStr += " - ";        // Separator
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
                    onPressed: () {}
                )
            );
          }
      );
    }
  }

}