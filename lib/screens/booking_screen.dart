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
      value: 1, // initially visible
    );
    _seats = List.generate(
      projection.salle.capacity,
      (index) => alphabet[index ~/ projection.salle.rowLength] + (index % projection.salle.rowLength + 1).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FadeTransition(
        opacity: _hideFabAnimController,
        child: SlideTransition(
          position: Tween<Offset>(
            end: const Offset(0.0, 0.0),
            begin: Offset(MediaQuery.of(context).size.width / 2, 0.0),
          ).animate(CurvedAnimation(
            parent: _hideFabAnimController,
            curve: Curves.easeInCubic,
          )),
          child: FloatingActionButton.extended(
            onPressed: () async {},
            label: Text("Réserver"),
            icon: Icon(CupertinoIcons.ticket_fill),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
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
      physics: BouncingScrollPhysics(),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            child: Center(),
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
        SizedBox(height: 100),
      ],
    );
  }

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
//     return AbsorbPointer(
//       absorbing: _loading,
//       child: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection("Reservations").where("ProjectionId", isEqualTo: projection.id).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.data == null)
//             return Container(
//               color: Style.Colors.mainColor,
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: Center(
//                 child: CircularProgressIndicator(
//                   backgroundColor: Colors.transparent,
//                   valueColor: AlwaysStoppedAnimation(Style.Colors.secondaryColor),
//                 ),
//               ),
//             );
//           _loading = true;

//           ReservationsResponse reservationsResponse = ReservationsResponse.fromSnapshots(snapshot.data.documents);
//           Future.forEach<Reservation>(
//             reservationsResponse.reservations,
//             (reservation) async {
//               if (!reservation.confirmed && DateTime.now().difference(reservation.date).inHours > 1) await reservation.reference.delete();
//             },
//           );
//           _selectedSeats.removeWhere((_seat) => reservationsResponse.reservations.indexWhere((reservation) => reservation.placesIds.contains(_seat)) != -1);
//           _loading = false;

//           return Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: Style.Colors.mainColor,
//             floatingActionButton: _selectedSeats.isEmpty
//                 ? null
//                 : FadeTransition(
//                     opacity: _hideFabAnimController,
//                     child: ScaleTransition(
//                       scale: _hideFabAnimController,
//                       child: FloatingActionButton.extended(
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                         onPressed: () async {
//                           setState(() {
//                             _loading = true;
//                           });
//                           await Future.delayed(Duration(seconds: 2));
//                           await FirebaseFirestore.instance.collection("Reservations").add(
//                             {
//                               "Date": DateTime.now(),
//                               "PlacesIds": _selectedSeats,
//                               "UserId": FirebaseAuth.instance.currentUser.uid,
//                               "UserName": FirebaseAuth.instance.currentUser.displayName,
//                               "UserPhoneNumber": FirebaseAuth.instance.currentUser.phoneNumber,
//                               "ProjectionId": projection.id,
//                               "Confirmed": false,
//                               "Arrived": false,
//                             },
//                           );
//                           setState(() {
//                             _loading = false;
//                           });
//                         },
//                         label: Text("Réserver"),
//                       ),
//                     ),
//                   ),
//             body: Stack(
//               children: [
//                 Builder(
//                   builder: (context) {
//                     User user = FirebaseAuth.instance.currentUser;
//                     if (reservationsResponse.reservations.indexWhere((element) => element.userId == user.uid) != -1) {
//                       Reservation reservation = reservationsResponse.reservations.firstWhere((element) => element.userId == user.uid);

//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Spacer(),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 10),
//                               child: Column(
//                                 children: [
//                                   Text("Vous avez reservé pour cette projection..."),
//                                   Text("Places Réservées: " + reservation.placesIds.toString()),
//                                 ],
//                               ),
//                             ),
//                             Spacer(),
//                             AspectRatio(
//                               aspectRatio: 1,
//                               child: Container(
//                                 decoration: BoxDecoration(),
//                                 margin: EdgeInsets.all(25),
//                                 child: QrImage(
//                                   data: reservation.id,
//                                   version: QrVersions.auto,
//                                   backgroundColor: Colors.white,
//                                   padding: EdgeInsets.all(10),
//                                 ),
//                               ),
//                             ),
//                             Spacer(),
//                             if (!reservation.confirmed)
//                               StreamBuilder(
//                                 stream: Stream.periodic(Duration(seconds: 20)),
//                                 builder: (context, snapshot) => Padding(
//                                   padding: EdgeInsets.symmetric(horizontal: 10),
//                                   child: Text(
//                                     "Votre projection n\a pas encore etais confirmé...\nLa reservation serra supprimé automatiquement dans ${DateTime.now().difference(reservation.date.add(Duration(hours: 1))).inMinutes} Minutes.",
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             Spacer(),
//                             if (!reservation.confirmed)
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   TextButton.icon(
//                                     style: ButtonStyle(
//                                       foregroundColor: MaterialStateProperty.resolveWith(
//                                         (Set<MaterialState> states) {
//                                           const Set<MaterialState> interactiveStates = <MaterialState>{
//                                             MaterialState.pressed,
//                                             MaterialState.hovered,
//                                             MaterialState.focused,
//                                           };
//                                           if (states.any(interactiveStates.contains)) {
//                                             return Colors.white;
//                                           }
//                                           return Colors.red;
//                                         },
//                                       ),
//                                       overlayColor: MaterialStateProperty.resolveWith(
//                                         (Set<MaterialState> states) {
//                                           const Set<MaterialState> interactiveStates = <MaterialState>{
//                                             MaterialState.pressed,
//                                             MaterialState.hovered,
//                                             MaterialState.focused,
//                                           };
//                                           if (states.any(interactiveStates.contains)) {
//                                             return Colors.red;
//                                           }
//                                           return Colors.red;
//                                         },
//                                       ),
//                                     ),
//                                     label: Text("Annuler"),
//                                     icon: Icon(MdiIcons.cancel),
//                                     onPressed: () async {
//                                       setState(() {
//                                         _loading = !_loading;
//                                       });
//                                       print(_loading.toString());
//                                       await reservation.reference.delete();
//                                       setState(() {
//                                         _loading = false;
//                                       });
//                                       Navigator.pop(context);
//                                     },
//                                   ),
//                                   TextButton.icon(
//                                     style: ButtonStyle(
//                                       foregroundColor: MaterialStateProperty.resolveWith(
//                                         (Set<MaterialState> states) {
//                                           const Set<MaterialState> interactiveStates = <MaterialState>{
//                                             MaterialState.pressed,
//                                             MaterialState.hovered,
//                                             MaterialState.focused,
//                                           };
//                                           if (states.any(interactiveStates.contains)) {
//                                             return Style.Colors.mainColor;
//                                           }
//                                           return Style.Colors.secondaryColor;
//                                         },
//                                       ),
//                                       overlayColor: MaterialStateProperty.resolveWith(
//                                         (Set<MaterialState> states) {
//                                           const Set<MaterialState> interactiveStates = <MaterialState>{
//                                             MaterialState.pressed,
//                                             MaterialState.hovered,
//                                             MaterialState.focused,
//                                           };
//                                           if (states.any(interactiveStates.contains)) {
//                                             return Style.Colors.secondaryColor;
//                                           }
//                                           return Style.Colors.secondaryColor;
//                                         },
//                                       ),
//                                     ),
//                                     label: Text("Valider"),
//                                     icon: Icon(MdiIcons.ticketConfirmation),
//                                     onPressed: () async {
//                                       final auth = Provider.of<UserAuth>(context, listen: false);
//                                       if (auth.user.phoneNumber == null) {
//                                         SnackBar _sb = SnackBar(
//                                           backgroundColor: Style.Colors.titleColor,
//                                           content: Text("Votre numéro de téléphone n'as pas encore était validé. Voulez vous le "),
//                                           action: SnackBarAction(
//                                             textColor: Style.Colors.secondaryColor,
//                                             label: "Valider?",
//                                             onPressed: () async {
//                                               setState(() {
//                                                 _loading = true;
//                                               });

//                                               await FirebaseAuth.instance.verifyPhoneNumber(
//                                                 phoneNumber: auth.phoneNumber,
//                                                 timeout: Duration(seconds: 120),
//                                                 verificationCompleted: (credential) async {
//                                                   setState(() {
//                                                     _loading = false;
//                                                   });
//                                                 },
//                                                 verificationFailed: (FirebaseAuthException exception) {
//                                                   print(exception);
//                                                   setState(() {
//                                                     _loading = false;
//                                                   });
//                                                 },
//                                                 codeSent: (String verificationId, [int forceResendingToken]) {
//                                                   setState(() {
//                                                     _loading = false;
//                                                   });
//                                                   showDialog(
//                                                     //backgroundColor: Colors.transparent,
//                                                     context: context,
//                                                     builder: (context) {
//                                                       return StatefulBuilder(
//                                                         builder: (BuildContext context, StateSetter myState) {
//                                                           return AlertDialog(
//                                                             title: Text("Entrer votre code:"),
//                                                             backgroundColor: Style.Colors.titleColor,
//                                                             clipBehavior: Clip.antiAlias,
//                                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//                                                             contentPadding: EdgeInsets.zero,
//                                                             actions: [
//                                                               RaisedButton(
//                                                                 color: Style.Colors.secondaryColor,
//                                                                 textColor: Colors.black,
//                                                                 elevation: 0,
//                                                                 shape: RoundedRectangleBorder(
//                                                                   borderRadius: BorderRadius.circular(5.0),
//                                                                 ),
//                                                                 child: Text("Confirmer"),
//                                                                 onPressed: () async {
//                                                                   myState(() {
//                                                                     _loading = true;
//                                                                   });
//                                                                   Navigator.pop(context);
//                                                                   final code = _codeController.text.trim();
//                                                                   AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
//                                                                   await auth.verifyPhoneNumber(credential);
//                                                                   Navigator.pop(context);
//                                                                   myState(() {
//                                                                     _loading = false;
//                                                                   });
//                                                                 },
//                                                               ),
//                                                             ],
//                                                             content: Container(
//                                                               width: MediaQuery.of(context).size.width * .75,
//                                                               height: MediaQuery.of(context).size.width * .5,
//                                                               padding: EdgeInsets.all(35),
//                                                               decoration: BoxDecoration(
//                                                                 color: Style.Colors.titleColor,
//                                                                 borderRadius: BorderRadius.circular(35),
//                                                               ),
//                                                               child: Column(
//                                                                 children: [
//                                                                   Spacer(),
//                                                                   TextField(
//                                                                     controller: _codeController,
//                                                                     textAlign: TextAlign.center,
//                                                                     keyboardType: TextInputType.number,
//                                                                     decoration: InputDecoration(
//                                                                       labelText: 'Code',
//                                                                       labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.black),
//                                                                       border: OutlineInputBorder(
//                                                                         borderRadius: BorderRadius.circular(16),
//                                                                         borderSide: BorderSide(color: Style.Colors.secondaryColor),
//                                                                       ),
//                                                                       focusedBorder: OutlineInputBorder(
//                                                                         borderRadius: BorderRadius.circular(16),
//                                                                         borderSide: BorderSide(color: Style.Colors.secondaryColor),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   Spacer(),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           );
//                                                         },
//                                                       );
//                                                     },
//                                                   );
//                                                 },
//                                                 codeAutoRetrievalTimeout: (str) {},
//                                               );
//                                             },
//                                           ),
//                                         );
//                                         ScaffoldMessenger.of(context).showSnackBar(_sb);
//                                         print("Is Empty");
//                                       } else {
//                                         setState(() {
//                                           _loading = true;
//                                         });
//                                         await Future.delayed(Duration(seconds: 2));
//                                         await reservation.reference.update({"Confirmed": true});
//                                         setState(() {
//                                           _loading = false;
//                                         });
//                                       }
//                                       //  Navigator.pop(context);
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             Spacer(),
//                           ],
//                         ),
//                       );
//                     }
//                     return Container(
//                       height: MediaQuery.of(context).size.height,
//                       width: MediaQuery.of(context).size.width,
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               child: Stack(
//                                 alignment: Alignment.bottomCenter,
//                                 children: [
//                                   Image.network(
//                                     projection.movie.isShow ? projection.movie.backPoster : 'https://image.tmdb.org/t/p/w780/' + projection.movie.backPoster,
//                                     fit: BoxFit.cover,
//                                   ),
//                                   Container(
//                                     height: MediaQuery.of(context).size.width * 439 / 780,
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [Style.Colors.mainColor, Colors.transparent, Style.Colors.mainColor],
//                                         begin: Alignment.topCenter,
//                                         end: Alignment.bottomCenter,
//                                       ),
//                                     ),
//                                   ),
//                                   Hero(
//                                     tag: projection.id.toString() + projection.date.toString() + widget.heroId.toString(),
//                                     child: Text(
//                                       DateTime.now().day == projection.date.day ? "Aujourd'hui à ${DateFormat('HH:mm ').format(projection.date)} " : DateFormat('EEEEEE d MMM à HH:mm', 'fr-FR').format(projection.date).capitalize(),
//                                       textAlign: TextAlign.center,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: Theme.of(context).textTheme.headline6.copyWith(color: Style.Colors.secondaryColor),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               width: MediaQuery.of(context).size.width * .85,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   IconButton(
//                                     icon: Icon(MdiIcons.minusCircle),
//                                     splashRadius: 15,
//                                     onPressed: () {
//                                       if (_numberOfSeats != 1) {
//                                         if (_selectedSeats.length == _numberOfSeats) {
//                                           _selectedSeats.removeLast();
//                                           _numberOfSeats--;
//                                         } else
//                                           _numberOfSeats--;
//                                         setState(() {});
//                                       }
//                                     },
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 5),
//                                     child: Text(_numberOfSeats.toString(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)),
//                                   ),
//                                   IconButton(
//                                     icon: Icon(MdiIcons.plusCircle),
//                                     splashRadius: 15,
//                                     onPressed: () {
//                                       if (_numberOfSeats < 3) {
//                                         _numberOfSeats++;
//                                         setState(() {});
//                                       }
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               width: MediaQuery.of(context).size.width * .85,
//                               child: GridView.builder(
//                                 physics: NeverScrollableScrollPhysics(),
//                                 shrinkWrap: true,
//                                 padding: EdgeInsets.all(10),
//                                 itemCount: projection.salle.capacity,
//                                 gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: projection.salle.rowLength,
//                                   childAspectRatio: 1,
//                                   mainAxisSpacing: 2,
//                                   crossAxisSpacing: 2,
//                                 ),
//                                 itemBuilder: (BuildContext context, int index) {
//                                   return InkWell(
//                                     onTap: () {
//                                       if (reservationsResponse.reservations.indexWhere((reservation) => reservation.placesIds.contains(_seats[index])) == -1) {
//                                         if (_selectedSeats.length == _numberOfSeats) _selectedSeats.removeAt(0);
//                                         setState(() {
//                                           _selectedSeats.add(_seats[index]);
//                                         });
//                                       }
//                                       setState(() {});
//                                     },
//                                     child: Container(
//                                       /*  child: Center(
//                                     child: Text(_seats[index]),
//                                   ), */
//                                       decoration: BoxDecoration(
//                                         color: reservationsResponse.reservations.indexWhere((reservation) => reservation.placesIds.contains(_seats[index])) != -1
//                                             ? Colors.white
//                                             : _selectedSeats.contains(_seats[index])
//                                                 ? Style.Colors.secondaryColor
//                                                 : Style.Colors.titleColor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             Container(
//                               width: MediaQuery.of(context).size.width * .85,
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: (MediaQuery.of(context).size.width * .85) / projection.salle.rowLength / 2,
//                                     height: (MediaQuery.of(context).size.width * .85) / projection.salle.rowLength / 2,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       shape: BoxShape.circle,
//                                       /* borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(10),
//                         ), */
//                                     ),
//                                   ),
//                                   Text(
//                                     " Réservé",
//                                     style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
//                                   ),
//                                   Spacer(),
//                                   Container(
//                                     width: (MediaQuery.of(context).size.width * .85) / projection.salle.rowLength / 2,
//                                     height: (MediaQuery.of(context).size.width * .85) / projection.salle.rowLength / 2,
//                                     decoration: BoxDecoration(
//                                       color: Style.Colors.secondaryColor,
//                                       shape: BoxShape.circle,
//                                       /* borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(10),
//                         ), */
//                                     ),
//                                   ),
//                                   Text(
//                                     " Ma place",
//                                     style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
//                                   ),
//                                   Spacer(),
//                                   Container(
//                                     width: (MediaQuery.of(context).size.width * .85) / projection.salle.rowLength / 2,
//                                     height: (MediaQuery.of(context).size.width * .85) / projection.salle.rowLength / 2,
//                                     decoration: BoxDecoration(
//                                       color: Style.Colors.titleColor,
//                                       shape: BoxShape.circle,
//                                       /* borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(10),
//                         ), */
//                                     ),
//                                   ),
//                                   Text(
//                                     " Vide",
//                                     style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 _loading
//                     ? Container(
//                         color: Style.Colors.secondaryColor.withOpacity(.2),
//                         height: MediaQuery.of(context).size.height,
//                         width: MediaQuery.of(context).size.width,
//                         child: Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       )
//                     : SizedBox(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
