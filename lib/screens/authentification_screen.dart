import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/providers/auth.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:murdjaju/widgets/authentification_widgets/sign_in_form_mail.dart';
import 'package:murdjaju/widgets/authentification_widgets/sign_up_form_mail.dart';
import 'package:provider/provider.dart';

class AuthentificationScreen extends StatefulWidget {
  static final String path = "lib/src/pages/login/auth3.dart";

  @override
  _AuthentificationScreenState createState() => _AuthentificationScreenState();
}

class _AuthentificationScreenState extends State<AuthentificationScreen> with SingleTickerProviderStateMixin {
  bool formVisible;
  int _formsIndex;

  @override
  void initState() {
    super.initState();

    formVisible = false;
    _formsIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/murdjaju.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Style.Colors.mainColor.withOpacity(.4),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
                      child: Row(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Center(
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: Image.asset("assets/splash.png"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Murdjaju',
                                    style: Theme.of(context).textTheme.headline4.copyWith(color: Style.Colors.secondaryColor),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ', le Cinéma où sont tous vos films.',
                                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     Container(
                  //       clipBehavior: Clip.antiAlias,
                  //       decoration: BoxDecoration(
                  //         color: Style.Colors.mainColor.withOpacity(.75),
                  //         borderRadius: BorderRadius.circular(15),
                  //       ),
                  //       child: ToggleButtons(
                  //         isSelected: [_formsIndex == 0, _formsIndex == 1],
                  //         onPressed: (index) => setState(() => _formsIndex = index),
                  //         selectedColor: Style.Colors.mainColor,
                  //         color: Colors.white,
                  //         fillColor: Style.Colors.secondaryColor,
                  //         borderRadius: BorderRadius.circular(15),
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                  //             child: Text("S'identifier"),
                  //           ),
                  //           Padding(
                  //             padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                  //             child: Text("S'inscrire"),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Spacer(),
                  //   ],
                  // ),
                  //SizedBox(height: 10),

                  // Spacer(),

                  _formsIndex == 0 ? SigninFormMail() : SignupFormMail(),

                  SizedBox(height: 20),
                  _formsIndex == 0
                      ? RichText(
                          text: TextSpan(
                            text: "Vous êtes pas encore inscrit? ",
                            children: [
                              TextSpan(
                                text: "Inscrivez-vous.",
                                style: TextStyle(color: Style.Colors.secondaryColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _formsIndex = (_formsIndex + 1) % 2;
                                    setState(() {});
                                  },
                              ),
                            ],
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            text: "Vous avez déja un compte? ",
                            children: [
                              TextSpan(
                                text: "Connecter.",
                                style: TextStyle(color: Style.Colors.secondaryColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _formsIndex = (_formsIndex + 1) % 2;
                                    setState(() {});
                                  },
                              ),
                            ],
                          ),
                        ),
                  // Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
