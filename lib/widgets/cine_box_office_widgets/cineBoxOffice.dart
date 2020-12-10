import 'package:murdjaju/bloc/get_projections_bloc.dart';
import 'package:murdjaju/model/genre.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/model/projection_response.dart';
import 'package:murdjaju/model/salle.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:murdjaju/widgets/swipersColumn.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CineBoxOffice extends StatefulWidget {
  final int dayIndex;
  final List<Genre> genres;
  final List<Salle> salles;
  CineBoxOffice({Key key, this.dayIndex, this.salles, this.genres})
      : super(key: key);

  @override
  _CineBoxOfficeState createState() => _CineBoxOfficeState(salles, genres);
}

class _CineBoxOfficeState extends State<CineBoxOffice> {
  final List<Salle> salles;
  final List<Genre> genres;

  _CineBoxOfficeState(this.salles, this.genres);

  @override
  void initState() {
    if (mounted) {
      print("hello..." + widget.dayIndex.toString());

      return;
    }
    super.initState();
    print("initializing..." + widget.dayIndex.toString());
    projectionListBloc..getMovies(widget.dayIndex);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: projectionListBloc.subject.stream,
      builder: (context, AsyncSnapshot<ProjectionResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.error != null && snapshot.data.error.length > 0) {
            return _buildErrorWidget(snapshot.data);
          }

          return _buildMostPopularWidget(snapshot.data);
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.data);
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildMostPopularWidget(ProjectionResponse data) {
    List<Projection> projections = data.projections
        .where((element) => element.date.weekday == widget.dayIndex)
        .toList();
    if (projections.length == 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("No projections !"),
          ],
        ),
      );
    } else
      return SwiperColumn(
        projections:
            projections /* .where(
          (element) =>
              salles.contains(element.salle) &&
              element.movie.genres.contains(genres),
        ) */
        ,
        heroId: 0,
      );
  }

  Widget _buildErrorWidget(ProjectionResponse error) {
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
