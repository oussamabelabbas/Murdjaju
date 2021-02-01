import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/screens/detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intl/intl.dart';
import 'package:progressive_image/progressive_image.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class SwiperColumn extends StatefulWidget {
  final List<Projection> projections;
  SwiperColumn({Key key, this.projections}) : super(key: key);

  @override
  _SwiperColumnState createState() => _SwiperColumnState(projections);
}

class _SwiperColumnState extends State<SwiperColumn> {
  final List<Projection> projections;
  _SwiperColumnState(this.projections);

  SwiperController _swiperController = SwiperController();
  SwiperControl _swiperControl;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _swiperControl = SwiperControl(iconNext: null, iconPrevious: null);
  }

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) return Text('Error');
    return Stack(
      children: [
        _backgroundSwiper(),
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Style.Colors.mainColor.withOpacity(.4),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(20),
                    child: Text(
                      DateTime.now().day == projections.first.date.day ? "Aujourd'hui" : DateFormat('EEEEEE d MMM', 'fr-FR').format(projections.first.date).capitalize(),
                      style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _mainSwiper(),
                  _textSwiper(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textSwiper() => Expanded(
        child: Swiper(
          loop: false,
          control: _swiperControl,
          itemCount: projections.length,
          controller: _swiperController,
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Spacer(),
                  Text(
                    "à " +
                        DateFormat('HH:mm ').format(projections[index].date) +
                        (DateTime.now().isAfter(
                          projections[index].date.add(
                                Duration(minutes: projections[index].movie.runtime),
                              ),
                        )
                            ? "(Déjà joué) "
                            : "") +
                        (DateTime.now().isBefore(
                                  projections[index].date.add(
                                        Duration(minutes: projections[index].movie.runtime),
                                      ),
                                ) &&
                                DateTime.now().isAfter(projections[index].date)
                            ? "(En train de jouer) "
                            : "") +
                        "\n" +
                        projections[index].salle.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Style.Colors.secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Spacer(flex: 2),
                  Hero(
                    tag: projections[index].movie.id.toString() + projections[index].movie.title.toString() + index.toString(),
                    child: Text(
                      projections[index].movie.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    projections[index].movie.overview,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Spacer(),
                ],
              ),
            );
          },
        ),
      );

  Widget _mainSwiper() => AspectRatio(
        aspectRatio: 1,
        child: Container(
          child: Swiper(
            controller: _swiperController,
            control: _swiperControl,
            itemCount: projections.length,
            loop: false,
            viewportFraction: 0.67,
            scale: 0.7,
            onIndexChanged: (value) => _swiperController.move(value),
            itemBuilder: (context, index) {
              AssetImage asset = AssetImage('assets/myGiffy.gif');

              NetworkImage thumbnail = NetworkImage(projections[index].movie.isShow ? projections[index].movie.poster : ('https://image.tmdb.org/t/p/w92/' + projections[index].movie.poster));
              NetworkImage image = NetworkImage(
                projections[index].movie.isShow ? projections[index].movie.poster : ('https://image.tmdb.org/t/p/w780/' + projections[index].movie.poster),
              );
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(
                        projection: projections[index],
                        image: image,
                        thumbnail: thumbnail,
                        asset: asset,
                        heroIndex: index,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: projections[index].movie.id + projections[index].movie.poster + index.toString(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ProgressiveImage(
                      blur: 10,
                      image: image,
                      fit: BoxFit.cover,

                      placeholder: asset,
                      thumbnail: thumbnail,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      // ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  Widget _backgroundSwiper() => ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Swiper(
            physics: BouncingScrollPhysics(),
            controller: _swiperController,
            control: _swiperControl,
            itemCount: projections.length,
            loop: false,
            itemBuilder: (context, index) {
              return Image.network(
                projections[index].movie.isShow ? projections[index].movie.poster : 'https://image.tmdb.org/t/p/w92/' + projections[index].movie.poster,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      );
}
