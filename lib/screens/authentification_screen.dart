import 'package:murdjaju/widgets/authentification_widgets/sign_in_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:murdjaju/widgets/authentification_widgets/sign_in_form_mail.dart';
import 'package:murdjaju/widgets/authentification_widgets/sign_up_form_mail.dart';

class AuthentificationScreen extends StatefulWidget {
  static final String path = "lib/src/pages/login/auth3.dart";

  @override
  _AuthentificationScreenState createState() => _AuthentificationScreenState();
}

class _AuthentificationScreenState extends State<AuthentificationScreen> with SingleTickerProviderStateMixin {
  bool formVisible;
  int _formsIndex;

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    formVisible = false;
    _formsIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Container(
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
                            "Welcome to the best app in the world 😂",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Spacer(),
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Style.Colors.mainColor.withOpacity(.75),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ToggleButtons(
                                  onPressed: (index) => setState(() => _formsIndex = index),
                                  selectedColor: Style.Colors.mainColor,
                                  color: Colors.white,
                                  fillColor: Style.Colors.secondaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                                      child: Text("S'identifier"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                                      child: Text("S'inscrire"),
                                    ),
                                  ],
                                  isSelected: [
                                    _formsIndex == 0,
                                    _formsIndex == 1,
                                  ],
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IndexedStack(
                      index: _formsIndex,
                      children: [
                        SigninFormMail(),
                        SignupFormMail(),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
