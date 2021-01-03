import 'package:murdjaju/model/cast_response.dart';
import 'package:murdjaju/model/genre_response.dart';
import 'package:murdjaju/model/images_response.dart';
import 'package:murdjaju/model/movie_detail_response.dart';
import 'package:murdjaju/model/movie_response.dart';
import 'package:murdjaju/model/person_response.dart';
import 'package:murdjaju/model/projection_response.dart';
import 'package:murdjaju/model/video_response.dart';
import 'package:murdjaju/model/week.dart';
import 'package:murdjaju/model/week_response.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:tmdb_api/tmdb_api.dart';

class MovieRepository {
  final String apiKey = "3fcc3cf0902881ec381782b11cebbe92";
  final String mainUrl = "https://api.themoviedb.org/3";
  final Dio _dio = Dio();

  TMDB tmdbWithCustomLogs = TMDB(
    ApiKeys(
      "3fcc3cf0902881ec381782b11cebbe92",
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZmNjM2NmMDkwMjg4MWVjMzgxNzgyYjExY2ViYmU5MiIsInN1YiI6IjVmODg5ZGRjZTMzZjgzMDAzN2ZkZjk1NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.tLu7CRm0t78C9_NtDb4_1KC8TC3sh6nqUGXdXq2BN44",
    ),
  );

  Movies get v3TMDB => tmdbWithCustomLogs.v3.movies;

  Future<GenreResponse> getAllGenres() async {
    try {
      Map<dynamic, dynamic> response = await tmdbWithCustomLogs.v3.geners.getMovieList();
      return GenreResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return GenreResponse.withError("$error");
    }
  }

  Future<Week> getCurrentWeek(String id) async {
    try {
      QuerySnapshot weeksQuery;
      QuerySnapshot query;

      QuerySnapshot querySalles;
      List<DocumentSnapshot> salles;
      List<DocumentSnapshot> projections = [];

      DocumentSnapshot week;

      if (id != null) {
        //weeksQuery =
        week = await FirebaseFirestore.instance.collection('Weeks').doc(id.toString()).get();
        //weeksQuery.docs.first;

        query = await week.reference.collection("Projections").orderBy("date").get();
        projections = query.docs;
      } else {
        weeksQuery = await FirebaseFirestore.instance.collection('Weeks').where("endDate", isGreaterThan: new DateTime.now()).limit(1).get();
        if (weeksQuery.docs.length > 0)
          week = weeksQuery.docs.first;
        else {
          weeksQuery = await FirebaseFirestore.instance.collection('Weeks').orderBy("startDate").limitToLast(1).get();
          if (weeksQuery.docs.length > 0) week = weeksQuery.docs.last;
        }

        if (week != null) {
          query = await week.reference.collection("Projections").orderBy("date").get();
          projections = query.docs;
        }
      }

      querySalles = await FirebaseFirestore.instance.collection('Salles').get();
      salles = querySalles.docs;

      return Week.fromProjection(week, salles, projections);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return Week.withError("$error");
    }
  }

  Future<WeekResponse> getMiniWeeksList() async {
    try {
      QuerySnapshot weeksQuery = await FirebaseFirestore.instance.collection('Weeks').get();
      List<DocumentSnapshot> weeks = weeksQuery.docs;

      return WeekResponse.fromMiniSnapshot(weeks);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return WeekResponse.withError("$error");
    }
  }

  Future<WeekResponse> getWeeksList() async {
    try {
      List<List<DocumentSnapshot>> projs = [];

      QuerySnapshot weeksQuery;
      QuerySnapshot query;
      /*  QuerySnapshot queryMovies;
      List<DocumentSnapshot> movies; */
      QuerySnapshot querySalles;
      List<DocumentSnapshot> salles;

      weeksQuery = await FirebaseFirestore.instance.collection('Weeks').get();
      List<DocumentSnapshot> weeks = weeksQuery.docs;
      weeks.forEach(
        (element) async {
          query = await element.reference.collection("Projections").orderBy("date").get();
          projs.add(query.docs);
        },
      );

      /*  queryMovies = await FirebaseFirestore.instance.collection('Movies').get();
      movies = queryMovies.docs; */
      querySalles = await FirebaseFirestore.instance.collection('Salles').get();
      salles = querySalles.docs;

      return WeekResponse.fromSnapshot(weeks, salles, projs);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return WeekResponse.withError("$error");
    }
  }

