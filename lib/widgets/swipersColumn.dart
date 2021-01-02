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

class SwiperColumn extends StatefulWidget {
  final List<Projection> projections;
  final int heroId;

  SwiperColumn({Key key, this.heroId, this.projections}) : super(key: key);

  @override
  _SwiperColumnState createState() => _SwiperColumnState(heroId, projections);
}

class _SwiperColumnState extends State<SwiperColumn> {
  final List<Projection> projections;
  final int heroId;

  _SwiperColumnState(this.heroId, this.projections);

  SwiperController _swiperController = SwiperController();
  SwiperControl _swiperControl;
  int initialIndex;

  List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'Decenmebr'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    _swiperControl = SwiperControl(iconNext: null, iconPrevious: null);
    initialIndex = projections.indexWhere(
      (proj) => proj.date.add(Duration(minutes: proj.movie.runtime)).isAfter(
            DateTime.now(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) return Text('Error');
    return Stack(
      children: [
        Container(
          child: Swiper(
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
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Style.Colors.mainColor.withOpacity(.4),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              height: AppBar().preferredSize.height,
              child: Text(
                DateFormat('EEEEEE d MMM y. HH:mm.', 'fr-FR').format(projections.first.date),
                style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.width,
              child: Swiper(
                controller: _swiperController,
                control: _swiperControl,
                itemCount: projections.length,
                loop: false,
                viewportFraction: 0.67,
                scale: 0.7,
                onIndexChanged: (value) => _swiperController.move(value),
                itemBuilder: (context, index) {
                  NetworkImage thumbnail = NetworkImage(projections[index].movie.isShow ? projections[index].movie.poster : ('https://image.tmdb.org/t/p/w92/' + projections[index].movie.poster));
                  NetworkImage image = NetworkImage(
                    projections[index].movie.isShow ? projections[index].movie.poster : ('https://image.tmdb.org/t/p/w780/' + projections[index].movie.poster),
                  );
                  AssetImage asset = AssetImage(
                    'assets/placeholder.png',
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
                            heroId: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        //color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          //color: Colors.orange,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Hero(
                          tag: projections[index].movie.id + index.toString(),
                          child: ProgressiveImage(
                            fit: BoxFit.cover,
                            blur: 10,
                            alignment: Alignment.center,

                            placeholder: asset,
                            // size: 1.87KB
                            thumbnail: thumbnail,
                            // size: 1.29MB
                            image: image,
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            // ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: Swiper(
                scrollDirection: Axis.horizontal,
                loop: false,
                //index: initialIndex == -1 ? projections.length - 1 : initialIndex,
                physics: NeverScrollableScrollPhysics(),
                control: _swiperControl,
                controller: _swiperController,
                itemCount: projections.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    //color: Colors.orange,
                    child: Column(
                      children: [
                        Spacer(),
                        Hero(
                          tag: projections[index].id.toString() + projections[index].date.toString() + index.toString(),
                          child: Text(
                            ((DateTime.now().isAfter(
                                          projections[index].date.add(
                                                Duration(minutes: projections[index].movie.runtime),
                                              ),
                                        )
                                            ? "(Played) "
                                            : "") +
                                        (DateTime.now().isBefore(
                                                  projections[index].date.add(
                                                        Duration(minutes: projections[index].movie.runtime),
                                                      ),
                                                ) &&
                                                DateTime.now().isAfter(projections[index].date)
                                            ? "(Playing Now) "
                                            : "") +
                                        DateFormat('EEE, d MMM', 'fr-FR').format(projections[index].date) +
                                        DateFormat(' HH:mm').format(projections[index].date) ??
                                    "Sat 14 Nov, 17:30") +
                                ", " +
                                projections[index].salle.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.button.copyWith(color: Style.Colors.secondaryColor),
                          ),
                        ),
                        Spacer(),
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
                        Text(
                          "\n" + projections[index].movie.overview,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: 3,
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
            ),
          ],
        ),
      ],
    );
    // return
  }
}
