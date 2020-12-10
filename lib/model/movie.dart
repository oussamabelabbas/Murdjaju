import 'package:intl/intl.dart';
import 'package:murdjaju/model/genre.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final int id;
  final int runtime;
  final String title;
  final String originalTitle;
  final String backPoster;
  final String poster;
  final String overview;
  final List<Genre> genres;
  final DateTime date;

  Movie(
    this.id,
    this.title,
    this.backPoster,
    this.poster,
    this.overview,
    this.runtime,
    this.originalTitle,
    this.genres,
    this.date,
  );

  Movie.fromSnap(DocumentSnapshot snap)
      : id = snap["id"],
        title = snap["title"],
        backPoster = snap["backdrop_path"],
        poster = snap["poster_path"],
        overview = snap["overview"],
        originalTitle = snap["original_title"],
        runtime = snap["runtime"],
        date = DateTime.fromMillisecondsSinceEpoch(DateFormat("yyyy-MM-dd")
            .parse(snap["release_date"])
            .millisecondsSinceEpoch),
        genres =
            (snap["genres"] as List).map((e) => new Genre.fromJson(e)).toList();

  Movie.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        backPoster = json["backdrop_path"],
        poster = json["poster_path"],
        overview = json["overview"],
        date = DateTime(2020, 10, 25),
        originalTitle = json["original_title"],
        runtime = json["runtime"],
        genres = json["genres"] != null
            ? (json["genres"] as List)
                .map((e) => new Genre.fromJson(e))
                .toList()
            : [];
}
