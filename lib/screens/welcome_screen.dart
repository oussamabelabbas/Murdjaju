import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:murdjaju/screens/authentification_screen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final pageList = [
    PageModel(
      body: SizedBox(),
      color: Style.Colors.secondaryColor,
      //icon: Icon(Icons.notifications_active),
      iconImagePath: 'assets/notification.svg',
      heroImagePath: 'assets/notification.svg',
      heroImageColor: Style.Colors.mainColor,

      title: Padding(
        padding: EdgeInsets.all(25),
        child: Text(
          'Recever des notifications une fois le programme disponible',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Style.Colors.mainColor,
            fontSize: 34.0,
          ),
        ),
      ),
    ),
    PageModel(
      body: SizedBox(),
      //icon: Icon(MdiIcons.ticket),
      color: Style.Colors.mainColor,
      iconImagePath: 'assets/ticket.svg',
      heroImagePath: 'assets/ticket.svg',
      heroImageColor: Style.Colors.secondaryColor,
      title: Padding(
        padding: EdgeInsets.all(25),
        child: Text(
          'Réserver vos places gratuitement et payez sur place',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Style.Colors.secondaryColor,
            fontSize: 34.0,
          ),
        ),
      ),
    ),
    PageModel(
      body: SizedBox(),
      //icon: Icon(Icons.movie),
      color: Style.Colors.secondaryColor,
      iconImagePath: 'assets/calendar.svg',
      heroImagePath: 'assets/calendar.svg',
      heroImageColor: Style.Colors.mainColor,
      title: Padding(
        padding: EdgeInsets.all(25),
        child: Text(
          'Tout le programme de notre cinéma en une seule application',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Style.Colors.mainColor,
            fontSize: 34.0,
          ),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FancyOnBoarding(
        pageList: pageList,
        doneButtonText: "Terminé",
        skipButtonText: "Sauter",
        doneButtonBackgroundColor: Style.Colors.mainColor,
        onDoneButtonPressed: () => Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => AuthentificationScreen())),
        onSkipButtonPressed: () => Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => AuthentificationScreen())),
        doneButton: MaterialButton(
          shape: StadiumBorder(),
          color: Style.Colors.mainColor,
          child: Text("Terminé"),
          onPressed: () => Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => AuthentificationScreen())),
        ),
        skipButton: MaterialButton(
          shape: StadiumBorder(),
          color: Style.Colors.mainColor,
          child: Text("Sauter"),
          onPressed: () => Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => AuthentificationScreen())),
        ),
      ),
    );
  }
}
