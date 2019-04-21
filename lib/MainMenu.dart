import 'package:app_vestiaires/MainDrawer.dart';
import 'package:app_vestiaires/components/ViewCloakroom.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;

/*
  This is the class for the main menu
  It handles cloakroom listing, providing a menu to access cloakrooms
 */
class MainMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vestiaire 2019 - Menu'),
        backgroundColor: Colors.green,
      ),
      body: Menu(),
      drawer: Drawer(
        child: MainDrawer()
      ),
    );
  }

}

class Menu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MenuStateful();
  }


}

class MenuStateful extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MenuState();
  }

}

class MenuState extends State<MenuStateful> {

  Map<dynamic, dynamic> cloakroomList = Map();
  Map<dynamic, MaterialColor> cloakroomColors = Map();
  Map<String, MaterialColor> colors = Map();

  List<Widget> cloakrooms = List();

  @override
  void initState() {
    _gatherColors();
    super.initState();
    _gatherCloakroomList();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        padding: EdgeInsets.all(20.0),
        children: this.cloakrooms
    );
  }

  Widget _generateCloakroomButton(BuildContext context, String cloakroomKey, String cloakroomName, Color color){
    return Container(
        width: double.infinity,
        color: Colors.black12,
        child: FlatButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCloakroom(cloakroomKey, cloakroomName, color)));
            },
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    tooltip: cloakroomName,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCloakroom(cloakroomKey, cloakroomName, color)));
                    },
                  ),
                  Text(cloakroomName, style: TextStyle(color: color))
                ]
            )
        )
    );
  }

  _gatherColors(){
    this.colors.putIfAbsent("red", () => Colors.red);
    this.colors.putIfAbsent("green", () => Colors.green);
    this.colors.putIfAbsent("blue", () => Colors.blue);
    this.colors.putIfAbsent("amber", () => Colors.amber);
    this.colors.putIfAbsent("yellow", () => Colors.yellow);
  }

  _gatherCloakroomList() async {
    var settings = new mysql.ConnectionSettings(
        host: 'ftp.simple-duino.com',
        port: 3306,
        user: 'vestiaires_2k19',
        password: 'emL3xC7jKCx7Nb5n',
        db: 'vestiaires_2k19'
    );
    var conn = await mysql.MySqlConnection.connect(settings);
    var results = await conn.query("SELECT cloakroom_name, cloakroom_key, cloakroom_color FROM cloakrooms");
    Map<dynamic, MaterialColor> cloakroomColor = new Map();
    Map<dynamic, dynamic> cloakroomMap = new Map();
    for(mysql.Row row in results){
      cloakroomMap.putIfAbsent(row[1].toString(), () => row[0].toString());
      cloakroomColor.putIfAbsent(row[1], () => this.colors[row[2]]);
    }

    List<Widget> tempCloakroomsWidget = List();
    cloakroomMap.forEach((cloakroomKey, cloakroomName) {
      tempCloakroomsWidget.add(_generateCloakroomButton(context, cloakroomKey, cloakroomName, cloakroomColor[cloakroomKey]));
    });

    this.setState((){
      this.cloakroomList = cloakroomMap;
      this.cloakroomColors = cloakroomColor;
      this.cloakrooms = tempCloakroomsWidget;
    });
  }

}