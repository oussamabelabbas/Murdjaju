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
  final Widget videoPlayer;

  MovieVideo({Key key, this.movie, this.videoPlayer}) : super(key: key);

  @override
  _MovieVideoState createState() => _MovieVideoState(movie);
}

class _MovieVideoState extends State<MovieVideo> with SingleTickerProviderStateMixin {
  final Movie movie;
  VideoPlayerController _showVideoPlayerController;
  _MovieVideoState(this.movie);

  AnimationController _iconAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (movie.isShow) {
      _showVideoPlayerController = VideoPlayerController.network(movie.trailer)
        ..addListener(() {})
        ..setLooping(true)
        ..initialize();

      _iconAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (movie.isShow)
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            VideoPlayer(_showVideoPlayerController),
            Center(
              child: IconButton(
                onPressed: () {
                  if (_iconAnimation.isCompleted) {
                    _showVideoPlayerController.pause();
                    _iconAnimation.reverse();
                  } else {
                    _showVideoPlayerController.play();
                    _iconAnimation.forward();
                  }
                },
                icon: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _iconAnimation,
                ),
              ),
            ),
          ],
        ),
      );
    return widget.videoPlayer;
  }
}
