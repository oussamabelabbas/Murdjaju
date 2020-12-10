import 'package:murdjaju/model/genre.dart';

class MovieDetail {
  final int id;
  final int budget;
  final bool adult;
  final List<Genre> genres;
  final String releaseDate;
  final int runtime;
  final String tagline;

  MovieDetail(
    this.id,
    this.budget,
    this.adult,
    this.genres,
    this.releaseDate,
    this.runtime,
    this.tagline,
  );

  MovieDetail.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        budget = json["budget"],
        adult = json["adult"],
        releaseDate = json["release_Date"],
        runtime = json["runtime"],
        tagline = json["tagline"],
        genres =
            (json["genres"] as List).map((e) => new Genre.fromJson(e)).toList();
}
