import 'package:murdjaju/model/reservations_response.dart';
import 'package:murdjaju/model/week_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class ReservationsListBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<ReservationsResponse> _subject = BehaviorSubject<ReservationsResponse>();

  Future getReservations(String projectionId) async {
    ReservationsResponse response = await _repository.getProjectionReservations(projectionId);
    _subject.sink.add(response);
  }

  void dispose() async {
    await _subject.drain();

    _subject.close();
  }

  BehaviorSubject<ReservationsResponse> get subject => _subject;
}

final reservationsListBloc = ReservationsListBloc();
