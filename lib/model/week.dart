import 'package:murdjaju/model/projection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Week {
  final String id;
  final DateTime startDate;
  final int numberOfDays;
  final List<Projection> projections;

  Week(this.id, this.startDate, this.numberOfDays, this.projections);

  Week.fromSnap(
    DocumentSnapshot week,
    List<DocumentSnapshot> movies,
    List<DocumentSnapshot> salles,
    List<DocumentSnapshot> projs,
  )   : id = week.id,
        startDate = DateTime.fromMillisecondsSinceEpoch(
            week["startDate"].millisecondsSinceEpoch),
        numberOfDays = week['numberOfDays'],
        projections = projs
            .map((proj) => new Projection.fromJson(proj, movies, salles))
            .toList();
}
