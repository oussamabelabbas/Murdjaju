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

class _MovieVideoState extends State<MovieVideo> {
  final Movie movie;
  VideoPlayerController _showVideoPlayerController;
  _MovieVideoState(this.movie);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (movie.isShow) _showVideoPlayerController = VideoPlayerController.network(movie.trailer);
  }

  @override
  Widget build(BuildContext context) {
    if (movie.isShow)
      return VideoPlayer(
        _showVideoPlayerController,
      );
    return widget.videoPlayer;
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
