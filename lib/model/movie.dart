import 'package:intl/intl.dart';
import 'package:murdjaju/model/genre.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final int runtime;
  final String title;
  final String originalTitle;
  final String backPoster;
  final String poster;
  final String overview;
  final List<Genre> genres;
  final bool isShow;
  final String video;
  //final DateTime date;

  Movie(
    this.id,
    this.title,
    this.backPoster,
    this.poster,
    this.overview,
    this.runtime,
    this.originalTitle,
    this.genres,
    this.isShow,
    this.video,

    //  this.date,
  );

  Movie.fromSnap(DocumentSnapshot snap)
      : id = snap["id"].toString(),
        title = snap["title"],
        backPoster = snap["backdrop_path"],
        poster = snap["poster_path"],
        overview = snap["overview"],
        originalTitle = snap["original_title"],
        runtime = snap["runtime"],
        //  date = DateTime.fromMillisecondsSinceEpoch(DateFormat("yyyy-MM-dd").parse(snap["release_date"]).millisecondsSinceEpoch),
        genres = (snap["genres"] as List).map((e) => new Genre.fromJson(e)).toList(),
        isShow = snap['isShow'],
        video = snap['isShow'] ? snap['trailer'] : null;

  Movie.fromJson(Map<String, dynamic> json)
      : id = json["id"].toString(),
        title = json["title"],
        backPoster = json["backdrop_path"],
        poster = json["poster_path"],
        overview = json["overview"],
        //   date = DateTime(2020, 10, 25),
        originalTitle = json["original_title"],
        runtime = json["runtime"],
        genres = json["genres"] != null ? (json["genres"] as List).map((e) => new Genre.fromJson(e)).toList() : [],
        isShow = json['isShow'],
        video = json['isShow'] ? json['trailer'] : null;

  Movie.fromProjection(DocumentSnapshot projection)
      : id = projection["movieId"].toString(),
        title = projection["movieTitle"],
        backPoster = projection["movieBackDropPath"],
        poster = projection["moviePosterPath"],
        overview = projection["movieOverview"],
        runtime = 0,
        originalTitle = "",
        genres = (projection["genres"] as List).map((e) => new Genre.fromJson(e)).toList(),
        isShow = projection['isShow'],
        video = projection['isShow'] ? projection['trailer'] : null;

  //  date = null;
}
