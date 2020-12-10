import 'package:murdjaju/model/movie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovieResponse {
  final List<Movie> movies;
  final String error;

  MovieResponse(this.movies, this.error);

  MovieResponse.fromSnapshots(List<DocumentSnapshot> snaps)
      : movies = snaps.map((snap) => new Movie.fromSnap(snap)).toList(),
        error = "";

  MovieResponse.fromJson(Map<String, dynamic> json)
      : movies = (json["results"] as List)
            .map((e) => new Movie.fromJson(e))
            .toList(),
        error = "";

  MovieResponse.withError(String errorValue)
      : movies = List(),
        error = errorValue;
}
