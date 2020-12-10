import 'package:murdjaju/model/projection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectionResponse {
  final List<Projection> projections;
  final String error;

  ProjectionResponse(
    this.projections,
    this.error,
  );

  ProjectionResponse.fromSnapshots(List<DocumentSnapshot> projections,
      List<DocumentSnapshot> movies, List<DocumentSnapshot> salles)
      : projections = projections
            .map(
              (projection) => new Projection.fromSnaps(
                projection,
                movies[movies.indexWhere((movie) =>
                    movie['id'].toString() == projection['movieId'])],
                salles[salles.indexWhere((salle) =>
                    salle['id'].toString() == projection['salleId'])],
              ),
            )
            .toList(),
        error = "";

  ProjectionResponse.withError(String errorValue)
      : projections = List(),
        error = errorValue;
}
