import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/bloc/current_week_bloc.dart';
import 'package:murdjaju/bloc/get_user_reservations_bloc.dart';
import 'package:murdjaju/model/reservation.dart';
import 'package:murdjaju/model/reservations_response.dart';
import 'package:murdjaju/providers/auth.dart';
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:murdjaju/screens/reservations_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../style/theme.dart' as Style;

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserAuth auth;
  bool _enableEditing = false;

  TextEditingController _mailAdressFieldTextController = TextEditingController();
  FocusNode _mailAdressFocusNode = FocusNode();
  TextEditingController _nameFieldTextController = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  TextEditingController _phoneNumberFieldTextController = TextEditingController();
  FocusNode _phoneNumberFocusNode = FocusNode();

  String _nameValide;
  String _emailValide;
  String _phoneNumberValide;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = Provider.of<UserAuth>(context, listen: false);
    _nameFieldTextController.addListener(() {
      _verifyName();
    });
    _mailAdressFieldTextController.addListener(() {
      _verifyEmail();
    });
    _phoneNumberFieldTextController.addListener(() {
      _verifyPhoneNumber();
    });
    resetFields();
  }

  void resetFields() {
    _nameFieldTextController.text = auth.user.displayName;
    _mailAdressFieldTextController.text = auth.user.email;
    _phoneNumberFieldTextController.text = auth.phoneNumber.substring(auth.phoneNumber.length - 9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.logout),
        label: Text("Déconnexion"),
        onPressed: () {
          SnackBar sb = SnackBar(
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Style.Colors.mainColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Text("Voulez vous déconnecter?", style: TextStyle(color: Colors.white)),
            action: SnackBarAction(
              label: "Déconnecter.",
              disabledTextColor: Colors.white,
              textColor: Style.Colors.secondaryColor,
              onPressed: () async {
                setState(() => _enableEditing = false);
                final auth = Provider.of<UserAuth>(context, listen: false);
                final loader = Loader();
                final GlobalKey<State> key = new GlobalKey<State>();
                loader.showLoadingDialog(context, key);
                await auth.logout();
                // Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => MyApp()));
                Navigator.pop(context);
                loader.removeLoadingDialog(context, key);
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(sb);
        },
      ),
      body: ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://image.tmdb.org/t/p/w780/' + currentWeekBloc.subject.value.projections.first.movie.poster),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Style.Colors.mainColor.withOpacity(.4),
                child: Column(
                  children: <Widget>[
                    AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      actions: _enableEditing
                          ? [
                              IconButton(
                                icon: Icon(Icons.save, color: Colors.green),
                                onPressed: () async {
                                  _verifyPhoneNumber();
                                  _verifyName();
                                  if (_nameValide == null && _phoneNumberValide == null) {
                                    final auth = Provider.of<UserAuth>(context, listen: false);
                                    final loader = Loader();
                                    final GlobalKey<State> key = new GlobalKey<State>();
                                    loader.showLoadingDialog(context, key);
                                    await auth.updateUser(_nameFieldTextController.text, _phoneNumberFieldTextController.text);
                                    loader.removeLoadingDialog(context, key);
                                    setState(() => _enableEditing = false);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  resetFields();
                                  setState(() => _enableEditing = false);
                                },
                              ),
                            ]
                          : [
                              IconButton(
                                icon: Icon(Icons.edit, color: Style.Colors.secondaryColor),
                                onPressed: () {
                                  setState(() => _enableEditing = true);
                                },
                              ),
                            ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            readOnly: !_enableEditing,
                            maxLines: 1,
                            focusNode: _nameFocusNode,
                            controller: _nameFieldTextController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.name,
                            decoration: new InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              helperText: "",
                              errorText: _nameValide,
                              labelText: 'Nom complet:',
                              labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Style.Colors.secondaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Style.Colors.secondaryColor),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              prefixIcon: new Icon(
                                Icons.person,
                                color: _nameFieldTextController.text != ''
                                    ? _nameValide != null
                                        ? Colors.red
                                        : Style.Colors.secondaryColor
                                    : Style.Colors.secondaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            readOnly: true,
                            textAlign: TextAlign.center,
                            focusNode: _mailAdressFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            controller: _mailAdressFieldTextController,
                            decoration: InputDecoration(
                              helperText: "",
                              errorText: _emailValide,
                              labelText: 'Adresse mail:',
                              labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Style.Colors.secondaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Style.Colors.secondaryColor),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              prefixIcon: new Icon(
                                Icons.mail,
                                color: _mailAdressFieldTextController.text != ''
                                    ? _emailValide != null
                                        ? Colors.red
                                        : Style.Colors.secondaryColor
                                    : Style.Colors.secondaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            readOnly: !_enableEditing,
                            focusNode: _phoneNumberFocusNode,
                            controller: _phoneNumberFieldTextController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              helperText: "",
                              prefixText: "+213",
                              labelText: 'Phone Number',
                              errorText: _phoneNumberValide,
                              prefixStyle: TextStyle(color: Style.Colors.secondaryColor),
                              labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Style.Colors.secondaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Style.Colors.secondaryColor),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              prefixIcon: new Icon(
                                Icons.phone,
                                color: _phoneNumberFieldTextController.text != ''
                                    ? _phoneNumberValide != null
                                        ? Colors.red
                                        : Style.Colors.secondaryColor
                                    : Style.Colors.secondaryColor,
                              ),
                            ),
                          ),
                          //_buildReservationsList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationsList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Mes réservations:"),
          StreamBuilder(
            stream: reservationsListBloc.subject.stream,
            builder: (context, AsyncSnapshot<ReservationsResponse> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.error != null && snapshot.data.error.length > 0) {
                  return _buildErrorWidget(snapshot.data);
                }
                return _buildWeekBuilder(snapshot.data);
              } else if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.data);
              } else {
                return _buildLoadingWidget();
              }
            },
          ),
        ],
      );
  Widget _title(String _str) => Padding(
        padding: EdgeInsets.only(left: 0),
        child: Row(
          children: [
            Text(
              _str,
              style: Theme.of(context).textTheme.headline6.copyWith(color: Style.Colors.secondaryColor),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => ReservationsScreen()));
              },
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Text(
                    "Voir tout.",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildWeekBuilder(ReservationsResponse data) {
    List<Reservation> reservations = data.reservations;

    return Container(
      height: 120,
      child: ListView.separated(
        itemCount: reservations.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(10),
        separatorBuilder: (context, index) => SizedBox(width: 20),
        itemBuilder: (context, index) => AspectRatio(
          aspectRatio: 1,
          child: InkWell(
            onTap: () {},
            child: Card(
              color: Style.Colors.titleColor.withOpacity(.65),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: "QR" + reservations[index].id,
                    child: QrImage(
                      data: reservations[index].id,
                      version: QrVersions.auto,
                      backgroundColor: Style.Colors.titleColor,
                      foregroundColor: Style.Colors.mainColor,
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(reservations[index].salleName),
                      Text(reservations[index].movieTitle),
                      Text(DateFormat('E d/MM.', 'fr-FR').format(reservations[index].date)),
                      Text(DateFormat('HH:mm', 'fr-FR').format(reservations[index].date)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  void _verifyPhoneNumber() {
    if (_phoneNumberFieldTextController.text == null || _phoneNumberFieldTextController.text == '')
      setState(() {
        _phoneNumberValide = 'Numéro téléphone vide !';
      });
    else if (!validatePhoneNumber(_phoneNumberFieldTextController.text))
      setState(() {
        _phoneNumberValide = 'Le numéro téléphone doit être valide.';
      });
    else
      setState(() {
        _phoneNumberValide = null;
      });
  }

  bool validatePhoneNumber(String value) {
    String pattern = r"^(\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{3}$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  void _verifyName() {
    if (_nameFieldTextController.text == null || _nameFieldTextController.text == '')
      setState(() {
        _nameValide = 'Le nom est vide !';
      });
    else if (!validateName(_nameFieldTextController.text))
      setState(() {
        _nameValide = 'Veillez entrer votre nom complet, svp.';
      });
    else
      setState(() {
        _nameValide = null;
      });
  }

  bool validateName(String value) {
    String pattern = r"^([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  void _verifyEmail() {
    if (_mailAdressFieldTextController.text == null || _mailAdressFieldTextController.text == '')
      setState(() {
        _emailValide = 'L\adresse mail est vide.';
      });
    else if (!validateEmail(_mailAdressFieldTextController.text))
      setState(() {
        _emailValide = 'L\'adresse mail doit être valide.';
      });
    else
      setState(() {
        _emailValide = null;
      });
  }

  bool validateEmail(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }
}