  Future<ProjectionResponse> getProjectionsList(int dayIndex) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance.collection('Projections').orderBy("date", descending: false).get();
      List<DocumentSnapshot> projections = query.docs;
      QuerySnapshot queryMovies = await FirebaseFirestore.instance.collection('Movies').get();
      List<DocumentSnapshot> movies = queryMovies.docs;
      QuerySnapshot querySalles = await FirebaseFirestore.instance.collection('Salles').get();
      List<DocumentSnapshot> salles = querySalles.docs;

      return ProjectionResponse.fromSnapshots(projections, movies, salles);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return ProjectionResponse.withError("$error");
    }
  }

  Future<MovieResponse> getFirebaseList() async {
    try {
      QuerySnapshot response = await FirebaseFirestore.instance.collection('Movies').orderBy("date", descending: false).get();
      response.docs.addAll(response.docs);

      return MovieResponse.fromSnapshots(response.docs);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return MovieResponse.withError("$error");
    }
  }

  Future<MovieDetailResponse> getMovieDetail(int id) async {
    try {
      var response = await v3TMDB.getDetails(id);
      return MovieDetailResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return MovieDetailResponse.withError("$error");
    }
  }

  Future<MovieResponse> getMostPopularMovies() async {
    var params = {"language": "fr-FR", "page": 1};

    try {
      var response = await v3TMDB.getPouplar(
        language: params["language"],
        page: params["page"],
      );
      return MovieResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");
      return MovieResponse.withError("$error");
    }
  }

  Future<MovieResponse> getTopRatedMovies() async {
    var params = {"language": "fr-FR", "page": 1};

    try {
      var response = await v3TMDB.getTopRated(
        language: params["language"],
        page: params["page"],
      );
      return MovieResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");
      return MovieResponse.withError("$error");
    }
  }

  Future<MovieResponse> getNowPlayingMovies() async {
    var params = {"language": "fr-FR", "page": 1};

    try {
      var response = await v3TMDB.getNowPlaying(
        language: params["language"],
        page: params["page"],
      );
      return MovieResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");
      return MovieResponse.withError("$error");
    }
  }

  Future<ImageResponse> getImages(int id) async {
    var params = {"language": "fr-FR", "page": 1};

    try {
      var response = await tmdbWithCustomLogs.v3.movies.getImages(id, language: "");
      return ImageResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");
      return ImageResponse.withError("$error");
    }
  }

  Future<PersonResponse> getPersons() async {
    var params = {"language": "fr-FR", "page": 1};

    try {
      var response = await tmdbWithCustomLogs.v3.people.getPopular(
        language: params["language"],
        page: params["page"],
      );
      return PersonResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");
      return PersonResponse.withError("$error");
    }
  }

  Future<CastResponse> getCasts(int id) async {
    try {
      var response = await v3TMDB.getCredits(id);
      return CastResponse.fromJson(response);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return CastResponse.withError("$error");
    }
  }

  Future<VideoResponse> getVideos(int id) async {
    try {
      var response =
          //await tmdbWithCustomLogs.v3.movies.getVideos(id);
          await _dio.get("https://api.themoviedb.org/3/movie/$id/videos?api_key=3fcc3cf0902881ec381782b11cebbe92&language=fr-FR");
      print("Response ==>>>" + response.data.toString());
      //var response = await v3TMDB.getVideos(id);
      if (response.data['results'].length == 0) {
        var backUpResponse = await tmdbWithCustomLogs.v3.movies.getVideos(id);
        return VideoResponse.fromJson(backUpResponse);
      }

      return VideoResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("exeption occured : $error stackTrace: $stacktrace");

      return VideoResponse.withError("$error");
    }
  }
}
