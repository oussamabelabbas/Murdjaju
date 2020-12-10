import 'package:murdjaju/model/cast_response.dart';
import 'package:murdjaju/model/images_response.dart';
import 'package:murdjaju/repository/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class ImagesBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<ImageResponse> _subject =
      BehaviorSubject<ImageResponse>();

  getImages(int id) async {
    ImageResponse response = await _repository.getImages(id);
    _subject.sink.add(response);
  }

  void drainStream() {
    _subject.value = null;
  }

  @mustCallSuper
  void dispose() async {
    print("projection cast disposed");

    await _subject.drain();
    _subject.close();
  }

  BehaviorSubject<ImageResponse> get subject => _subject;
}

final imagesBloc = ImagesBloc();
