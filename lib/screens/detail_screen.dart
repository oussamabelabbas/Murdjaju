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
  final int heroIndex;
  MovieDetailScreen({Key key, this.projection, this.image, this.thumbnail, this.asset, this.heroIndex}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(projection, heroIndex);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> with SingleTickerProviderStateMixin {
  final Projection projection;
  final int heroIndex;
  _MovieDetailScreenState(this.projection, this.heroIndex);

  YoutubePlayerController _controller;

  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  bool _isVisible = true;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () => _controller.play(),
      onExitFullScreen: () => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.

      player: YoutubePlayer(
        onReady: () {},
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onEnded: (data) => _controller.load(projection.movie.trailer),
      ),
      builder: (context, player) => Scaffold(
        floatingActionButton: false //projection.date.isBefore(DateTime.now())
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
                            return BookingScreen(projection: projection, heroId: heroIndex);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
        body: Stack(
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(image: widget.image, fit: BoxFit.cover),
                ),
                clipBehavior: Clip.antiAlias,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Style.Colors.mainColor.withOpacity(.4),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            ClipRRect(
              clipBehavior: Clip.antiAlias,
              child: CustomScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    backgroundColor: Style.Colors.mainColor.withOpacity(.0),
                    expandedHeight: MediaQuery.of(context).size.width * 3 / 2 - MediaQuery.of(context).padding.top,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      background: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Hero(
                            tag: projection.movie.id + heroIndex.toString(),
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
                    leading: Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Style.Colors.secondaryColor.withOpacity(.5), shape: BoxShape.circle),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.chevron_left),
                            color: Style.Colors.mainColor,
                            onPressed: () => Navigator.pop(context),
                            tooltip: MaterialLocalizations.of(context).previousPageTooltip,
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: MovieInfos(
                          heroId: heroIndex,
                          projection: projection,
                          videoPlayer: player,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
