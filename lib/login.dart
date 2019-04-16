import 'package:flutter/material.dart';

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

class LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginFormState();
  }

}

class LoginFormState extends State<LoginForm> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              validator: (value) {
                if(value.isEmpty) {
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
              onChanged: (String newValue){
                setState((){
                  currentProms = newValue;
                });
              },
              items: <String>['li217', 'li218', 'li218+1'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if(value.isEmpty) {
                  return 'Choisissez votre prom\'s';
                }
              }
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Center(
                child: RaisedButton(
                  onPressed: () {
                    if(_formKey.currentState.validate()){
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Authentification en cours')));
                      //Todo: Make request to server
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

}