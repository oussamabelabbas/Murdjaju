import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/bloc/current_week_bloc.dart';
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
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:toggle_bar_button/toggle_bar_button.dart';

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
    genresListBloc.getGenres();
    weeksListBloc.getMiniWeeks();
    myWeekId = widget.myWeekId;
    cineWhat = widget.cineWhat;
    genresFilterList = widget.myGenresFilterList;
    sallesFilterList = widget.mySallesFilterList;
  }

  void getData() async {
    if (currentWeekBloc.subject.hasValue) {
      currentWeekBloc.subject.value.projections.forEach(
        (element) {
          if (allSalles.indexWhere((salle) => salle.id == element.salle.id) == -1) allSalles.add(element.salle);
        },
      );
      setState(() {});
    }
  }

  Widget _title(String _str) => Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text(
          _str,
          style: Theme.of(context).textTheme.headline5.copyWith(color: Style.Colors.secondaryColor),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(MdiIcons.filter),
        label: Text("Filtrer."),
        onPressed: () {
          Navigator.pop(
            context,
            [myWeekId, cineClear ? null : cineWhat, genresFilterList, sallesFilterList],
          );
        },
      ),
      body: ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://image.tmdb.org/t/p/w780/' + currentWeekBloc.subject.value.projections.first.movie.poster),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Style.Colors.mainColor.withOpacity(.4),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: kToolbarHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Genres:"),
                    _buildGenresListView(),
                    _title("Semaine du:"),
                    _buildWeeksListView(),
                    Row(children: [_title("Ciné:"), Spacer(), _buildCineToggleButtons()]),
                    Row(children: [_title("Salle:"), Spacer(), _buildSalleToggleButtons()]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildWeeksListView() => Container(
        height: 100,
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
      );

  _buildWeeksBuilder(WeekResponse data) {
    List<Week> weeks = data.weeks;
    if (weeks.length == 0) return _buildErrorWidget("No weeks founds");

    weeks.sort((a, b) => a.startDate.compareTo(b.startDate));

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(20),
      itemCount: weeks.length,
      separatorBuilder: (context, index) => SizedBox(width: 10),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            myWeekId == weeks[index].id ? myWeekId = null : myWeekId = weeks[index].id;
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: myWeekId == weeks[index].id ? Style.Colors.secondaryColor.withOpacity(.5) : Style.Colors.titleColor.withOpacity(.5),
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

  _buildSalleToggleButtons() => Padding(
        padding: EdgeInsets.all(20),
        child: ToggleButtons(
          color: Colors.white,
          borderColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          selectedColor: Style.Colors.secondaryColor,
          selectedBorderColor: Style.Colors.secondaryColor,
          isSelected: List.generate(allSalles.length, (index) => sallesFilterList.contains(allSalles.elementAt(index).id)),
          children: List.generate(
            allSalles.length,
            (index) => Padding(padding: EdgeInsets.all(10), child: Text(allSalles.elementAt(index).name)),
          ),
          onPressed: (index) {
            if (sallesFilterList.contains(allSalles.elementAt(index).id))
              sallesFilterList.remove(allSalles.elementAt(index).id);
            else
              sallesFilterList.add(allSalles.elementAt(index).id);
            setState(() {});
          },
        ),
      );

  _buildCineToggleButtons() => Padding(
        padding: EdgeInsets.all(20),
        child: ToggleButtons(
          borderRadius: BorderRadius.circular(20),
          borderColor: Colors.white,
          color: Colors.white,
          selectedColor: Style.Colors.secondaryColor,
          selectedBorderColor: Style.Colors.secondaryColor,
          isSelected: List.generate(cineList.length, (index) => cineList[index] == cineWhat && !cineClear),
          children: List.generate(
            cineList.length,
            (index) => Padding(padding: EdgeInsets.all(10), child: Text(cineList[index])),
          ),
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
        ),
      );

  _buildGenresListView() => Container(
        height: 100,
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
      );

  _buildGenresBuilder(GenreResponse data) {
    List<Genre> genres = data.genres;
    if (genres.length == 0) return _buildErrorWidget("No genres founds");
    genres.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(20),
      itemCount: genres.length,
      separatorBuilder: (context, index) => SizedBox(width: 10),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            genresFilterList.contains(genres[index % genres.length].id) ? genresFilterList.remove(genres[index % genres.length].id) : genresFilterList.add(genres[index % genres.length].id);
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: genresFilterList.contains(genres[index % genres.length].id) ? Style.Colors.secondaryColor.withOpacity(.5) : Style.Colors.titleColor.withOpacity(.5),
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
    Widget loader = new Loader().loader;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [loader],
      ),
    );
  }
}
