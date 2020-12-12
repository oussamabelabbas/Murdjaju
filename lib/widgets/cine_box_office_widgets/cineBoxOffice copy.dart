import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/model/projection_response.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:murdjaju/widgets/swipersColumn.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CineBoxOffice2 extends StatefulWidget {
  final List<Projection> projections;
  CineBoxOffice2({Key key, this.projections}) : super(key: key);

  @override
  _CineBoxOffice2State createState() => _CineBoxOffice2State(projections);
}

class _CineBoxOffice2State extends State<CineBoxOffice2> {
  final List<Projection> projections;

  _CineBoxOffice2State(this.projections);
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
}
