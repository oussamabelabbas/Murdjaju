import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:murdjaju/bloc/get_weeks_bloc.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class BookingScreen extends StatefulWidget {
  final Projection projection;
  final int heroId;
  BookingScreen({Key key, this.projection, this.heroId}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState(projection);
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final Projection projection;

  _BookingScreenState(this.projection);
  AnimationController _hideFabAnimController;

  List<int> _selectedSeats = [];
  int _numberOfSeats = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      value: 1, // initially visible
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Weeks")
          .doc(projection.weekId)
          .collection("Projections")
          .doc(projection.id.toString())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );

        DateTime _date = DateTime.fromMillisecondsSinceEpoch(
            snapshot.data["date"].millisecondsSinceEpoch);
        String _salleId = snapshot.data['salleId'];
        List<Place> _places = (snapshot.data["places"] as List)
            .map((e) => new Place.fromJson(e))
            .toList();
        int _prix = snapshot.data['prixTicket'];

        _selectedSeats.removeWhere(
          (_element) => (snapshot.data["places"] as List)
              .where((element) => element['isReserved'])
              .toList()
              .contains(_element),
        );

        return Scaffold(
          backgroundColor: Style.Colors.mainColor,
          appBar: AppBar(
            centerTitle: true,
            title: Hero(
              tag: projection.movie.id.toString() +
                  projection.movie.title.toString() +
                  widget.heroId.toString(),
              child: Text(
                projection.movie.title,
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: Colors.white),
              ),
            ),
            backgroundColor: Style.Colors.mainColor,
            leading: IconButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: Style.Colors.titleColor,
              ),
            ),
          ),
          floatingActionButton: _selectedSeats.isEmpty
              ? null
              : FadeTransition(
                  opacity: _hideFabAnimController,
                  child: ScaleTransition(
                    scale: _hideFabAnimController,
                    child: FloatingActionButton.extended(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () async {
                        /*   if (_selectedSeats.indexWhere((_element) =>
                                (snapshot.data["places"] as List)
                                    .where((element) => element['isReserved'])
                                    .toList()
                                    .contains(_element)) !=
                            -1)
                          Fluttertoast.showToast(
                            msg:
                                "OOps, qlq'un viens de voler votre place, merci de la changer svp",
                          );
                        else */
                        {
                          await showDialog(
                            context: context,
                            barrierColor:
                                Style.Colors.secondaryColor.withOpacity(.1),
                            barrierDismissible: true,
                            useRootNavigator: true,
                            builder: (context) => AlertDialog(
                              backgroundColor: Style.Colors.mainColor,
                              actions: [
                                IconButton(
                                  icon: Icon(MdiIcons.cancel),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(MdiIcons.ticketConfirmation),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                              contentPadding: EdgeInsets.all(10),
                              content: Container(
                                // width: MediaQuery.of(context).size.width / 2,
                                // height: MediaQuery.of(context).size.width / 2,
                                // color: Style.Colors.mainColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Film: ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(color: Colors.white),
                                          ),
                                          TextSpan(
                                            text: projection.movie.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color: Style
                                                        .Colors.secondaryColor),
                                          ),
                                        ],
                                      ),
                                      //"Film: " + projection.movie.title,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Date: ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(color: Colors.white),
                                          ),
                                          TextSpan(
                                            text: DateFormat.MMMMEEEEd("fr-FR")
                                                .format(
                                              projection.date,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color: Style
                                                        .Colors.secondaryColor),
                                          ),
                                        ],
                                      ),
                                      //"Film: " + projection.movie.title,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Places Réservé: ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(color: Colors.white),
                                          ),
                                          TextSpan(
                                            text: _selectedSeats.fold(
                                              "",
                                              (previousValue, element) =>
                                                  previousValue +
                                                  projection.places[element].id
                                                      .toString() +
                                                  ", ",
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color: Style
                                                        .Colors.secondaryColor),
                                          ),
                                        ],
                                      ),
                                      //"Film: " + projection.movie.title,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      label: Text("Réserver"),
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
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.network(
                          'https://image.tmdb.org/t/p/w780/' +
                              projection.movie.backPoster,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.width * 439 / 780,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Style.Colors.mainColor
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Hero(
                          tag: projection.movie.id.toString() +
                              projection.movie.date.toString() +
                              widget.heroId.toString(),
                          child: Text(
                            ((DateTime.now().isAfter(
                                          projection.date.add(
                                            Duration(
                                                minutes:
                                                    projection.movie.runtime),
                                          ),
                                        )
                                            ? "(Played) "
                                            : "") +
                                        (DateTime.now().isBefore(
                                                  projection.date.add(
                                                    Duration(
                                                        minutes: projection
                                                            .movie.runtime),
                                                  ),
                                                ) &&
                                                DateTime.now()
                                                    .isAfter(projection.date)
                                            ? "(Playing Now) "
                                            : "") +
                                        DateFormat('EEE, d MMM,')
                                            .format(projection.date) +
                                        DateFormat(' HH:mm')
                                            .format(projection.date) ??
                                    "Sat 14 Nov, 17:30") +
                                ", " +
                                projection.salle.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: Style.Colors.secondaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .85,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Nombre de places :",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.white)),
                        IconButton(
                          icon: Icon(MdiIcons.minusCircle),
                          splashRadius: 15,
                          onPressed: () {
                            if (_numberOfSeats != 1) {
                              if (_selectedSeats.length == _numberOfSeats) {
                                _selectedSeats.removeLast();
                                _numberOfSeats--;
                              } else
                                _numberOfSeats--;
                              setState(() {});
                            }
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(_numberOfSeats.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Colors.white)),
                        ),
                        IconButton(
                          icon: Icon(MdiIcons.plusCircle),
                          splashRadius: 15,
                          onPressed: () {
                            _numberOfSeats++;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .85,
                    //   height: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(10),
                      itemCount: projection.salle.capacity
                      /* +
                      2 *
                          projection.salle.capacity ~/
                          projection.salle.rowLength */
                      ,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: projection.salle.rowLength,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return /* index % projection.salle.rowLength == 3 ||
                            index % projection.salle.rowLength ==
                                projection.salle.rowLength - 4
                        ? SizedBox()
                        : */
                            InkWell(
                          onTap: () {
                            if (!_places[index].isReserved) {
                              if (_selectedSeats.length == _numberOfSeats)
                                _selectedSeats.removeAt(0);
                              setState(() {
                                _selectedSeats.add(index);
                              });
                            }
                            setState(() {});
                          },
                          child: Container(
                            child: Center(
                              child: Text(_places[index].id),
                            ),
                            decoration: BoxDecoration(
                              color: _places[index].isReserved
                                  ? Style.Colors.titleColor.withOpacity(.25)
                                  : _selectedSeats.contains(index)
                                      ? Style.Colors.secondaryColor
                                      : Style.Colors.titleColor,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .85,
                    child: Row(
                      children: [
                        Container(
                          width: (MediaQuery.of(context).size.width * .85) /
                              projection.salle.rowLength /
                              2,
                          height: (MediaQuery.of(context).size.width * .85) /
                              projection.salle.rowLength /
                              2,
                          decoration: BoxDecoration(
                            color: Style.Colors.titleColor.withOpacity(.25),
                            shape: BoxShape.circle,
                            /* borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ), */
                          ),
                        ),
                        Text(
                          " Réservé",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.white),
                        ),
                        Spacer(),
                        Container(
                          width: (MediaQuery.of(context).size.width * .85) /
                              projection.salle.rowLength /
                              2,
                          height: (MediaQuery.of(context).size.width * .85) /
                              projection.salle.rowLength /
                              2,
                          decoration: BoxDecoration(
                            color: Style.Colors.secondaryColor,
                            shape: BoxShape.circle,
                            /* borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ), */
                          ),
                        ),
                        Text(
                          " Ma place",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.white),
                        ),
                        Spacer(),
                        Container(
                          width: (MediaQuery.of(context).size.width * .85) /
                              projection.salle.rowLength /
                              2,
                          height: (MediaQuery.of(context).size.width * .85) /
                              projection.salle.rowLength /
                              2,
                          decoration: BoxDecoration(
                            color: Style.Colors.titleColor,
                            shape: BoxShape.circle,
                            /* borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ), */
                          ),
                        ),
                        Text(
                          " Vide",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
