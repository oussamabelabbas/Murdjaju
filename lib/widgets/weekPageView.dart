import 'package:murdjaju/bloc/current_week_bloc.dart';
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
  final String cineWhat;
  final List<int> myGenresFilterList;
  final List<String> mySallesFilterList;

  WeekPageView({Key key, this.tabController, this.weekId, this.cineWhat, this.myGenresFilterList, this.mySallesFilterList}) : super(key: key);

  @override
  _WeekPageViewState createState() => _WeekPageViewState(tabController, weekId, cineWhat, myGenresFilterList, mySallesFilterList);
}

class _WeekPageViewState extends State<WeekPageView> {
  final TabController _tabController;
  final String weekId;
  final String cineWhat;

  final List<int> myGenresFilterList;
  final List<String> mySallesFilterList;

  _WeekPageViewState(this._tabController, this.weekId, this.cineWhat, this.myGenresFilterList, this.mySallesFilterList);

  PageController _pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentWeekBloc.getCurrentWeek(weekId);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: currentWeekBloc.subject.stream,
        builder: (context, AsyncSnapshot<Week> snapshot) {
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

  Widget _buildWeekBuilder(Week data) {
    Week myWeek = data;

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: myWeek.numberOfDays,
      controller: _pageController,
      itemBuilder: (context, index) {
        List<Projection> _projections = myWeek.projections.where((proj) => proj.date.day == myWeek.startDate.add(Duration(days: index)).day).toList();
        return CineBoxOffice2(
          projections: _projections,
        );
      },
    );
  }

  Widget _buildErrorWidget(Week error) {
    if (error.error == "Loading...") return _buildLoadingWidget();
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
              valueColor: AlwaysStoppedAnimation<Color>(Style.Colors.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
