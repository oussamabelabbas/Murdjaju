import 'package:murdjaju/model/projection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final DocumentReference reference;
  final bool confirmed;
  final String userId;
  final DateTime date;
  final List<String> placesIds;

  Reservation(
    this.id,
    this.reference,
    this.confirmed,
    this.userId,
    this.date,
    this.placesIds,
  );

  Reservation.fromSnapshots(DocumentSnapshot reservation)
      : id = reservation.id,
        reference = reservation.reference,
        confirmed = reservation['Confirmed'],
        userId = reservation['UserId'],
        date = DateTime.fromMillisecondsSinceEpoch(reservation["Date"].millisecondsSinceEpoch),
        placesIds = (reservation['PlacesIds'] as List).map((e) => e.toString()).toList();

  Reservation.withError(String errorValue)
      : id = null,
        reference = null,
        confirmed = false,
        userId = null,
        date = DateTime.now(),
        placesIds = [];
}
