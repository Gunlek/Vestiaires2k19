import 'package:app_vestiaires/MainDrawer.dart';
import 'package:app_vestiaires/components/ViewCloakroom.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:app_vestiaires/components/BelongingsAdder.dart';
import 'package:app_vestiaires/components/BelongingsGetter.dart';
import 'package:app_vestiaires/utils/database_helper.dart';

/*
  This is the class for the main menu
  It handles cloakroom listing, providing a menu to access cloakrooms
 */
GlobalKey<_MenuState> globalKey = GlobalKey();

class MainMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vestiaire 2019 - Menu'),
        backgroundColor: Colors.green,
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () {
                  globalKey.currentState._gatherCloakroomList();
                }),
          ]
      ),
      floatingActionButton:Container(
        padding: EdgeInsets.only(left:30.0),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white,),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BelongingsAdder()));
                },
                heroTag: null,
                            ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                child: Icon(Icons.remove,color: Colors.white,),
                onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BelongingsGetter()));
                  },

              ),
            )
    ]
        ),
      ),


      body: MenuStateful(key: globalKey),
      drawer: Drawer(
        child: MainDrawer()
      ),
    );
  }

}



class MenuStateful extends StatefulWidget {

  MenuStateful({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();


}

class _MenuState extends State<MenuStateful> {

  DatabaseHelper db = DatabaseHelper();

  Map<dynamic, dynamic> cloakroomList = Map();
  Map<dynamic, MaterialColor> cloakroomColors = Map();
  Map<String, MaterialColor> colors = Map();

  bool progressActive = true;

  List<Widget> cloakrooms = List();

  @override
  void initState() {
    _gatherColors();
    super.initState();
    _gatherCloakroomList();
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
      return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          padding: EdgeInsets.all(20.0),
          children: this.cloakrooms
      );
    }
  }

  Widget _generateCloakroomButton(BuildContext context, String cloakroomKey, String cloakroomName, Color color, String capacity){
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
                  Text(cloakroomName, style: TextStyle(color: color)),
                  Text(capacity, style: TextStyle(color: color)),
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
    this.progressActive = true;
    var conn = await db.database;
    var results = await conn.query("SELECT cloakroom_name, cloakroom_key, cloakroom_color FROM cloakrooms");
    Map<dynamic, MaterialColor> cloakroomColor = new Map();
    Map<dynamic, dynamic> cloakroomMap = new Map();
    Map<dynamic, dynamic> cloakroomCapacity = new Map();
    //List<String> capacity;
    for(mysql.Row row in results){
      cloakroomMap.putIfAbsent(row[1].toString(), () => row[0].toString());
      cloakroomColor.putIfAbsent(row[1], () => this.colors[row[2]]);

      //var results2 = await conn.query('SELECT COUNT(*) FROM belongings, cloakrooms JOIN ON cloakroom_key WHERE cloakroom_name = ?', []);
      var results2 = await conn.query('SELECT COUNT(*) FROM belongings WHERE belongings_cloakroom = ?', [row[1]]);
      List total = results2.toString().split(""":""");
      String clearedText = total[2].split('''}''')[0];
      cloakroomCapacity.putIfAbsent(row[1].toString(), () => clearedText);

    }

    List<Widget> tempCloakroomsWidget = List();
    cloakroomMap.forEach((cloakroomKey, cloakroomName) {
      tempCloakroomsWidget.add(_generateCloakroomButton(context, cloakroomKey, cloakroomName, cloakroomColor[cloakroomKey], cloakroomCapacity[cloakroomKey]));
    });

    this.setState((){
      this.cloakroomList = cloakroomMap;
      this.cloakroomColors = cloakroomColor;
      this.cloakrooms = tempCloakroomsWidget;
      this.progressActive = false;
    });
  }



}