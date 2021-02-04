import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/bloc/get_user_reservations_bloc.dart';
import 'package:murdjaju/model/reservation.dart';
import 'package:murdjaju/model/reservations_response.dart';
import 'package:murdjaju/providers/auth.dart';
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationsScreen extends StatefulWidget {
  ReservationsScreen({Key key}) : super(key: key);

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  UserAuth auth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = Provider.of<UserAuth>(context, listen: false);
    reservationsListBloc.getReservations(null, auth.user.uid);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    reservationsListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
          margin: EdgeInsets.all(5),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Style.Colors.mainColor,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Mes réservations:",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Style.Colors.secondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: reservationsListBloc.subject.stream,
                  builder: (context, AsyncSnapshot<ReservationsResponse> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.error != null && snapshot.data.error.length > 0) {
                        return _buildErrorWidget(snapshot.data.error);
                      }

                      return _buildReservationsWidget(snapshot.data.reservations);
                    } else if (snapshot.hasError) {
                      return _buildErrorWidget(snapshot.data.error);
                    } else {
                      return _buildLoadingWidget();
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildReservationsWidget(List<Reservation> reservations) {
    reservations.sort((a, b) => a.projectionDate.compareTo(b.projectionDate));
    if (reservations.isEmpty)
      return Center(
        child: Text("Vous n'avez aucune réservation"),
      );
    return ListView.separated(
      padding: EdgeInsets.all(10),
      itemCount: reservations.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) => AspectRatio(
        aspectRatio: 7,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => AlertDialog(
                backgroundColor: Style.Colors.mainColor,
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: AspectRatio(
                  aspectRatio: 1,
                  child: _buildQrScreenBuilder(reservations[index]),
                ),
              ),
            );
          },
          child: Card(
            color: reservations[index].expired ? Colors.red : Style.Colors.titleColor,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.qr_code_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservations[index].movieTitle,
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('EEE d MMM y à HH:mm', 'fr-FR').format(reservations[index].projectionDate),
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrScreenBuilder(Reservation reservation) {
    return ListView(
      padding: EdgeInsets.all(20),
      physics: BouncingScrollPhysics(),
      children: [
        Text(
          reservation.movieTitle,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline5.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          "Le " + DateFormat('EEEEEE, d MMM ', 'fr-FR').format(reservation.projectionDate) + "à " + DateFormat('HH:mm ').format(reservation.projectionDate),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  QrImage(
                    data: reservation.id,
                    foregroundColor: Colors.white,
                  ),
                  if (reservation.expired)
                    Container(
                      color: Colors.red,
                      height: 100,
                      width: double.infinity,
                      child: Center(
                        child: Text("Réservation éxpiré"),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildText("Places", reservation.placesIds.toString()),
              _buildText("Prix Totale", (reservation.placesIds.length * reservation.placePrice).toString() + "Da"),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Text("Merci de contacter la réception de Murdjaju oubien sur le numero +213779299089 pour l'annulation ou la modification de votre réservation."),
        ),
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

  Widget _buildErrorWidget(String error) {
    if (error == "Loading...") return _buildLoadingWidget();
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
            error,
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
