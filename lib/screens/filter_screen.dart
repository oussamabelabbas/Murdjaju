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
  final List<Genre> myGenresFilterList;
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
  List<Genre> myGenresFilterList;
  List<String> mySallesFilterList;
  List<Genre> allGenres = [];
  List<Salle> allSalles = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    weeksListBloc.getWeeks();
    myWeekid = widget.myWeekid;
    myGenresFilterList = widget.myGenresFilterList;
    mySallesFilterList = widget.mySallesFilterList;
  }

  void getData() async {
    await FirebaseFirestore.instance.collection("Salles").get().then(
      (query) async {
        allSalles = List.generate(
          query.docs.length,
          (index) => Salle.fromSnapshot(query.docs[index]),
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          FlatButton(
            child: FittedBox(
              child: Text(
                "Cancel",
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.black),
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
                    .copyWith(color: Colors.black),
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
                Text("Salles", style: Theme.of(context).textTheme.headline5),
                Container(
                  height: 120,
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
                          height: 100,
                          width: 100,
                          color:
                              mySallesFilterList.contains(allSalles[index].id)
                                  ? Colors.orange
                                  : Colors.white,
                          child: Center(
                            child: Text(
                              allSalles[index].name +
                                  " -" +
                                  allSalles[index].screenQuality +
                                  "-",
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  "Programme:",
                  style: Theme.of(context).textTheme.headline5,
                ),
                Text(
                  "(Si aucun programme n'est selectioné, le programme de la semaine en cours s'affichera)",
                  style: Theme.of(context).textTheme.caption,
                ),
                Container(
                  height: 120,
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
                                height: 100,
                                //width: 100,
                                color: myWeekid == snapshot.data.weeks[index].id
                                    ? Colors.orange
                                    : Colors.white,
                                child: Center(
                                  child: Text(
                                    snapshot.data.weeks[index].startDate
                                            .toString() +
                                        "\n --> \n" +
                                        snapshot.data.weeks[index].startDate
                                            .add(
                                              Duration(
                                                  days: snapshot
                                                      .data
                                                      .weeks[index]
                                                      .numberOfDays),
                                            )
                                            .toString(),
                                  ),
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
