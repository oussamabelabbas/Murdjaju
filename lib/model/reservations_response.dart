import 'package:murdjaju/model/projection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:murdjaju/model/reservation.dart';

class ReservationsResponse {
  final List<Reservation> reservations;
  final String error;

  ReservationsResponse(
    this.reservations,
    this.error,
  );

  ReservationsResponse.fromSnapshots(List<DocumentSnapshot> reservations)
      : reservations = reservations.map((reservation) => new Reservation.fromSnapshots(reservation)).toList(),
        error = "";

  ReservationsResponse.withError(String errorValue)
      : reservations = [],
        error = errorValue;
}
