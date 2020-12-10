import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/bloc/get_weeks_bloc.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class BookingScreen extends StatefulWidget {
  final Projection projection;
  BookingScreen({Key key, this.projection}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState(projection);
}

class _BookingScreenState extends State<BookingScreen> {
  final Projection projection;

  _BookingScreenState(this.projection);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weeksListBloc..getWeeks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          projection.movie.title,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Style.Colors.mainColor,
        leading: IconButton(
          onPressed: () async {},
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Style.Colors.titleColor,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .85,
                //   height: MediaQuery.of(context).size.width,
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(10),
                  itemCount: projection.salle.capacity,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: projection.salle.rowLength,
                    childAspectRatio: 1,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return index % projection.salle.rowLength == 3 ||
                            index % projection.salle.rowLength ==
                                projection.salle.rowLength - 4
                        ? SizedBox()
                        : Container(
                            child: Center(
                              child: Text(projection.places[index].id),
                            ),
                            decoration: BoxDecoration(
                              color: Style.Colors.titleColor,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
