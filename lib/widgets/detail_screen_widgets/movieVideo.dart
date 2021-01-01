import 'package:murdjaju/bloc/get_movie_videos_bloc.dart';
import 'package:murdjaju/model/movie.dart';
import 'package:murdjaju/model/video.dart';
import 'package:murdjaju/model/video_response.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MovieVideo extends StatefulWidget {
  final Movie movie;

  MovieVideo({Key key, this.movie}) : super(key: key);

  @override
  _MovieVideoState createState() => _MovieVideoState(movie);
}

class _MovieVideoState extends State<MovieVideo> {
  final Movie movie;

  _MovieVideoState(this.movie);

  @override
  void initState() {
    super.initState();
    movieVideosBloc..getMovieDetail(movie.id);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    movieVideosBloc..drainStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
                )),
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.data);
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildVideoWidget(VideoResponse data, YoutubePlayerController controller) {
    Video video = data.videos.first;

    return Stack(
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
            )

            /*  YoutubePlayerBuilder(
            builder: (context, child) => child,
            onExitFullScreen: () {
              setState(() {});
            },
            player: YoutubePlayer(
              controller: controller,
            ),
          ), */
            ),
      ],
    );
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
