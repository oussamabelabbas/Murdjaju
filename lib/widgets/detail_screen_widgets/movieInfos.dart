import 'package:intl/intl.dart';
import 'package:murdjaju/bloc/get_movie_detail_bloc.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/widgets/detail_screen_widgets/movieCast.dart';
import 'package:murdjaju/widgets/detail_screen_widgets/movieImages.dart';
import 'package:murdjaju/widgets/detail_screen_widgets/movieVideo.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class MovieInfos extends StatefulWidget {
  final Projection projection;
  final int heroId;
  final Widget videoPlayer;

  MovieInfos({Key key, this.projection, this.heroId, this.videoPlayer})
      : super(key: key);

  @override
  _MovieInfosState createState() => _MovieInfosState(projection, heroId);
}

class _MovieInfosState extends State<MovieInfos> {
  final Projection projection;
  final int heroId;

  @override
  void initState() {
    super.initState();
    //movieDetailBloc..getMovieDetail(projection.movie.id);
  }

  _MovieInfosState(this.projection, this.heroId);

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'Decenmebr'
  ];

  final EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 10);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Container(
          child: Center(
            child: Hero(
              tag: projection.movie.id.toString() +
                  projection.movie.title.toString() +
                  heroId.toString(),
              child: Text(
                projection.movie.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Style.Colors.secondaryColor),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          child: Center(
            child: Hero(
              tag: projection.id.toString() +
                  projection.date.toString() +
                  heroId.toString(),
              child: Text(
                DateTime.now().day == projection.date.day
                    ? "Aujourd'hui à ${DateFormat('HH:mm ').format(projection.date)} "
                    : DateFormat('EEEEEE d MMM ', 'fr-FR')
                            .format(projection.date)
                            .capitalize() +
                        (DateTime.now().isAfter(
                          projection.date.add(
                            Duration(minutes: projection.movie.runtime),
                          ),
                        )
                            ? "(Déjà joué) "
                            : "") +
                        (DateTime.now().isBefore(
                                  projection.date.add(
                                    Duration(minutes: projection.movie.runtime),
                                  ),
                                ) &&
                                DateTime.now().isAfter(projection.date)
                            ? "(En train de jouer) "
                            : ""), //+ projection.salle.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          constraints: BoxConstraints.tightFor(),
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: projection.movie.genres.length,
              separatorBuilder: (context, index) => SizedBox(width: 10),
              itemBuilder: (context, index) => Container(
                padding: EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  shape: StadiumBorder(),
                  color: Style.Colors.secondaryColor.withOpacity(.3),
                ),
                child: Center(
                  child: Text(
                    projection.movie.genres[index].name,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        _title("Resumé:"),
        SizedBox(height: 10),
        Padding(
          padding: _padding,
          child: Text(
            projection.movie.overview,
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: 20),
        _title("Casting:"),
        SizedBox(height: 10),
        projection.movie.isShow
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: 120,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      height: 120,
                      width: 80,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.person),
                    );
                  },
                ),
              )
            : MovieCast(movie: projection.movie),
        SizedBox(height: 20),
        _title("Gallery:"),
        SizedBox(height: 10),
        MovieImages(movie: projection.movie),
        SizedBox(height: 20),
        _title("Bande annonce:"),
        SizedBox(height: 10),
        MovieVideo(movie: projection.movie, videoPlayer: widget.videoPlayer),
        //SizedBox(height: 20),
      ],
    );
  }

  Widget _title(String text) => Padding(
        padding: _padding,
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
}
