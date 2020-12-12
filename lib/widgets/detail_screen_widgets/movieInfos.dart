import 'package:intl/intl.dart';
import 'package:murdjaju/bloc/get_movie_detail_bloc.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/widgets/detail_screen_widgets/movieCast.dart';
import 'package:murdjaju/widgets/detail_screen_widgets/movieImages.dart';
import 'package:murdjaju/widgets/detail_screen_widgets/movieVideo.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class MovieInfos extends StatefulWidget {
  final Projection projection;
  final int heroId;

  MovieInfos({Key key, this.projection, this.heroId}) : super(key: key);

  @override
  _MovieInfosState createState() => _MovieInfosState(projection, heroId);
}

class _MovieInfosState extends State<MovieInfos> {
  final Projection projection;
  final int heroId;

  @override
  void initState() {
    super.initState();
    movieDetailBloc..getMovieDetail(projection.movie.id);
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
                  projection.movie.date.toString() +
                  heroId.toString(),
              child: Text(
                ((DateTime.now().isAfter(
                              projection.date.add(
                                Duration(minutes: projection.movie.runtime),
                              ),
                            )
                                ? "(Played) "
                                : "") +
                            (DateTime.now().isBefore(
                                      projection.date.add(
                                        Duration(
                                            minutes: projection.movie.runtime),
                                      ),
                                    ) &&
                                    DateTime.now().isAfter(projection.date)
                                ? "(Playing Now) "
                                : "") +
                            DateFormat('EEE, d MMM,').format(projection.date) +
                            DateFormat(' HH:mm').format(projection.date) ??
                        "Sat 14 Nov, 17:30") +
                    ", " +
                    projection.salle.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Style.Colors.secondaryColor),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: _padding,
          child: Text(
            "Resumé:",
            textAlign: TextAlign.left,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Padding(
          padding: _padding,
          child: Text(
            projection.movie.overview,
            textAlign: TextAlign.left,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: _padding,
          child: Text(
            "Casting:",
            textAlign: TextAlign.left,
            //maxLines: 1,
            //overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(height: 5),
        MovieCast(movie: projection.movie),
        SizedBox(height: 10),
        SizedBox(height: 10),
        Padding(
          padding: _padding,
          child: Text(
            "Bande annonce:",
            textAlign: TextAlign.left,
            //maxLines: 1,
            //overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(height: 5),
        MovieVideo(movie: projection.movie),
        SizedBox(height: 10),
        MovieImages(movie: projection.movie)
      ],
    );
  }
}
