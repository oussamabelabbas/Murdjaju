import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/screens/booking_screen.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:murdjaju/widgets/detail_screen_widgets/movieInfos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';

class MovieDetailScreen extends StatefulWidget {
  final Projection projection;
  final NetworkImage image;
  final NetworkImage thumbnail;
  final AssetImage asset;
  final int heroId;
  MovieDetailScreen({Key key, this.projection, this.image, this.thumbnail, this.asset, this.heroId}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(projection, heroId);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> with SingleTickerProviderStateMixin {
  final Projection projection;
  final int heroId;

  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  bool _isVisible = true;

  _MovieDetailScreenState(this.projection, this.heroId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      value: 1, // initially visible
    );
    _scrollController.addListener(
      () {
        switch (_scrollController.position.userScrollDirection) {
          // Scrolling up - forward the animation (value goes to 1)
          case ScrollDirection.forward:
            _hideFabAnimController.forward();
            break;
          // Scrolling down - reverse the animation (value goes to 0)
          case ScrollDirection.reverse:
            _hideFabAnimController.reverse();
            break;
          // Idle - keep FAB visibility unchanged
          case ScrollDirection.idle:
            break;
        }
      },
    );
    // movieVideosBloc..getMovieDetail(movie.id);
    // movieDetailBloc..getMovieDetail(movie.id);
    // castsBloc..getCasts(movie.id);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _hideFabAnimController.dispose(); // movieDetailBloc.drainStream();
    // movieVideosBloc.drainStream();
    // castsBloc.drainStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: false //projection.date.isBefore(DateTime.now())
          ? null
          : FadeTransition(
              opacity: _hideFabAnimController,
              child: ScaleTransition(
                scale: _hideFabAnimController,
                child: FloatingActionButton(
                  backgroundColor: Style.Colors.mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Icon(MdiIcons.ticket, color: Style.Colors.secondaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) {
                          return BookingScreen(projection: projection, heroId: heroId);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: widget.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                color: Style.Colors.mainColor.withOpacity(.4),
              ),
            ),
          ),
          CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                shape: RoundedRectangleBorder(
                    //  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                expandedHeight: MediaQuery.of(context).size.width * 3 / 2 - MediaQuery.of(context).padding.top,
                backgroundColor: Style.Colors.mainColor.withOpacity(.15),
                pinned: true,
                shadowColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Hero(
                    tag: projection.movie.id.toString() + projection.movie.title.toString() + heroId.toString(),
                    child: Text(
                      projection.movie.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  centerTitle: true,
                  background: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Hero(
                        tag: projection.movie.id + heroId.toString(),
                        child: ProgressiveImage(
                          placeholder: widget.asset,
                          thumbnail: widget.thumbnail,
                          image: widget.image,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * 3 / 2,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Style.Colors.mainColor.withOpacity(.4)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left),
                  tooltip: 'Retour',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  // padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                      //color: Style.Colors.mainColor.withOpacity(.75),
                      ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    child: MovieInfos(
                      heroId: heroId,
                      projection: projection,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Style.Colors.mainColor,
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: MaterialButton(
        color: Colors.orange,
        minWidth: Theme.of(context).buttonTheme.minWidth * 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(15),
        child: Text(
          'Reserver',
          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) {
                return BookingScreen(projection: projection);
              },
            ),
          );
        },
      ),
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              Container(
                color: Style.Colors.mainColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Hero(
                      tag: projection.movie.id + heroId.toString(),
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            image: widget.thumbnail,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.transparent,
                                child: Center(
                                  child: SizedBox(),
                                ),
                              ),
                            ),
                            ProgressiveImage(
                              placeholder: widget.asset,
                              thumbnail: widget.thumbnail,
                              image: widget.image,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * .85,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                minChildSize: .2,
                maxChildSize: .8,
                initialChildSize: .2,
                builder: (context, _sc) {
                  return Container(
                    // padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                      controller: _sc,
                      children: [
                        MovieInfos(
                          heroId: heroId,
                          projection: projection,
                        ),
                      ],
                    ),
                  );
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          color: Style.Colors.mainColor,
                        ),
                        clipBehavior: Clip.antiAlias,
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          projection.movie.isShow ? projection.movie.backPoster : 'https://image.tmdb.org/t/p/w92/' + projection.movie.poster,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;

                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Style.Colors.mainColor,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        // padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          color: Style.Colors.mainColor,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                          child: ListView(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            controller: _sc,
                            children: [
                              MovieInfos(
                                heroId: heroId,
                                projection: projection,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
