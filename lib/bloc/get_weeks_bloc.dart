import 'package:murdjaju/model/week_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class WeeksListBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<WeekResponse> _subject = BehaviorSubject<WeekResponse>();

  Future getMiniWeeks() async {
    WeekResponse response = await _repository.getMiniWeeksList();
    _subject.sink.add(response);
  }

  Future getWeeks() async {
    WeekResponse response = await _repository.getWeeksList();
    _subject.sink.add(response);
  }

  void dispose() async {
    print("projection list disposed");
    await _subject.drain();

    _subject.close();
  }

  BehaviorSubject<WeekResponse> get subject => _subject;
}

final weeksListBloc = WeeksListBloc();
