import 'package:murdjaju/model/projection_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class ProjectionListBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<ProjectionResponse> _subject =
      BehaviorSubject<ProjectionResponse>();

  getMovies(int index) async {
    ProjectionResponse response = await _repository.getProjectionsList(index);
    _subject.sink.add(response);
  }

  void dispose() async {
    print("projection list disposed");
    await _subject.drain();

    _subject.close();
  }

  BehaviorSubject<ProjectionResponse> get subject => _subject;
}

final projectionListBloc = ProjectionListBloc();
