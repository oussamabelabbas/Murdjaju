//import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:murdjaju/authentication/auth.dart';
import 'package:murdjaju/bloc/current_week_bloc.dart';
import 'package:murdjaju/model/firebase.dart';
import 'package:murdjaju/model/genre.dart';
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
  TabController _tabController;

  List<int> myGenresFilterList = [];
  List<String> mySallesFilterList = [];

  AnimationController _animationController;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String myWeekId;
  String cineWhat;

  void oneSignal() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    await OneSignal.shared.init(
      "a1de0aa0-fb19-466a-9986-37ff14e1491e",
      iOSSettings: {OSiOSSettings.autoPrompt: false, OSiOSSettings.inAppLaunchUrl: false},
    );
    await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) async {
      // will be called whenever a notification is received
      showBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              child: Center(
            child: Text(notification.toString()),
          ));
        },
      );
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // will be called whenever a notification is opened/button pressed.
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // will be called whenever the subscription changes
      //(ie. user gets registered with OneSignal and gets a user ID)
    });

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
      // will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    await FirebaseFirestore.instance.collection("Players").doc("NotificationsPlayersIdsDocument").update(
      {
        "Ids": FieldValue.arrayUnion([status.subscriptionStatus.userId]),
      },
    );
  }

  @override
  void initState() {
    super.initState();
    oneSignal();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
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
        // centerTitle: true,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          /*  child: Text(
            mySallesFilterList.isEmpty
                ? ""
                : mySallesFilterList.fold(
                      "",
                      (previousValue, element) => previousValue + element + ", ",
                    ) +
                    (myGenresFilterList.isEmpty
                        ? ""
                        : myGenresFilterList.fold(
                            "",
                            (previousValue, element) => (previousValue + element.toString() + ", ").toString(),
                          )),
            style: Theme.of(context).textTheme.headline6.copyWith(color: Style.Colors.secondaryColor),
          ), */
        ),
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
            icon: Icon(MdiIcons.filterOutline, color: Colors.white),
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
                    setState(() {
                      myWeekId = value[0];
                      cineWhat = value[1];
                      myGenresFilterList = value[2];
                      mySallesFilterList = value[3];
                    });

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
              builder: (context) => WeekPageView(
                tabController: _tabController,
                weekId: null, // myWeekId,
                cineWhat: null, // cineWhat,
                myGenresFilterList: [], //myGenresFilterList,
                mySallesFilterList: [], //mySallesFilterList,
              ),
            ),
          ],
        ),
        snackBar: SnackBar(
          content: Text('Double-Tap to close'),
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await currentWeekBloc.getCurrentWeek(null);
          print(currentWeekBloc.subject.value.startDate.toString());
        },
      ), */
      /*   floatingActionButton: FloatingActionButton(onPressed: () async {
        var status = await OneSignal.shared.getPermissionSubscriptionState();
        String str = status.subscriptionStatus.userId;
        print(str);
        /*  var status = await OneSignal.shared.getPermissionSubscriptionState();
        print(status.subscriptionStatus.userId);

        await FirebaseFirestore.instance
            .collection("Players")
            .doc("NotificationsPlayersIdsDocument")
            .get()
            .then(
          (doc) async {
            try {
              await OneSignal.shared.postNotification(
                OSCreateNotification(
                  playerIds: List.generate(
                      doc['Ids'].length, (index) => doc['Ids'][index]),
                  androidLargeIcon: "@mipmap/logo",
                  androidSmallIcon: "@mipmap/logo",
                  bigPicture:
                      "https://image.tmdb.org/t/p/original/pbrkL804c8yAv3zBZR4QPEafpAR.jpg",
                  content:
                      "Interstellar,Tenet et Inception...\nLa semaine Christopher Nolan est la pour vous, 25% de reduction pour les 10 premiers réservations !!",
                  heading: "Nouvelle semaine et nouveaux films !!!",
                  buttons: [
                    OSActionButton(
                      text: "Botona",
                      id: "id1",
                    ),
                    OSActionButton(
                      text: "Botona bessah a droite",
                      id: "id2",
                    )
                  ],
                ),
              );
            } catch (e) {
              print(e);
            }
          },
        );

        var response;

        print("==>" + response.toString()); */

        /*  var res = await http.post(
          "https://onesignal.com/api/v1/notifications",
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization":
                "basic ODk4ZTMzZTktYzAzMy00ZGI3LThjMWYtMTQ1YTcxNzM4YWZm"
          },
          body: {
            "app_id": "5eb5a37e-b458-11e3-ac11-000c2940e62c",
            "included_segments": ["All"],
            "data": {"foo": "bar"},
            "contents": {"en": "English Message"},
          },

          /*   {
            "app_id": "5eb5a37e-b458-11e3-ac11-000c2940e62c",
            "contents": {"en": "English Message"},
          }, */
        );

        print(res.body); */
        /*   var postUrl = "https://onesignal.com/api/v1/notifications";

        var headers = {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "ODk4ZTMzZTktYzAzMy00ZGI3LThjMWYtMTQ1YTcxNzM4YWZm"
        };

        var options = {
          "host": "onesignal.com",
          "port": 443,
          "path": "/api/v1/notifications",
          "method": "POST",
          "headers": headers
        };
        BaseOptions option = BaseOptions(
          headers: headers,
        );

        final data = {
          "app_id": "a1de0aa0-fb19-466a-9986-37ff14e1491e",
          "included_segments": ["All"],
          "contents": {"en": "English Message"},
          "data": {"foo": "bar"}
        };

        var message = {
          "app_id": "5eb5a37e-b458-11e3-ac11-000c2940e62c",
          "contents": {"en": "English Message"},
          "filters": [
            {"field": "tag", "key": "level", "relation": "=", "value": "10"},
            {"operator": "OR"},
            {"field": "amount_spent", "relation": ">", "value": "0"}
          ]
        };

        try {
          final response = await Dio(option).post(postUrl, data: data);

          if (response.statusCode == 200) {
            Fluttertoast.showToast(msg: 'Request Sent To Driver');
          } else {
            print('notification sending failed');
            // on failure do sth
          }
        } catch (e) {
          print('exception $e');
        } */

        /*  // See index.js in the functions folder for the example function we
        // are using for this example
        HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
            'listFruit',
            options: HttpsCallableOptions(timeout: Duration(seconds: 5)));

        await callable().then((v) {
          print("ketba chabaa ====");
        }).catchError((e) {
          print("Lmohim ketba");
        }); */
        /*  Dio dio = Dio();
        var postUrl = "fcm.googleapis.com/fcm/send";
        FirebaseMessaging fcm = FirebaseMessaging();
        var token = await fcm.getToken();

        final data = {
          "notification": {
            "body": "Accept Ride Request",
            "title": "This is Ride Request"
          },
          "priority": "high",
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "id": "1",
            "status": "done"
          },
          "to": "$token"
        };

        final headers = {
          'content-type': 'application/json',
          'Authorization':
              'AAAAe2oi9U4:APA91bFLEdUODxfi9uQr3NheZF-jnCTLawULAx1riWhRUUOm7eFCQey0a5axD_GHZ9-I79_RlZG8Q7HD_gU2yLOXNW75nQBAmO6h-LNT2AUxRhBLVwjQqrvZcUOrK7augqSlhSql2uO-'
        };

        BaseOptions options = new BaseOptions(
          connectTimeout: 5000,
          receiveTimeout: 3000,
          headers: headers,
        );

        try {
          final response =
              await http.post(postUrl, body: data.toString(), headers: headers);

          if (response.statusCode == 200) {
            Fluttertoast.showToast(msg: 'Request Sent To Driver');
          } else {
            print('notification sending failed');
            // on failure do sth
          }
        } catch (e) {
          print('exception $e');
        } */
      }), */
      /*
        child: Center(
          child: CircularProgressIndicator(
            value: _animationController.isAnimating ? null : 1,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
         onPressed: () async {
          /*Stream s = weeksListBloc.subject.stream; */

        floatingActionButton: FloatingActionButton(
          print("pressed");
          _animationController.repeat();
          Random rnd = Random();

          List<DateTime> list = [
            DateTime(2020, 12, 6, 12, 30),
            DateTime(2020, 12, 6, 14, 30),
            DateTime(2020, 12, 6, 15, 30),
            DateTime(2020, 12, 6, 17, 30),
            DateTime(2020, 12, 7, 13, 30),
            DateTime(2020, 12, 7, 15, 30),
            DateTime(2020, 12, 7, 17, 15),
            DateTime(2020, 12, 7, 18, 45),
            DateTime(2020, 12, 8, 12, 00),
            DateTime(2020, 12, 8, 13, 45),
            DateTime(2020, 12, 8, 15, 30),
            DateTime(2020, 12, 8, 17, 30),
            DateTime(2020, 12, 8, 19, 00),
            DateTime(2020, 12, 9, 12, 30),
            DateTime(2020, 12, 9, 14, 30),
            DateTime(2020, 12, 9, 16, 30),
            DateTime(2020, 12, 9, 18, 30),
            DateTime(2020, 12, 10, 12, 00),
            DateTime(2020, 12, 10, 14, 30),
            DateTime(2020, 12, 10, 16, 30),
            DateTime(2020, 12, 11, 12, 00),
            DateTime(2020, 12, 11, 13, 45),
            DateTime(2020, 12, 11, 15, 30),
            DateTime(2020, 12, 11, 17, 30),
            DateTime(2020, 12, 11, 19, 00),
            DateTime(2020, 12, 12, 12, 30),
            DateTime(2020, 12, 12, 14, 30),
            DateTime(2020, 12, 12, 16, 30),
            DateTime(2020, 12, 12, 18, 30),
          ];

          QuerySnapshot moviesQuery =
              await FirebaseFirestore.instance.collection("Movies").get();
          List<DocumentSnapshot> _movies = moviesQuery.docs;
          QuerySnapshot sallesQuery =
              await FirebaseFirestore.instance.collection("Salles").get();
          List<DocumentSnapshot> _salles = sallesQuery.docs;

          int randomInt = 0;

          list.forEach(
            (_date) async {
              randomInt = rnd.nextInt(9999);
              await FirebaseFirestore.instance
                  .collection("Weeks")
                  .doc("PGNyQuoIDdOh3kzqejda")
                  .collection("Projections")
                  .add(
                {
                  "date": _date,
                  "movieId": _movies[randomInt % _movies.length].id,
                  "prixTicket": 500 + (randomInt % 10) * 50,
                  "salleId": _salles[randomInt % _salles.length].id,
                  "places": _salles[randomInt % _salles.length]['places'],
                },
              );
            },
          );

          _animationController.stop();
          /*  MovieRepository _rep = MovieRepository();
          TMDB tmdbWithCustomLogs = TMDB(
            ApiKeys(
              "3fcc3cf0902881ec381782b11cebbe92",
              "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZmNjM2NmMDkwMjg4MWVjMzgxNzgyYjExY2ViYmU5MiIsInN1YiI6IjVmODg5ZGRjZTMzZjgzMDAzN2ZkZjk1NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.tLu7CRm0t78C9_NtDb4_1KC8TC3sh6nqUGXdXq2BN44",
            ),
          );

          MovieResponse movieResponse = await _rep.getNowPlayingMovies();

          movieResponse.movies.forEach(
            (_movie) async {
              Map<dynamic, dynamic> response = await tmdbWithCustomLogs
                  .v3.movies
                  .getDetails(_movie.id, language: "fr-FR");

              await FirebaseFirestore.instance
                  .collection("Movies")
                  .doc(_movie.id.toString())
                  .set(response);
            },
          );

          print('stoped'); */

          /*  QuerySnapshot snapshot =
              await FirebaseFirestore.instance.collection('Movies').get();
          List<DocumentSnapshot> movies = snapshot.docs;
          QuerySnapshot snapshotsalle =
              await FirebaseFirestore.instance.collection('Salles').get();
          List<DocumentSnapshot> salles = snapshotsalle.docs;
          DocumentSnapshot movie;
          int number;
          QuerySnapshot query = await FirebaseFirestore.instance
              .collection('Projections')
              //.where("date.Date.weekDay", isEqualTo: dayIndex)
              .orderBy("date", descending: false)
              .get();
          List<DocumentSnapshot> projs = query.docs; */

          /* await Future.forEach(
            list,
            (element) {
              projs.add({
                "movieId": movies[number].id,
                "date": element,
                "salleId": number % 2 == 0 ? "salle_Q" : "salle_W",
                "prixTicket": 300 + (number * 10),
                "places": number % 2 == 0
                    ? salles
                        .where((element) => element.id == "salle_Q")
                        .toList()
                        .first['places']
                    : salles
                        .where((element) => element.id == "salle_W")
                        .toList()
                        .first['places'],
              });
            },
          );
 */
          /*   list.forEach(
            (element) async { */
          /*  number = rnd.nextInt(list.length);
          movie = movies[number % movies.length];
          await FirebaseFirestore.instance.collection("Weeks").add(
            {
              "numberOfDays": 5,
              "startDay": list[0],
            },
          ).then(
            (value) async {
              projs.map((e) => e.data()).toList().forEach(
                (element) async {
                  value.collection("Projections").add(
                        element,
                      );
                },
              );
            },
          ); */
        },
      ), */
    );
  }
}
