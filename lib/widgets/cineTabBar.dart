import 'package:murdjaju/style/theme.dart' as Style;
import 'package:flutter/material.dart';

class CineBar extends StatefulWidget {
  final TabController tabController;
  CineBar({Key key, this.tabController}) : super(key: key);

  @override
  _CineBarState createState() => _CineBarState();
}

class _CineBarState extends State<CineBar> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: TabBar(
        controller: widget.tabController,
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 5,
        indicatorPadding: EdgeInsets.only(top: 5),
        isScrollable: true,
        onTap: (index) {
          //  setState(() {});
        },
        indicator: CircleTabIndicator(color: Colors.orange, radius: 2),
        /*  unselectedLabelStyle: Theme.of(context).textTheme.headline5.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: Theme.of(context).textTheme.headline1.fontSize - 5,
            ),
        labelStyle: Theme.of(context).textTheme.headline1.copyWith(
              fontWeight: FontWeight.bold,
            ), */
        tabs: [
          Tab(
            child: FittedBox(
              // text: "Ciné\nBoxOffice",
              child: Text(
                "Ciné\nBoxOffice",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Tab(
            child: FittedBox(
              // text: "Ciné\nShows",
              child: Text(
                "Ciné\nShow",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Tab(
            child: FittedBox(
              //text: "Ciné\nKids",
              child: Text(
                "Ciné\nKids",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
