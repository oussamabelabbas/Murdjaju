import 'package:murdjaju/widgets/authentification_widgets/sign_in_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class AuthentificationScreen extends StatefulWidget {
  static final String path = "lib/src/pages/login/auth3.dart";

  @override
  _AuthentificationScreenState createState() => _AuthentificationScreenState();
}

class _AuthentificationScreenState extends State<AuthentificationScreen> {
  bool formVisible;
  int _formsIndex;

  @override
  void initState() {
    super.initState();
    formVisible = false;
    _formsIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/joker.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.black54,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: kToolbarHeight + 40),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Cinema Murdjaju",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 30.0,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          "Welcome to this awesome login app. \n You are awesome",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SigninForm(),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
