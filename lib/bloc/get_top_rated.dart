import 'package:murdjaju/model/movie_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class TopRatedListBlpoc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<MovieResponse> _subject =
      BehaviorSubject<MovieResponse>();

  getMovies() async {
    MovieResponse response = await _repository.getTopRatedMovies();
    _subject.sink.add(response);
  }

  @override
  void dispose() {
    _subject.close();
  }

  BehaviorSubject<MovieResponse> get subject => _subject;
}

final topRatedBloc = TopRatedListBlpoc();
