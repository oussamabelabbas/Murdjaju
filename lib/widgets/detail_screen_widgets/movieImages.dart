import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:murdjaju/bloc/get_movie_images_bloc.dart';
import 'package:murdjaju/bloc/get_movie_videos_bloc.dart';
import 'package:murdjaju/model/image.dart';
import 'package:murdjaju/model/images_response.dart';
import 'package:murdjaju/model/movie.dart';
import 'package:murdjaju/model/video.dart';
import 'package:murdjaju/model/video_response.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieImages extends StatefulWidget {
  final Movie movie;

  MovieImages({Key key, this.movie}) : super(key: key);

  @override
  _MovieImagesState createState() => _MovieImagesState(movie);
}

class _MovieImagesState extends State<MovieImages> {
  final Movie movie;

  _MovieImagesState(this.movie);

  @override
  void initState() {
    super.initState();
    if (!movie.isShow) imagesBloc..getImages(int.parse(movie.id));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (!movie.isShow) imagesBloc..drainStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 1.777777777777778 * .9,
      child: StreamBuilder(
        stream: imagesBloc.subject.stream,
        builder: (context, AsyncSnapshot<ImageResponse> snapshot) {
          if (movie.isShow) return _buildShowImagesWidget();
          if (snapshot.hasData) {
            if (snapshot.data.error != null && snapshot.data.error.length > 0) {
              return _buildErrorWidget(snapshot.data);
            }

            return _buildImagesWidget(snapshot.data);
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.data);
          } else {
            return _buildLoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildImagesWidget(ImageResponse data) {
    List<Poster> posters = data.posters;
    List<Backdrop> backdrops = data.backdrops;

    return Swiper(
      itemCount: backdrops.length,
      loop: true,
      scale: .95,
      viewportFraction: .9,
      itemBuilder: (context, index) {
        //   return Text(backdrops[index].path);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Style.Colors.titleColor.withOpacity(.1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            "https://image.tmdb.org/t/p/w780" + backdrops[index].path,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(Style.Colors.secondaryColor),
                    /* value: loadingProgress.expectedTotalBytes /
                        loadingProgress.expectedTotalBytes, */
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShowImagesWidget() => AspectRatio(
        aspectRatio: 16 / 9,
        child: Card(
          color: Colors.white10,
          child: Image.network(
            movie.backPoster,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(Style.Colors.secondaryColor),
                  ),
                ),
              );
            },
          ),
        ),
      );

  Widget _buildErrorWidget(ImageResponse error) {
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
    Widget loader = new Loader().loader;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [loader],
      ),
    );
  }
}
