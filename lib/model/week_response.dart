import 'package:murdjaju/model/week.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeekResponse {
  final List<Week> weeks;
  final String error;

  WeekResponse(
    this.weeks,
    this.error,
  );

  WeekResponse.fromSnapshots(
    List<DocumentSnapshot> weeks,
    List<DocumentSnapshot> movies,
    List<DocumentSnapshot> salles,
    List<List<DocumentSnapshot>> projs,
  )   : weeks = weeks
            .map(
              (doc) => new Week.fromSnap(
                  doc, movies, salles, projs[weeks.indexOf(doc)]),
            )
            .toList(),
        error = "";

  WeekResponse.withError(String errorValue)
      : weeks = List(),
        error = errorValue;
}
