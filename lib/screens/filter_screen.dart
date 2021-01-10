import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/bloc/get_genres_list.dart';
import 'package:murdjaju/model/genre.dart';
import 'package:murdjaju/model/genre_response.dart';
import 'package:murdjaju/model/salle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/model/week.dart';
import 'package:murdjaju/model/week_response.dart';
import 'package:murdjaju/bloc/get_weeks_bloc.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class FilterScreen extends StatefulWidget {
  final String myWeekId;
  final List<int> myGenresFilterList;
  final List<String> mySallesFilterList;
  final String cineWhat;

  FilterScreen({Key key, this.myWeekId, this.myGenresFilterList, this.mySallesFilterList, this.cineWhat}) : super(key: key);
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String myWeekId;
  List<int> myGenresFilterList;
  List<String> mySallesFilterList;
  List<Genre> allGenres = [];
  List<Salle> allSalles = [];

  List<int> genresFilterList = [];
  List<String> sallesFilterList = [];

  List cineList = ["BoxOffice", "Kids", "Show"];

  String cineWhat;
  bool cineClear = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    initializeDateFormatting();
    genresListBloc.getGenres();
    weeksListBloc.getMiniWeeks();

    //weeksListBloc.getWeeks();
    myWeekId = widget.myWeekId;
    cineWhat = widget.cineWhat;
    genresFilterList = widget.myGenresFilterList;
    sallesFilterList = widget.mySallesFilterList;
  }

  void getData() async {
    await FirebaseFirestore.instance.collection("Salles").get().then(
      (value) {
        value.docs.forEach(
          (element) {
            allSalles.add(Salle.fromSnapshot(element));
          },
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  floatingActionButton: FloatingActionButton(onPressed: () {
        print(genresFilterList.toString());
      }), */
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
                style: Theme.of(context).textTheme.button.copyWith(color: Style.Colors.titleColor),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, []);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                "filtrer votre expérience",
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Style.Colors.titleColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          FlatButton(
            child: FittedBox(
              child: Text(
                "Confirm",
                style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
                [
                  myWeekId,
                  cineClear ? null : cineWhat,
                  genresFilterList,
                  sallesFilterList,
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
                SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        "Genres:",
                        style: Theme.of(context).textTheme.headline6.copyWith(color: Style.Colors.titleColor),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        //padding: EdgeInsets.zero,
                        child: Icon(
                          MdiIcons.closeCircle,
                          color: (genresFilterList.length > 0) ? Style.Colors.secondaryColor : Colors.transparent,
                        ),
                        onTap: (genresFilterList.length > 0)
                            ? () {
                                genresFilterList.clear();
                                setState(() {});
                              }
                            : null,
                      ),
                      Expanded(
                        child: Container(
                          height: 75,
                          child: StreamBuilder(
                            stream: genresListBloc.subject.stream,
                            builder: (context, AsyncSnapshot<GenreResponse> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.error != null && snapshot.data.error.length > 0) {
                                  return _buildErrorWidget(snapshot.data.error);
                                }

                                return _buildGenresBuilder(snapshot.data);
                              } else if (snapshot.hasError) {
                                return _buildErrorWidget(snapshot.data.error);
                              } else {
                                return _buildLoadingWidget();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Ciné:",
                      style: Theme.of(context).textTheme.headline6.copyWith(color: Style.Colors.titleColor),
                    ),
                    Spacer(),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(20),
                      onPressed: (index) {
                        if (cineClear) {
                          cineClear = false;
                          cineWhat = cineList[index];
                        } else if (cineWhat == cineList[index])
                          cineClear = true;
                        else
                          cineWhat = cineList[index];
                        setState(() {});
                      },
                      borderColor: Style.Colors.titleColor,
                      color: Style.Colors.titleColor,
                      selectedColor: Style.Colors.secondaryColor,
                      selectedBorderColor: Style.Colors.secondaryColor,
                      isSelected: List.generate(cineList.length, (index) => cineList[index] == cineWhat && !cineClear),
                      children: List.generate(
                        cineList.length,
                        (index) => Padding(padding: EdgeInsets.all(10), child: Text(cineList[index])),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Salle:",
                      style: Theme.of(context).textTheme.headline6.copyWith(color: Style.Colors.titleColor),
                    ),
                    Spacer(),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(20),
                      onPressed: (index) {
                        if (sallesFilterList.contains(allSalles[index].id))
                          sallesFilterList.remove(allSalles[index].id);
                        else
                          sallesFilterList.add(allSalles[index].id);
                        setState(() {});
                      },
                      borderColor: Style.Colors.titleColor,
                      color: Style.Colors.titleColor,
                      selectedColor: Style.Colors.secondaryColor,
                      selectedBorderColor: Style.Colors.secondaryColor,
                      isSelected: List.generate(allSalles.length, (index) => sallesFilterList.contains(allSalles[index].id)),
                      children: List.generate(
                        allSalles.length,
                        (index) => Padding(padding: EdgeInsets.all(10), child: Text(allSalles[index].name)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        "Semaine de :",
                        style: Theme.of(context).textTheme.headline6.copyWith(color: Style.Colors.titleColor),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        //padding: EdgeInsets.zero,
                        child: Icon(
                          MdiIcons.closeCircle,
                          color: myWeekId != null ? Style.Colors.secondaryColor : Colors.transparent,
                        ),
                        onTap: myWeekId != null
                            ? () {
                                myWeekId = null;
                                setState(() {});
                              }
                            : null,
                      ),
                      Expanded(
                        child: Container(
                          height: 75,
                          child: StreamBuilder(
                            stream: weeksListBloc.subject.stream,
                            builder: (context, AsyncSnapshot<WeekResponse> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.error != null && snapshot.data.error.length > 0) {
                                  return _buildErrorWidget(snapshot.data.error);
                                }

                                return _buildWeeksBuilder(snapshot.data);
                              } else if (snapshot.hasError) {
                                return _buildErrorWidget(snapshot.data.error);
                              } else {
                                return _buildLoadingWidget();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildWeeksBuilder(WeekResponse data) {
    List<Week> weeks = data.weeks;
    if (weeks.length == 0) return _buildErrorWidget("No weeks founds");

    weeks.sort((a, b) => a.startDate.compareTo(b.startDate));

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(10),
      itemCount: weeks.length,
      separatorBuilder: (context, index) => SizedBox(width: 10),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            myWeekId == weeks[index].id ? myWeekId = null : myWeekId = weeks[index].id;
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: myWeekId == weeks[index].id ? Style.Colors.secondaryColor.withOpacity(.5) : Style.Colors.titleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                DateFormat('EEE d MMM y', 'fr-FR').format(weeks[index].startDate),
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ),
        );
      },
    );
  }

  _buildGenresBuilder(GenreResponse data) {
    List<Genre> genres = data.genres;
    if (genres.length == 0) return _buildErrorWidget("No genres founds");

    // genres.sort((genre0, genre1) => genresFilterList.contains(genre0) ? genres.indexOf(genre0) : genres.indexOf(genre1));
    genres.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(10),
      itemCount: genres.length,
      separatorBuilder: (context, index) => SizedBox(width: 10),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            genresFilterList.contains(genres[index % genres.length].id) ? genresFilterList.remove(genres[index % genres.length].id) : genresFilterList.add(genres[index % genres.length].id);
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: genresFilterList.contains(genres[index % genres.length].id) ? Style.Colors.secondaryColor.withOpacity(.5) : Style.Colors.titleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                genres[index % genres.length].name,
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: Icon(MdiIcons.exclamation, color: Colors.grey),
          ),
          Text(
            "Something went wrong :",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            error,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
              backgroundColor: Style.Colors.mainColor,
              valueColor: AlwaysStoppedAnimation<Color>(Style.Colors.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
