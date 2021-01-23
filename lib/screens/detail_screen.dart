import 'dart:ui';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/screens/booking_screen.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:murdjaju/widgets/detail_screen_widgets/movieInfos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

  YoutubePlayerController _controller;

  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  bool _isVisible = true;

  _MovieDetailScreenState(this.projection, this.heroId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: projection.movie.trailer,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
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
    _controller.dispose();

    // _scrollController.dispose();
    // _hideFabAnimController.dispose(); // movieDetailBloc.drainStream();
    // movieVideosBloc.drainStream();
    // castsBloc.drainStream();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      onEnterFullScreen: () {
        _controller.play();
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {},
        onEnded: (data) {
          _controller.load(projection.movie.trailer);
        },
      ),
      builder: (context, player) => Scaffold(
        //floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: projection.date.isBefore(DateTime.now())
            ? null
            : FadeTransition(
                opacity: _hideFabAnimController,
                child: ScaleTransition(
                  scale: _hideFabAnimController,
                  child: FloatingActionButton(
                    backgroundColor: Style.Colors.secondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Icon(MdiIcons.ticket, color: Style.Colors.mainColor),
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
                  image: widget.image,
                  fit: BoxFit.cover,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Style.Colors.mainColor.withOpacity(.4),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            CustomScrollView(
              physics: ClampingScrollPhysics(),
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.width * 3 / 2 - MediaQuery.of(context).padding.top,
                  backgroundColor: Style.Colors.mainColor.withOpacity(.0),
                  pinned: true,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
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
                  leadingWidth: 56 + 5.0,
                  leading: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Colors.white60,
                      child: Icon(
                        Icons.chevron_left,
                        color: Style.Colors.mainColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
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
                      physics: BouncingScrollPhysics(),
                      child: MovieInfos(
                        heroId: heroId,
                        projection: projection,
                        videoPlayer: player,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
