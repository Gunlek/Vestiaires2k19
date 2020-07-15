import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:app_vestiaires/utils/database_helper.dart';

class Dialogs {

  information(BuildContext context, List<String> data, FocusNode codeFocusNode){
    /*
      data[0] => belongings_id
      data[1] => belongings_type
      data[2] => belongings_cloakroom
      data[3] => belongings_number
      data[4] => belongings_location
      data[5] => belongings_info
      data[6] => vestiaire_name
      data[7] => currentUser
      data[8] => currentUserProms
     */

    TextEditingController DescriptionController = TextEditingController(text: data[1]);
    TextEditingController CodeController = TextEditingController(text: data[3]);
    TextEditingController CloakroomController = TextEditingController(text: data[6]);
    TextEditingController LocationController = TextEditingController(text: data[4]);
    TextEditingController InfoController = TextEditingController(text: data[5]);
    return showBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Container(
          padding: EdgeInsets.fromLTRB(20.0, 0, 20, 20.0),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.arrow_downward),
                      Text("Glisser vers le bas pour disparaitre"),
                      Icon(Icons.arrow_downward)
                    ]
                ),

                Padding(padding: EdgeInsets.all(15.0)),

                RichText(
                  text: TextSpan(
                    text: "Emplacement: ",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    children: <TextSpan>[
                      TextSpan(text: data[6] + " - " + data[4], style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20))
                    ]
                  )
                ),

                Padding(padding: EdgeInsets.all(8.0)),

                Text("Code: "),
                TextField(
                  controller: CodeController,
                  enabled: false,
                ),

                Padding(padding: EdgeInsets.all(8.0)),

                Text("Description: "),
                TextField(
                  controller: DescriptionController,
                  enabled: false,
                ),

                Padding(padding: EdgeInsets.all(8.0)),

                Text("Vestiaire: "),
                TextField(
                  controller: CloakroomController,
                  enabled: false,
                ),

                Padding(padding: EdgeInsets.all(8.0)),

                Text("Emplacement: "),
                TextField(
                  controller: LocationController,
                  enabled: false,
                ),

                Padding(padding: EdgeInsets.all(8.0)),

                Text("Informations: "),
                TextField(
                  controller: InfoController,
                  enabled: false,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.red,
                      child: Center(child: Text('Masquer', style: TextStyle(color: Colors.white))),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      color: Colors.blue,
                      child: Center(child: Text('Récupérer', style: TextStyle(color: Colors.white))),
                      onPressed: (){
                        _removeBelongingsFromDatabase(data, context, codeFocusNode);
                      },
                    )
                  ]
                )
              ]
            ),
          ),
          height: double.infinity
        );
      }
    );
  }

  _removeBelongingsFromDatabase(List<String> data, BuildContext context, FocusNode codeFocusNode) async {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Récupération en cours...")));
    int belongingsId = int.tryParse(data[0]);
    DatabaseHelper db = DatabaseHelper();
    var conn = await db.database;
    conn.query("DELETE FROM belongings WHERE belongings_id = ?", [belongingsId]);
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Affaire récupérée..."), backgroundColor: Colors.green));
    Navigator.pop(context);
    if(codeFocusNode!=null)
      FocusScope.of(context).requestFocus(codeFocusNode);
  }

}