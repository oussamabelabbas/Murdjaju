import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:murdjaju/model/genre.dart';
import 'package:murdjaju/model/salle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/model/week_response.dart';
import 'package:murdjaju/bloc/get_weeks_bloc.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class FilterScreen extends StatefulWidget {
  final String myWeekid;
  final List<int> myGenresFilterList;
  final List<String> mySallesFilterList;

  FilterScreen(
      {Key key,
      this.myWeekid,
      this.myGenresFilterList,
      this.mySallesFilterList})
      : super(key: key);
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String myWeekid;
  List<int> myGenresFilterList;
  List<String> mySallesFilterList;
  List<Genre> allGenres = [];
  List<Salle> allSalles = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    initializeDateFormatting();

    //weeksListBloc.getWeeks();
    myWeekid = widget.myWeekid;
    myGenresFilterList = widget.myGenresFilterList;
    mySallesFilterList = widget.mySallesFilterList;
  }

  void getData() async {
    weeksListBloc.subject.value.weeks.forEach(
      (week) {
        week.projections.forEach(
          (proj) {
            if (allSalles.indexWhere((salle) => salle.id == proj.salle.id) ==
                -1) allSalles.add(proj.salle);
            proj.movie.genres.forEach(
              (genre) {
                if (allGenres.indexWhere((_genre) => _genre.id == genre.id) ==
                    -1) allGenres.add(genre);
              },
            );
          },
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Style.Colors.mainColor,
        elevation: 0,
        actions: [
          FlatButton(
            child: FittedBox(
              child: Text(
                "Cancel",
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Style.Colors.titleColor),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, []);
            },
          ),
          Spacer(),
          FlatButton(
            child: FittedBox(
              child: Text(
                "Confirm",
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.white),
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
                [
                  myWeekid,
                  myGenresFilterList,
                  mySallesFilterList,
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Genres:",
                      style: Theme.of(context).textTheme.headline5),
                ),
                Container(
                  height: 60,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(10),
                    itemCount: allGenres.length,
                    separatorBuilder: (context, index) => SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          myGenresFilterList.contains(allGenres[index].id)
                              ? myGenresFilterList.remove(allGenres[index].id)
                              : myGenresFilterList.add(allGenres[index].id);
                          setState(() {});
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                myGenresFilterList.contains(allGenres[index].id)
                                    ? Style.Colors.secondaryColor
                                    : Style.Colors.titleColor.withOpacity(.5),
                          ),
                          child: Center(
                            child: Text(
                              allGenres[index].name,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Salles:",
                      style: Theme.of(context).textTheme.headline5),
                ),
                Container(
                  height: 60,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(10),
                    itemCount: allSalles.length,
                    separatorBuilder: (context, index) => SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          mySallesFilterList.contains(allSalles[index].id)
                              ? mySallesFilterList.remove(allSalles[index].id)
                              : mySallesFilterList.add(allSalles[index].id);
                          setState(() {});
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                mySallesFilterList.contains(allSalles[index].id)
                                    ? Style.Colors.secondaryColor
                                    : Style.Colors.titleColor.withOpacity(.5),
                          ),
                          child: Center(
                            child: Text(
                              allSalles[index].name +
                                  " (" +
                                  allSalles[index].screenQuality +
                                  ")",
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    "Programme:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "(Si aucun programme n'est selectioné, le programme de la semaine en cours s'affichera)",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                Container(
                  height: 60,
                  child: StreamBuilder(
                    stream: weeksListBloc.subject.stream,
                    builder: (context, AsyncSnapshot<WeekResponse> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.error != null &&
                            snapshot.data.error.length > 0) {
                          return Center(child: Text("Error"));
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.all(10),
                          itemCount: snapshot.data.weeks.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                myWeekid == snapshot.data.weeks[index].id
                                    ? myWeekid = null
                                    : myWeekid = snapshot.data.weeks[index].id;
                                setState(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: myWeekid ==
                                          snapshot.data.weeks[index].id
                                      ? Style.Colors.secondaryColor
                                      : Style.Colors.titleColor.withOpacity(.5),
                                ),
                                child: Center(
                                  child: Text("Semaine du " +
                                      DateFormat('EEE, d MMM', 'fr-FR').format(
                                        snapshot.data.weeks[index].startDate,
                                      )),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error"));
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
