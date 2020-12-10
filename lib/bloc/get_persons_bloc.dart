import 'package:murdjaju/model/person_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class PersonsListBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<PersonResponse> _subject =
      BehaviorSubject<PersonResponse>();

  getPopularMovies() async {
    PersonResponse response = await _repository.getPersons();
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

  BehaviorSubject<PersonResponse> get subject => _subject;
}

final popularBloc = PersonsListBloc();
