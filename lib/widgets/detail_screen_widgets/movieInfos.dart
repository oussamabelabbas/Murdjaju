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
        /*  Padding(
          padding: _padding,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Hero(
              tag: heroId.toString() +
                  projection.movie.id.toString() +
                  projection.movie.date.toString(),
              child: Text(
                (DateTime.now().isAfter(
                          projection.date.add(
                            Duration(minutes: projection.movie.runtime),
                          ),
                        )
                            ? "(Played) "
                            : "") +
                        (DateTime.now().isBefore(
                                  projection.date.add(
                                    Duration(minutes: projection.movie.runtime),
                                  ),
                                ) &&
                                DateTime.now().isAfter(projection.date)
                            ? "(Playing Now) "
                            : "") +
                        DateFormat('EEE, d MMM ').format(projection.date) +
                        "at" +
                        DateFormat(' HH:mm').format(projection.date) ??
                    "Sat 14 Nov, 17:30",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.orange),
              ),
            ),
          ),
        ),
         */

        Container(
          height: 200,
          child: Row(
            children: [
              Container(
                height: 200,
                width: 200 * 2 / 3,
                child: Image.network(
                  'https://image.tmdb.org/t/p/original/' +
                      projection.movie.poster,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        ((DateTime.now().isAfter(
                                      projection.date.add(
                                        Duration(
                                            minutes: projection.movie.runtime),
                                      ),
                                    )
                                        ? "(Played) "
                                        : "") +
                                    (DateTime.now().isBefore(
                                              projection.date.add(
                                                Duration(
                                                    minutes: projection
                                                        .movie.runtime),
                                              ),
                                            ) &&
                                            DateTime.now()
                                                .isAfter(projection.date)
                                        ? "(Playing Now) "
                                        : "") +
                                    DateFormat('EEE, d MMM,')
                                        .format(projection.date) +
                                    DateFormat(' HH:mm')
                                        .format(projection.date) ??
                                "Sat 14 Nov, 17:30") +
                            ", " +
                            projection.salle.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Style.Colors.secondaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        /* Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 70,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white24,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Text(
                      "Genre",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      projection.movie.genres[0].name,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.orange),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Text(
                      "Durée",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      Duration(hours: projection.movie.runtime ~/ 60)
                              .inHours
                              .toString() +
                          "h " +
                          Duration(minutes: projection.movie.runtime % 60)
                              .inMinutes
                              .toString(),
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.orange),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Text(
                      "Salle",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      projection.salle.name.replaceAll("salle ", ""),
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
            //    color: Colors.white,
            /* child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(5),
            itemCount: projection.movie.genres.length + 1,
            itemBuilder: (context, index) {
              return index == 0
                  ? Container(
                      // width: 65,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white.withOpacity(.35),
                      ),
                      child: Center(
                        child: Text(
                          projection.movie.runtime.toString() + " mins",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white.withOpacity(.35),
                      ),
                      child: Center(
                        child: Text(
                          projection.movie.genres[index - 1].name,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    );
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 5);
            },
          ), */
          ),
        ), */
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

        /*  Hero(
          tag: projection.movie.id + heroId,
          child: Text(
            "Sat 14 Nov, 17:30",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.orange),
          ),
        ), */
      ],
    );
  }
}
