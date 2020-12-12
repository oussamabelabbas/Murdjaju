import 'package:murdjaju/screens/authentification_screen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class WelcomeScreen extends StatefulWidget {
  static final String path = "lib/src/pages/onboarding/intro6.dart";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  SwiperController _controller = SwiperController();
  int _currentIndex = 0;
  final List<String> titles = [
    "Welcome",
    "Awesome App",
    "Flutter App",
  ];
  final List<String> subtitles = [
    "Welcome to this awesome intro screen app.",
    "This is an awesome app, of intro screen design",
    "Flutter is awesome for app development"
  ];
  final List<Color> colors = [
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];
  final List<String> images = [
    "https://image.tmdb.org/t/p/original/oVQkW4kJ7P9HZZzMEHWGGRlv5hO.jpg",
    "https://image.tmdb.org/t/p/original/mS2FYxJU0BhInfgw2By1VCe069o.jpg",
    "https://image.tmdb.org/t/p/original/zrJXfi9O3GpSkA8vZ7lGYKUItrt.jpg",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,

      /* bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.transparent,
          height: AppBar().preferredSize.height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FlatButton(
                  child: Text("Skip"),
                  textColor: Colors.orange,
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) {
                          return AuthentificationScreen();
                        },
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                      _currentIndex == 2 ? Icons.check : Icons.arrow_forward,
                      color: Colors.orange),
                  onPressed: () {
                    if (_currentIndex != 2) {
                      _controller.next();
                    } else
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) {
                            return AuthentificationScreen();
                          },
                        ),
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      ), */
      body: DoubleBackToCloseApp(
        child: Stack(
          children: <Widget>[
            Swiper(
              loop: false,
              index: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              controller: _controller,
              pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  activeColor: Colors.red,
                  activeSize: 20.0,
                ),
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return IntroItem(
                  title: titles[index],
                  subtitle: subtitles[index],
                  bg: colors[index],
                  imageUrl: images[index],
                );
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FlatButton(
                child: Text("Skip"),
                textColor: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) {
                        return AuthentificationScreen();
                      },
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(
                    _currentIndex == 2 ? Icons.check : Icons.arrow_forward,
                    color: Colors.orange),
                onPressed: () {
                  if (_currentIndex != 2) {
                    _controller.next();
                  } else
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) {
                          return AuthentificationScreen();
                        },
                      ),
                    );
                },
              ),
            ),
          ],
        ),
        snackBar: SnackBar(
          content: Text('Tap back again to leave'),
          backgroundColor: Style.Colors.titleColor,
        ),
      ),
    );
  }
}

class IntroItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bg;
  final String imageUrl;

  const IntroItem(
      {Key key, @required this.title, this.subtitle, this.bg, this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Style.Colors.mainColor,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: <Widget>[
            /* const SizedBox(height: 40),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35.0,
                  color: Colors.white),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 20.0),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white, fontSize: 24.0),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 40.0), */
            Expanded(
              child: Container(
                //margin: const EdgeInsets.only(bottom: 70),
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Material(
                    color: Style.Colors.mainColor,
                    elevation: 0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : Center(
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      backgroundColor: Style.Colors.mainColor,
                                      valueColor: AlwaysStoppedAnimation(
                                          Style.Colors.secondaryColor),
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
