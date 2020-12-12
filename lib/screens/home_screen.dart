import 'package:http/http.dart';
import 'package:murdjaju/authentication/auth.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.setAutoInitEnabled(true);
    _firebaseMessaging.configure(
      onMessage: (message) async {},
      onLaunch: (message) async {},
      onResume: (message) async {},
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
          child: Text(
            mySallesFilterList.isEmpty
                ? ""
                : mySallesFilterList.fold(
                      "",
                      (previousValue, element) =>
                          previousValue + element + ", ",
                    ) +
                    (myGenresFilterList.isEmpty
                        ? ""
                        : myGenresFilterList.fold(
                            "",
                            (previousValue, element) =>
                                (previousValue + element.toString() + ", ")
                                    .toString(),
                          )),
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Style.Colors.secondaryColor),
          ),
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
                      myWeekid: myWeekId,
                      myGenresFilterList: myGenresFilterList,
                      mySallesFilterList: mySallesFilterList,
                    );
                  },
                ),
              ).then(
                (value) {
                  if (value != null && value.isNotEmpty) {
                    myWeekId = value[0];
                    myGenresFilterList = value[1];
                    mySallesFilterList = value[2];
                    setState(() {});
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
            /*  CineBar(tabController: _tabController),
            SizedBox(height: 5), */
            Builder(
              builder: (context) => WeekPageView(
                tabController: _tabController,
                weekId: myWeekId,
                myGenresFilterList: myGenresFilterList,
                mySallesFilterList: mySallesFilterList,
              ),
            ),
          ],
        ),
        snackBar: SnackBar(
          content: Text('Double-Tap to close'),
        ),
      ),
      /*  floatingActionButton: FloatingActionButton(
        child: Center(
          child: CircularProgressIndicator(
            value: _animationController.isAnimating ? null : 1,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
         onPressed: () async {
          /*Stream s = weeksListBloc.subject.stream; */

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
