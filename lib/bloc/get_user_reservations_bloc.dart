import 'package:murdjaju/model/reservation.dart';
import 'package:murdjaju/model/reservations_response.dart';
import 'package:murdjaju/model/week_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class ReservationsListBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<ReservationsResponse> _subject = BehaviorSubject<ReservationsResponse>();

  Future getReservations(String projectionId, String userId) async {
    ReservationsResponse response = await _repository.getProjectionReservations(projectionId, userId);
    _subject.sink.add(response);
  }

  Future updateReservations(Reservation reservation) async {
    List<Reservation> reservations = _subject.value.reservations;
    reservations.add(reservation);
    ReservationsResponse response = ReservationsResponse(reservations, "");
    _subject.sink.add(response);
  }

  void dispose() async {
    _subject.value = null;
  }

  BehaviorSubject<ReservationsResponse> get subject => _subject;
}

final reservationsListBloc = ReservationsListBloc();
