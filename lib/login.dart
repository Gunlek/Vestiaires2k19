import 'package:app_vestiaires/MainMenu.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
          Center(
            child: Text(
                'Identifiez vous',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                )
            )
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: LoginForm()
        )
        ]
    );
  }

}

String currentProms = 'li218';
bool rememberMe = false;

class LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginFormState();
  }

}

class LoginFormState extends State<LoginForm> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController bucqueController;
  String recoveredBucque;

  @override
  void initState(){
    super.initState();
    _recoverBucque();
  }

  Future<String> _recoverBucque() async {
    SharedPreferences prefs = await SharedPreferences.getInstance().then((sp) {
      bool remember = sp.getBool("remember");
      if(remember == null)
        remember = false;
      this.setState(() {
        rememberMe = remember;
        if(remember){
          recoveredBucque = sp.getString("bucque");
        }
        else
          recoveredBucque = "";
      });
    });

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    bucqueController = TextEditingController(text: recoveredBucque);
    return Form(
        key: _formKey,
        child: Container(
            width: 250,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      'Bucque',
                      style: TextStyle(
                        fontSize: 20,
                      )
                  ),
                  TextFormField(
                    style: TextStyle(fontSize: 15),
                    controller: bucqueController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Entrez votre bucque';
                      }
                    },
                  ),

                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10)
                  ),

                  Text(
                      'Prom\'s',
                      style: TextStyle(
                        fontSize: 20,
                      )
                  ),
                  DropdownButtonFormField<String>(
                      value: currentProms,
                      onChanged: (String newValue) {
                        setState(() {
                          currentProms = newValue;
                        });
                      },
                      items: <String>['li217', 'li218', 'li218+1'].map<
                          DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Choisissez votre prom\'s';
                        }
                      }
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Center(
                    child: Row(
                        children: <Widget>[
                          Switch(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value;
                              });
                            },
                          ),
                          Text(
                              'Se souvenir de moi'
                          )
                        ]
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Center(
                      child: RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Authentification en cours')));

                            var settings = new mysql.ConnectionSettings(
                                host: '91.121.135.77',
                                port: 3306,
                                user: 'vestiaires_2k19',
                                password: 'emL3xC7jKCx7Nb5n',
                                db: 'vestiaires_2k19'
                            );
                            var conn = await mysql.MySqlConnection.connect(settings);
                            var results = await conn.query("SELECT * FROM users WHERE bucque = ? AND proms = ?", [bucqueController.text, currentProms]);
                            SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
                            if (results.length > 0) {
                              await sharedPrefs.setBool("remember", rememberMe);
                              if (rememberMe)
                                await sharedPrefs.setString("bucque", bucqueController.text);
                              _registerUserData(bucqueController.text, currentProms);
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Vous êtes authentifié !'), backgroundColor: Colors.green));
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenu()));
                            }
                            else {
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Authentification impossible'), backgroundColor: Colors.red));
                            }
                          }
                        },
                        child: Text('M\'identifier'),
                        color: Colors.green,
                        textColor: Colors.white,
                      )
                  )
                ]
            )
        )
    );
  }

  _registerUserData(String bucque, String proms) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("session_bucque", bucque);
    prefs.setString("session_proms", proms);
  }

}