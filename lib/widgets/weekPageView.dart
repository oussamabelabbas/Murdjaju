import 'package:murdjaju/bloc/get_weeks_bloc.dart';
import 'package:murdjaju/model/genre.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/model/week.dart';
import 'package:murdjaju/model/week_response.dart';
import 'package:murdjaju/widgets/cine_kids_widgets/cineKids%20copy.dart';
import 'package:flutter/material.dart';

import 'package:murdjaju/style/theme.dart' as Style;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'cine_box_office_widgets/cineBoxOffice copy.dart';
import 'cine_show_widgets/cineShow copy.dart';

class WeekPageView extends StatefulWidget {
  final TabController tabController;
  final String weekId;
  final List<int> myGenresFilterList;
  final List<String> mySallesFilterList;

  WeekPageView(
      {Key key,
      this.tabController,
      this.weekId,
      this.myGenresFilterList,
      this.mySallesFilterList})
      : super(key: key);

  @override
  _WeekPageViewState createState() => _WeekPageViewState(
      tabController, weekId, myGenresFilterList, mySallesFilterList);
}

class _WeekPageViewState extends State<WeekPageView> {
  final TabController _tabController;
  final String weekId;
  final List<int> myGenresFilterList;
  final List<String> mySallesFilterList;

  _WeekPageViewState(this._tabController, this.weekId, this.myGenresFilterList,
      this.mySallesFilterList);

  PageController _pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    weeksListBloc..getWeeks();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: weeksListBloc.subject.stream,
        builder: (context, AsyncSnapshot<WeekResponse> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.error != null && snapshot.data.error.length > 0) {
              return _buildErrorWidget(snapshot.data);
            }

            return _buildWeekBuilder(snapshot.data);
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.data);
          } else {
            return _buildLoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildWeekBuilder(WeekResponse data) {
    Week myWeek;
    if (data.weeks.isEmpty)
      return Center(
        child: Text(data.weeks.length.toString()),
      );
    if (widget.weekId != null)
      myWeek = data.weeks.firstWhere((element) => element.id == widget.weekId);
    else
      myWeek = data.weeks.indexWhere(
                (_week) =>
                    DateTime.now().isAfter(_week.startDate) &&
                    DateTime.now().isBefore(
                      _week.projections.last.date.add(
                        Duration(
                          minutes: _week.projections.last.movie.runtime,
                        ),
                      ),
                    ),
              ) ==
              -1
          ? data.weeks.first
          : data.weeks[data.weeks.indexWhere(
              (_week) =>
                  DateTime.now().isAfter(_week.startDate) &&
                  DateTime.now().isBefore(
                    _week.projections.last.date.add(
                      Duration(
                        minutes: _week.projections.last.movie.runtime,
                      ),
                    ),
                  ),
            )];

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: myWeek.numberOfDays,
      controller: _pageController,
      itemBuilder: (context, index) {
        List<Projection> _projections = myWeek.projections
            .where(
              (proj) =>
                  proj.date.weekday % 7 == index &&
                  (mySallesFilterList.isEmpty ||
                      mySallesFilterList.contains(proj.salle.id)) &&
                  (myGenresFilterList.isEmpty ||
                      proj.movie.genres.indexWhere(
                            (genre) => myGenresFilterList.contains(genre.id),
                          ) !=
                          -1),
            )
            .toList();
        return CineBoxOffice2(
          projections: _projections,
        );
      },
    );
  }

  Widget _buildErrorWidget(WeekResponse error) {
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
            error.error,
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
              valueColor:
                  AlwaysStoppedAnimation<Color>(Style.Colors.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
