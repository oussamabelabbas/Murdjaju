import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/model/projection_response.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:murdjaju/widgets/swipersColumn.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CineShow2 extends StatefulWidget {
  final List<Projection> projections;
  CineShow2({Key key, this.projections}) : super(key: key);

  @override
  _CineShow2State createState() => _CineShow2State(projections);
}

class _CineShow2State extends State<CineShow2> {
  final List<Projection> projections;

  _CineShow2State(this.projections);
  @override
  Widget build(BuildContext context) {
    return _buildMostPopularWidget();
  }

  Widget _buildMostPopularWidget() {
    if (projections.length == 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("No Projections !"),
          ],
        ),
      );
    } else
      return SwiperColumn(
        projections: projections,
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
