import 'package:murdjaju/model/cast_response.dart';
import 'package:murdjaju/model/genre_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class GenresListBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<GenreResponse> _subject = BehaviorSubject<GenreResponse>();

  getGenres() async {
    GenreResponse response = await _repository.getAllGenres();
    _subject.sink.add(response);
  }

  void drainStream() {
    _subject.value = null;
  }

  @mustCallSuper
  void dispose() async {
    await _subject.drain();
    _subject.close();
  }

  BehaviorSubject<GenreResponse> get subject => _subject;
}

final genresListBloc = GenresListBloc();
