//import 'package:cloud_functions/cloud_functions.dart';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:http/http.dart';
import 'package:murdjaju/providers/auth.dart';
import 'package:murdjaju/bloc/current_week_bloc.dart';
import 'package:murdjaju/model/firebase.dart';
import 'package:murdjaju/model/genre.dart';
import 'package:murdjaju/model/movie.dart';
import 'package:murdjaju/model/movie_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:murdjaju/screens/account_screen.dart';
import 'package:murdjaju/screens/filter_screen.dart';
import 'package:murdjaju/widgets/cineTabBar.dart';
import 'package:murdjaju/widgets/weekPageView.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../style/theme.dart' as Style;
import 'package:murdjaju/bloc/get_weeks_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

import 'package:tmdb_api/tmdb_api.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<int> myGenresFilterList = [];
  List<String> mySallesFilterList = [];

  String myWeekId;
  String cineWhat;

  void _initOneSignal() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    await OneSignal.shared.init("2c44c278-0038-4e05-a26b-3d17c6562f22", iOSSettings: {OSiOSSettings.autoPrompt: false, OSiOSSettings.inAppLaunchUrl: false});
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Players").doc("NotificationsPlayersIdsDocument").get();
    if (!doc.exists) {
      await FirebaseFirestore.instance.collection("Players").doc("NotificationsPlayersIdsDocument").set({
        "Ids": <String>[status.subscriptionStatus.userId]
      });
    } else {
      if (!doc["Ids"].contains(status.subscriptionStatus.userId)) {
        doc.reference.update({
          "Ids": FieldValue.arrayUnion([status.subscriptionStatus.userId])
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    currentWeekBloc.getCurrentWeek(myWeekId);
    _initOneSignal();
  }

  void getSallesAndGenres() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(MdiIcons.account, color: Colors.white),
          onPressed: () async {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AccountScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.filter, color: (myWeekId != null || cineWhat != null || myGenresFilterList.isNotEmpty || mySallesFilterList.isNotEmpty) ? Style.Colors.secondaryColor : Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) {
                    return FilterScreen(
                      myWeekId: myWeekId,
                      cineWhat: cineWhat,
                      myGenresFilterList: myGenresFilterList,
                      mySallesFilterList: mySallesFilterList,
                    );
                  },
                ),
              ).then(
                (value) {
                  if (value != null && value.isNotEmpty) {
                    print(value.toString());
                    setState(
                      () {
                        myWeekId = value[0];
                        cineWhat = value[1];
                        myGenresFilterList = value[2];
                        mySallesFilterList = value[3];
                      },
                    );
                    currentWeekBloc.filterCurrentWeek(value[0], value[1], value[2], value[3]);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: DoubleBackToCloseApp(
        child: Column(
          children: [
            Builder(
              builder: (context) => WeekPageView(),
            ),
          ],
        ),
        snackBar: SnackBar(
          backgroundColor: Style.Colors.mainColor,
          duration: Duration(seconds: 2),
          content: Text(
            'Appuyer "Retour" a nouveau pour quitter Murdjaju.',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
