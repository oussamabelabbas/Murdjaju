import 'package:flutter/services.dart';
import 'package:murdjaju/bloc/get_movie_videos_bloc.dart';
import 'package:murdjaju/model/movie.dart';
import 'package:murdjaju/model/video.dart';
import 'package:murdjaju/model/video_response.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MovieVideo extends StatefulWidget {
  final Movie movie;

  MovieVideo({Key key, this.movie}) : super(key: key);

  @override
  _MovieVideoState createState() => _MovieVideoState(movie);
}

class _MovieVideoState extends State<MovieVideo> {
  final Movie movie;

  _MovieVideoState(this.movie);

  VideoPlayerController videoPlayerController;
  YoutubePlayerController youtubePlayerController;
  bool videoIsPlaying = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;

  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: movie.trailer,
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
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller.load(movie.trailer);
        },
      ),
      builder: (context, player) => player,
    );
    /*  return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: youtubePlayerController,
      ),
      builder: (context, player) => Column(
        children: [
          // some widgets
          player,
          //some other widgets
        ],
      ),
    ); */

    //if (movie.isShow)
    /* return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(5),
          width: (MediaQuery.of(context).size.width - 10),
          height: (MediaQuery.of(context).size.width - 10) * 9 / 16,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: Style.Colors.titleColor.withOpacity(.15),
              valueColor: AlwaysStoppedAnimation(Style.Colors.secondaryColor),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.all(5),
            width: (MediaQuery.of(context).size.width - 10),
            height: (MediaQuery.of(context).size.width - 10) * 9 / 16,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              child: VideoPlayer(videoPlayerController),
              onTap: () {
                videoIsPlaying ? videoPlayerController.pause() : videoPlayerController.play();
                setState(() => videoIsPlaying = !videoIsPlaying);
              },
            )),
      ],
    ); */
    /* return StreamBuilder(
      stream: movieVideosBloc.subject.stream,
      builder: (context, AsyncSnapshot<VideoResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.error != null && snapshot.data.error.length > 0) {
            return _buildErrorWidget(snapshot.data);
          }

          return _buildVideoWidget(
            snapshot.data,
            YoutubePlayerController(
              initialVideoId: snapshot.data.videos.first.key,
              params: YoutubePlayerParams(
                showFullscreenButton: true,
                showControls: true,
                desktopMode: true,
                strictRelatedVideos: true,
                showVideoAnnotations: false,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.data);
        } else {
          return _buildLoadingWidget();
        }
      },
    ); */
  }

  Widget _buildVideoWidget(VideoResponse data, YoutubePlayerController controller) {
    Video video = data.videos.first;

    /* return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(5),
          width: (MediaQuery.of(context).size.width - 10),
          height: (MediaQuery.of(context).size.width - 10) * 9 / 16,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: Style.Colors.titleColor.withOpacity(.15),
              valueColor: AlwaysStoppedAnimation(Style.Colors.secondaryColor),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.all(5),
            width: (MediaQuery.of(context).size.width - 10),
            height: (MediaQuery.of(context).size.width - 10) * 9 / 16,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: YoutubePlayerIFrame(
              aspectRatio: 9 / 16,
              controller: controller,
            )),
      ],
    ); */
  }

  Widget _buildErrorWidget(VideoResponse error) {
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
    return Container(
      width: (MediaQuery.of(context).size.width - 50),
      height: 190,
      child: Center(
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
      ),
    );
  }
}
