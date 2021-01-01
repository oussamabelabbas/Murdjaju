import 'package:murdjaju/model/projection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Week {
  final String id;
  final DateTime startDate;
  final int numberOfDays;
  final List<Projection> projections;
  final String error;

  Week(this.id, this.startDate, this.numberOfDays, this.projections, this.error);

  Week.fromMini(DocumentSnapshot week)
      : id = week.id,
        startDate = DateTime.fromMillisecondsSinceEpoch(week["startDate"].millisecondsSinceEpoch),
        numberOfDays = week['numberOfDays'],
        projections = [],
        error = "";

  Week.fromProjection(
    DocumentSnapshot week,
    List<DocumentSnapshot> salles,
    List<DocumentSnapshot> projs,
  )   : id = week.id,
        startDate = DateTime.fromMillisecondsSinceEpoch(week["startDate"].millisecondsSinceEpoch),
        numberOfDays = week['numberOfDays'],
        projections = projs.map((proj) => new Projection.fromSnap(proj, salles)).toList(),
        error = "";

  Week.fromSnaps(
    DocumentSnapshot week,
    List<DocumentSnapshot> movies,
    List<DocumentSnapshot> salles,
    List<DocumentSnapshot> projs,
  )   : id = week.id,
        startDate = DateTime.fromMillisecondsSinceEpoch(week["startDate"].millisecondsSinceEpoch),
        numberOfDays = week['numberOfDays'],
        projections = projs.map((proj) => new Projection.fromJson(proj, movies, salles)).toList(),
        error = "";

  Week.withError(String error)
      : id = error,
        startDate = DateTime(2012, 12, 12),
        numberOfDays = 0,
        projections = [],
        error = error;
}
