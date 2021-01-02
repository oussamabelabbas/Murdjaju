import 'package:murdjaju/bloc/get_casts_bloc.dart';
import 'package:murdjaju/model/cast.dart';
import 'package:murdjaju/model/cast_response.dart';
import 'package:murdjaju/model/movie.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progressive_image/progressive_image.dart';

class MovieCast extends StatefulWidget {
  final Movie movie;

  MovieCast({Key key, this.movie}) : super(key: key);

  @override
  _MovieCastState createState() => _MovieCastState(movie);
}

class _MovieCastState extends State<MovieCast> {
  final Movie movie;

  _MovieCastState(this.movie);

  List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'Decenmebr'];

  @override
  void initState() {
    super.initState();
    castsBloc..getCasts(int.parse(movie.id));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    castsBloc..drainStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: castsBloc.subject.stream,
      builder: (context, AsyncSnapshot<CastResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.error != null && snapshot.data.error.length > 0) {
            return _buildErrorWidget(snapshot.data);
          }

          return _buildCastWidget(snapshot.data);
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.data);
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildCastWidget(CastResponse data) {
    List<Cast> cast = data.casts;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 130,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (context, index) => SizedBox(width: 5),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                height: 120,
                width: 80,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: cast[index].image != null
                    ? ProgressiveImage(
                        height: 120,
                        width: 80,
                        placeholder: AssetImage('assets/Netflix_Symbol_RGB.png'),
                        thumbnail: NetworkImage(
                          "https://image.tmdb.org/t/p/w45/" + cast[index].image,
                        ),
                        image: NetworkImage(
                          "https://image.tmdb.org/t/p/h632/" + cast[index].image,
                        ),
                      )
                    : Icon(Icons.person),
              ),
              /*  Container(
                height: 120,
                width: 80,
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    end: Alignment.topCenter,
                    begin: Alignment.bottomCenter,
                    colors: [
                      Style.Colors.mainColor,
                      Style.Colors.mainColor.withOpacity(0)
                    ],
                    stops: [0, .5],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cast[index].character,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: Colors.white,
                            decorationStyle: TextDecorationStyle.double,
                            decorationColor: Colors.black,
                          ),
                    ),
                    Text(
                      "By",
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: Style.Colors.titleColor,
                          ),
                    ),
                    Text(
                      cast[index].name,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: Style.Colors.titleColor,
                          ),
                    ),
                  ],
                ),
              ) */
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(CastResponse error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: Icon(MdiIcons.exclamation, color: Colors.grey),
          ),
          Text(
            "Something went wrong :",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            error.error,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 190,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                backgroundColor: Style.Colors.mainColor,
                valueColor: AlwaysStoppedAnimation<Color>(Style.Colors.secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
