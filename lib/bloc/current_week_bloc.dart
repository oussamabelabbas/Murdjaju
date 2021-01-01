import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/model/week.dart';

import '../model/week_response.dart';
import '../repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class CurrentWeekBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<Week> _subject = BehaviorSubject<Week>();
  final BehaviorSubject<Week> _subjectReserve = BehaviorSubject<Week>();

  Future filterCurrentWeek(String id, String cineWhat, List<int> genresIdList, List<String> sallesIdList) async {
    _subject.sink.add(Week(_subject.value.id, _subject.value.startDate, _subject.value.numberOfDays, _subject.value.projections, "Loading..."));

    Week response;
    if (_subject.value.id != id) {
      response = await _repository.getCurrentWeek(id);
      _subjectReserve.sink.add(response);
    } else
      response = _subjectReserve.value;

    List<Projection> projections = response.projections
        .where(
          (proj) => (cineWhat == null || proj.cine == cineWhat) && (genresIdList.isEmpty || proj.movie.genres.map<int>((e) => e.id).toList().where((element) => genresIdList.contains(element)).isNotEmpty) && (sallesIdList.isEmpty || sallesIdList.indexWhere((element) => proj.salle.id == element) != -1),
        )
        .toList();
    response = Week(response.id, response.startDate, response.numberOfDays, projections, response.error);
    _subject.sink.add(response);
  }

  Future getCurrentWeek(String id) async {
    Week response = await _repository.getCurrentWeek(id);
    _subject.sink.add(response);
    _subjectReserve.sink.add(response);
  }

  void dispose() async {
    print("projection list disposed");
    await _subject.drain();

    _subject.close();
  }

  BehaviorSubject<Week> get subject => _subject;
}

final currentWeekBloc = CurrentWeekBloc();
