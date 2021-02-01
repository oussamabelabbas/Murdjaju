import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/bloc/get_user_reservations_bloc.dart';
import 'package:murdjaju/providers/auth.dart';
import 'package:murdjaju/model/projection.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/model/reservation.dart';
import 'package:murdjaju/model/reservations_response.dart';
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
//import 'package:qrscan/qrscan.dart' as scanner;

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class BookingScreen extends StatefulWidget {
  final Projection projection;
  final int heroId;
  BookingScreen({Key key, this.projection, this.heroId}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState(projection);
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  final Projection projection;

  _BookingScreenState(this.projection);
  AnimationController _hideFabAnimController;

  List<String> alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

  List<String> _selectedSeats = [];
  List<String> _seats;
  int _numberOfSeats = 1;
  bool _loading = false;
  UserAuth auth;

  TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    reservationsListBloc.getReservations(projection.id);
    auth = Provider.of<UserAuth>(context, listen: false);
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      value: 0, // initially visible
    );
    _seats = List.generate(
      projection.salle.capacity,
      (index) => alphabet[index ~/ projection.salle.rowLength] + (index % projection.salle.rowLength + 1).toString(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    reservationsListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 10,
              child: Image.network(
                'https://image.tmdb.org/t/p/w780/' + projection.movie.backPoster,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  Widget loader = Loader().loader;
                  return Center(child: loader);
                },
              ),
            ),
          ),
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }

  Widget _buildScreen() => StreamBuilder(
        stream: reservationsListBloc.subject.stream,
        builder: (context, AsyncSnapshot<ReservationsResponse> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.error != null && snapshot.data.error.length > 0) {
              return _buildErrorWidget(snapshot.data);
            }
            if (snapshot.data.reservations.indexWhere((element) => element.userId == auth.user.uid) == -1) return _buildReservationScreenBuilder(snapshot.data);
            return _buildQrScreenBuilder(snapshot.data.reservations[snapshot.data.reservations.indexWhere((element) => element.userId == auth.user.uid)]);
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.data);
          } else {
            return _buildLoadingWidget();
          }
        },
      );
  Widget _buildExample() => Row(
        children: [
          SizedBox(width: 20),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 20 - ((projection.salle.rowLength - 1) * 4)) / projection.salle.rowLength,
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(margin: EdgeInsets.zero, color: Colors.white),
            ),
          ),
          Text(" Réservé", style: Theme.of(context).textTheme.caption),
          Spacer(),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 20 - ((projection.salle.rowLength - 1) * 4)) / projection.salle.rowLength,
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(margin: EdgeInsets.zero, color: Style.Colors.secondaryColor),
            ),
          ),
          Text(" Séléctionné", style: Theme.of(context).textTheme.caption),
          Spacer(),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 20 - ((projection.salle.rowLength - 1) * 4)) / projection.salle.rowLength,
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(margin: EdgeInsets.zero, color: Style.Colors.titleColor),
            ),
          ),
          Text(" Vide", style: Theme.of(context).textTheme.caption),
          SizedBox(width: 20),
        ],
      );

  Widget _buildSeats(List<Reservation> reservations) {
    return Container(
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(20),
        itemCount: projection.salle.capacity,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: projection.salle.rowLength,
          childAspectRatio: 1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if (_selectedSeats.isEmpty) _hideFabAnimController.forward();
              if (reservations.indexWhere((reservation) => reservation.placesIds.contains(_seats[index])) == -1) {
                if (_selectedSeats.length == _numberOfSeats) _selectedSeats.removeAt(0);
                setState(() {
                  _selectedSeats.add(_seats[index]);
                });
              }
              setState(() {});
            },
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: reservations.indexWhere((reservation) => reservation.placesIds.contains(_seats[index])) != -1
                  ? Colors.white
                  : _selectedSeats.contains(_seats[index])
                      ? Style.Colors.secondaryColor
                      : Style.Colors.titleColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrScreenBuilder(Reservation reservation) {
    return ListView(
      padding: EdgeInsets.all(20),
      physics: BouncingScrollPhysics(),
      children: [
        Text(
          projection.movie.title,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline5.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          "Le " +
              DateFormat('EEEEEE, DD MMM ', 'fr-FR').format(projection.date) +
              "à " +
              DateFormat('HH:mm ').format(projection.date) +
              (DateTime.now().isAfter(
                projection.date.add(
                  Duration(minutes: projection.movie.runtime),
                ),
              )
                  ? "(Déjà joué) "
                  : "") +
              (DateTime.now().isBefore(
                        projection.date.add(
                          Duration(minutes: projection.movie.runtime),
                        ),
                      ) &&
                      DateTime.now().isAfter(projection.date)
                  ? "(En train de jouer) "
                  : "") +
              "\n" +
              projection.salle.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Style.Colors.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: QrImage(
                data: reservation.id,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("Merci de contacter la réception de Murdjaju oubien sur le numero  +213779299089 pour l'annulation ou la modification de votre réservation."),
          ),
        ),
      ],
    );
  }

  Widget _buildReservationScreenBuilder(ReservationsResponse data) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        _buildSeatsCounter(),
        _buildSeats(data.reservations),
        _buildExample(),
        Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: () async {
                if (_selectedSeats.isEmpty) {
                  SnackBar sb = SnackBar(
                    margin: EdgeInsets.all(10),
                    duration: Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Style.Colors.mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    content: Text("Vueillez selectionner au moins une chaise.", style: TextStyle(color: Colors.white)),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(sb);
                } else {
                  await showDialog(
                    context: context,
                    barrierColor: Style.Colors.secondaryColor.withOpacity(.25),
                    builder: (_) => SimpleDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Style.Colors.mainColor,
                      contentPadding: EdgeInsets.all(20),
                      titlePadding: EdgeInsets.all(10),
                      title: Text(
                        "Valider votre réservation?",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      children: [
                        _buildText("Film", projection.movie.title),
                        _buildText("Date", DateFormat('EEEEEE, DD MMM ', 'fr-FR').format(projection.date)),
                        _buildText("Heur", DateFormat('HH:mm ', 'fr-FR').format(projection.date)),
                        _buildText("Salle", projection.salle.name),
                        _buildText("Places", _selectedSeats.toString()),
                        _buildText("Prix:", "${projection.prixTicket}*${_selectedSeats.length} = ${projection.prixTicket * _selectedSeats.length}Da"),
                        Row(
                          children: [
                            Spacer(),
                            MaterialButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              color: Style.Colors.secondaryColor,
                              textColor: Style.Colors.mainColor,
                              child: Text("Valider"),
                              onPressed: () async {
                                final GlobalKey<State> key = new GlobalKey<State>();
                                final loader = Loader();
                                Navigator.pop(context);
                                await loader.showLoadingDialog(context, key);

                                await FirebaseFirestore.instance.collection('Reservations').add(
                                  {
                                    "projectionId": projection.id,
                                    "confirmed": true,
                                    "userId": auth.user.uid,
                                    "date": DateTime.now(),
                                    "placesIds": _selectedSeats,
                                    "movieTitle": projection.movie.title,
                                    "salleName": projection.salle.name,
                                    "projectionDate": projection.date,
                                  },
                                );
                                await reservationsListBloc.getReservations(projection.id);
                                loader.removeLoadingDialog(context, key);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
              label: Text("Réserver"),
              icon: Icon(CupertinoIcons.ticket_fill),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        // SizedBox(height: 100),
      ],
    );
  }

  Widget _buildText(String title, String str) => RichText(
        text: TextSpan(
          text: title + ": ",
          style: Theme.of(context).textTheme.subtitle1.copyWith(color: Style.Colors.secondaryColor, fontWeight: FontWeight.w700),
          children: <TextSpan>[
            TextSpan(text: str, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      );

  Widget _buildSeatsCounter() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          Text("Nombre de chaises:"),
          SizedBox(width: 20),
          DropdownButton(
            value: _numberOfSeats,
            onChanged: (value) {
              if (value < _selectedSeats.length) _selectedSeats = _selectedSeats.sublist(0, value);
              setState(() {
                _numberOfSeats = value;
              });
            },
            items: [
              DropdownMenuItem(child: Text(" 1 "), value: 1),
              DropdownMenuItem(child: Text(" 2 "), value: 2),
              DropdownMenuItem(child: Text(" 3 "), value: 3),
              DropdownMenuItem(child: Text(" 4 "), value: 4),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: () {
              _numberOfSeats = 1;
              _selectedSeats.clear();
              setState(() {});
              _hideFabAnimController.reverse();
            },
            child: Center(child: Text("Vider", style: Theme.of(context).textTheme.caption)),
          ),
          SizedBox(width: 20),
        ],
      );

  Widget _buildErrorWidget(ReservationsResponse error) {
    if (error.error == "Loading...") return _buildLoadingWidget();
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
    Widget loader = new Loader().loader;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [loader],
      ),
    );
  }
}
