import 'package:murdjaju/model/projection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final DocumentReference reference;
  final String projectionId;
  final bool confirmed;
  final String userId;
  final DateTime date;
  final List<String> placesIds;
  final String movieTitle;
  final String salleName;
  final DateTime projectionDate;

  Reservation(
    this.id,
    this.reference,
    this.projectionId,
    this.confirmed,
    this.userId,
    this.date,
    this.placesIds,
    this.movieTitle,
    this.salleName,
    this.projectionDate,
  );

  Reservation.fromSnapshots(DocumentSnapshot reservation)
      : id = reservation.id,
        reference = reservation.reference,
        projectionId = reservation['projectionId'],
        confirmed = reservation['confirmed'],
        userId = reservation['userId'],
        date = DateTime.fromMillisecondsSinceEpoch(reservation["date"].millisecondsSinceEpoch),
        placesIds = (reservation['placesIds'] as List).map((e) => e.toString()).toList(),
        movieTitle = reservation['movieTitle'],
        salleName = reservation['salleName'],
        projectionDate = DateTime.fromMillisecondsSinceEpoch(reservation["projectionDate"].millisecondsSinceEpoch);

  Reservation.withError(String errorValue)
      : id = null,
        reference = null,
        projectionId = null,
        confirmed = false,
        userId = null,
        date = DateTime.now(),
        placesIds = [],
        movieTitle = null,
        salleName = null,
        projectionDate = DateTime.now();
}
