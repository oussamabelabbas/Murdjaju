import 'dart:async';
import 'dart:ui';

import 'package:async/async.dart';
import 'authentication/auth.dart';
import 'myMain/movie.dart';
import 'myMain/movieHome.dart';
import 'myMain/palette.dart';
import 'screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'style/theme.dart' as Style;

import 'screens/fillData_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  SystemUiOverlayStyle mySystemTheme = SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Style.Colors.mainColor);
  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ChangeNotifierProvider<UserAuth>(
      create: (_) => UserAuth(
        FirebaseAuth.instance.currentUser,
        FirebaseAuth.instance.currentUser != null,
        FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.displayName != null,
      ),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Palette.white,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.montserrat().fontFamily,
        accentColor: Style.Colors.secondaryColor,
        splashColor: Style.Colors.secondaryColor,
        iconTheme: IconThemeData(
          color: Colors.white,
          opacity: .85,
        ),
      ),
      home: Consumer<UserAuth>(
        builder: (_, auth, __) {
          if (!auth.loggedIn) return WelcomeScreen();
          if (!auth.haveData) return FillDataScreen();
          return HomeScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  double get _screenHeight => MediaQuery.of(context).size.height;
  double get _screenWidth => MediaQuery.of(context).size.width;

  List<int> _movies = [
    539885,
    157336,
    372058,
    496243,
    400160,
    527641,
    508965,
    490132,
    475557,
    671039,
    724989,
    531219,
    741067,
    741074,
    340102,
    528085,
    613504,
    497582,
    624779,
    560050,
    337401,
    694919,
  ];

  TabController _tabController;

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  SwiperController _swiperController = SwiperController();
  SwiperPlugin _swiperControl;

  int _swiperIndex = 0;

  ScrollController _scrollController = ScrollController();

  String _title = "Sunday";

  List _cineType = [
    "boxOffice",
    "kids",
    "show",
  ];

  List _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  TMDB tmdbWithCustomLogs;

  List<String> _titles = ["Home", "Weekly program", "Book a place", "Coming soon", "Profile"];

  TextEditingController _textController = TextEditingController();
  bool _appIsLoading;

  PageController _pageController = PageController();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  IndexController _indexController = IndexController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _swiperControl = SwiperControl(
      color: Palette.red,
    );
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.setAutoInitEnabled(true);

    _tabController = TabController(length: 3, vsync: this);

    _appIsLoading = true;

    tmdbWithCustomLogs = TMDB(
      ApiKeys(
        "3fcc3cf0902881ec381782b11cebbe92",
        "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZmNjM2NmMDkwMjg4MWVjMzgxNzgyYjExY2ViYmU5MiIsInN1YiI6IjVmODg5ZGRjZTMzZjgzMDAzN2ZkZjk1NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.tLu7CRm0t78C9_NtDb4_1KC8TC3sh6nqUGXdXq2BN44",
      ),
    );

    _firebaseMessaging.configure(
      onMessage: (message) => _notificationConfigure(message),
      onLaunch: (message) => _notificationConfigure(message),
      onResume: (message) => _notificationConfigure(message),
    );
    _appIsLoading = false;
  }

  Future<dynamic> _notificationConfigure(_message) {
    print(_message);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('onMessage'),
            content: Text(_message['notification']['title'] + _message['notification']['body']),
            actions: [
              FlatButton(
                child: Text('khra'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<List<Movie>> _getMovies() async {
    var data = await FirebaseFirestore.instance.collection('MoviesData').get();
    return List.generate(
      data.docs.length,
      (index) => Movie(
        data.docs[index]['title'],
        data.docs[index]['overview'],
        ProgressiveImage(
          blur: 10,
          alignment: Alignment.center,
          placeholder: AssetImage('assets/Netflix_Symbol_RGB.png'),
          // size: 1.87KB
          thumbnail: NetworkImage('http://image.tmdb.org/t/p/w92/' + data.docs[index]['poster_path']),
          // size: 1.29MB
          image: NetworkImage(
            'http://image.tmdb.org/t/p/w780/' + data.docs[index]['poster_path'],
          ),
          height: _screenHeight * .6,
          width: _screenWidth * .67,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.white,
      appBar: AppBar(
        shadowColor: Palette.darkRed.withOpacity(.0),
        backgroundColor: Palette.white,
        leading: IconButton(
          icon: Icon(MdiIcons.accountCircle, color: Palette.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.directions, color: Palette.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        height: _screenHeight,
        width: _screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              //   color: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Palette.red,
                labelColor: Palette.black,
                unselectedLabelColor: Palette.black.withOpacity(.75),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2,
                isScrollable: true,
                onTap: (index) {
                  setState(() {});
                  _swiperController.move(0);
                },
                indicator: CircleTabIndicator(color: Palette.darkRed, radius: 2),
                unselectedLabelStyle: TextStyle(
                  color: Palette.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
                labelStyle: TextStyle(
                  color: Palette.darkRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                tabs: [
                  Tab(
                    text: "Ciné'BoxOffice",
                  ),
                  Tab(
                    text: "Ciné'Kids",
                  ),
                  Tab(
                    text: "Ciné'Shows",
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: IndexedStack(
                  index: _tabController.index,
                  children: List.generate(
                    3,
                    (index) => StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('MoviesData').where("cineType", isEqualTo: _cineType[index]).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null)
                          return LinearProgressIndicator(
                            backgroundColor: Palette.black,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Palette.white.withOpacity(.05),
                            ),
                          );

                        if (snapshot.data.documents.length < 5) return Center(child: Text(snapshot.data.documents.length.toString()));

                        return Column(
                          children: [
                            Container(
                              width: _screenWidth,
                              height: _screenWidth,
                              child: Swiper(
                                controller: _swiperController,
                                control: _swiperControl,
                                itemCount: snapshot.data.documents.length,
                                loop: false,
                                viewportFraction: 0.67,
                                scale: 0.7,
                                onIndexChanged: (index) {
                                  setState(() {
                                    _swiperIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(25),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return MovieHome(
                                              movie: snapshot.data.documents[index],
                                              poster: Image.network(
                                                'http://image.tmdb.org/t/p/w780/' + snapshot.data.documents[index]['poster_path'],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        //color: Palette.red,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Hero(
                                        tag: 'Poster${snapshot.data.documents[index]['id']}',
                                        child: ProgressiveImage(
                                          blur: 10,
                                          alignment: Alignment.center,
                                          placeholder: AssetImage('assets/Netflix_Symbol_RGB.png'),
                                          // size: 1.87KB
                                          thumbnail: NetworkImage('http://image.tmdb.org/t/p/w92/' + snapshot.data.documents[index]['poster_path']),
                                          // size: 1.29MB
                                          image: NetworkImage(
                                            'http://image.tmdb.org/t/p/w780/' + snapshot.data.documents[index]['poster_path'],
                                          ),
                                          height: _screenHeight * .6,
                                          width: _screenWidth * .67,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: _screenWidth,
                                // color: Palette.red.withOpacity(.1),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Hero(
                                      tag: 'title${snapshot.data.documents[_swiperIndex]['id']}',
                                      child: AnimatedSwitcher(
                                        switchInCurve: Curves.easeOutExpo,
                                        duration: Duration(milliseconds: 300),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return SlideTransition(
                                            child: child,
                                            position: Tween<Offset>(begin: Offset(-_screenWidth, -0.0), end: Offset(0.0, 0.0)).animate(animation),
                                          );
                                        },
                                        child: Text(
                                          snapshot.data.documents[_swiperIndex]['title'],
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          key: ValueKey<String>(
                                            snapshot.data.documents[_swiperIndex]['title'],
                                          ),
                                          style: Theme.of(context).textTheme.headline4.copyWith(color: Palette.black),
                                        ),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      switchInCurve: Curves.easeOutExpo,
                                      duration: Duration(milliseconds: 500),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return SlideTransition(
                                          child: child,
                                          position: Tween<Offset>(begin: Offset(_screenWidth, -0.0), end: Offset(0.0, 0.0)).animate(animation),
                                        );
                                      },
                                      child: Text(
                                        snapshot.data.documents[_swiperIndex]['overview'],
                                        maxLines: 3,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        key: ValueKey<String>(
                                          snapshot.data.documents[_swiperIndex]['overview'],
                                        ),
                                        style: Theme.of(context).textTheme.bodyText1.copyWith(color: Palette.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.white,
      appBar: AppBar(
        shadowColor: Palette.darkRed.withOpacity(.0),
        backgroundColor: Palette.white,
        leading: IconButton(
          icon: Icon(MdiIcons.accountCircle, color: Palette.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.directions, color: Palette.black),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('MoviesData').where("cineType", isEqualTo: _cineType[_tabController.index]).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return LinearProgressIndicator(
              backgroundColor: Palette.black,
              valueColor: AlwaysStoppedAnimation<Color>(
                Palette.white.withOpacity(.05),
              ),
            );

          if (snapshot.data.documents.length < 5) return Center(child: Text(snapshot.data.documents.length.toString()));

          return Container(
            height: _screenHeight,
            width: _screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  //   color: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Palette.red,
                    labelColor: Palette.black,
                    unselectedLabelColor: Palette.black.withOpacity(.75),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 2,
                    isScrollable: true,
                    onTap: (index) {
                      _swiperController.move(0);
                      setState(() {});
                    },
                    indicator: CircleTabIndicator(color: Palette.darkRed, radius: 2),
                    unselectedLabelStyle: TextStyle(
                      color: Palette.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                    labelStyle: TextStyle(
                      color: Palette.darkRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    tabs: [
                      Tab(
                        text: "Ciné'BoxOffice",
                      ),
                      Tab(
                        text: "Ciné'Kids",
                      ),
                      Tab(
                        text: "Ciné'Shows",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          width: _screenWidth,
                          height: _screenWidth,
                          child: Swiper(
                            controller: _swiperController,
                            control: _swiperControl,
                            itemCount: snapshot.data.documents.length,
                            loop: false,
                            viewportFraction: 0.67,
                            scale: 0.7,
                            onIndexChanged: (index) {
                              setState(() {
                                _swiperIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MovieHome(
                                          movie: snapshot.data.documents[index],
                                          poster: Image.network(
                                            'http://image.tmdb.org/t/p/w780/' + snapshot.data.documents[index]['poster_path'],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    //color: Palette.red,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Hero(
                                    tag: 'Poster${snapshot.data.documents[index]['id']}',
                                    child: ProgressiveImage(
                                      blur: 10,
                                      alignment: Alignment.center,
                                      placeholder: AssetImage('assets/Netflix_Symbol_RGB.png'),
                                      // size: 1.87KB
                                      thumbnail: NetworkImage('http://image.tmdb.org/t/p/w92/' + snapshot.data.documents[index]['poster_path']),
                                      // size: 1.29MB
                                      image: NetworkImage(
                                        'http://image.tmdb.org/t/p/w780/' + snapshot.data.documents[index]['poster_path'],
                                      ),
                                      height: _screenHeight * .6,
                                      width: _screenWidth * .67,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: _screenWidth,
                            // color: Palette.red.withOpacity(.1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: 'title${snapshot.data.documents[_swiperIndex]['id']}',
                                  child: AnimatedSwitcher(
                                    switchInCurve: Curves.easeOutExpo,
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return SlideTransition(
                                        child: child,
                                        position: Tween<Offset>(begin: Offset(-_screenWidth, -0.0), end: Offset(0.0, 0.0)).animate(animation),
                                      );
                                    },
                                    child: Text(
                                      snapshot.data.documents[_swiperIndex]['title'],
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      key: ValueKey<String>(
                                        snapshot.data.documents[_swiperIndex]['title'],
                                      ),
                                      style: Theme.of(context).textTheme.headline4.copyWith(color: Palette.black),
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  switchInCurve: Curves.easeOutExpo,
                                  duration: Duration(milliseconds: 500),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return SlideTransition(
                                      child: child,
                                      position: Tween<Offset>(begin: Offset(_screenWidth, -0.0), end: Offset(0.0, 0.0)).animate(animation),
                                    );
                                  },
                                  child: Text(
                                    snapshot.data.documents[_swiperIndex]['overview'],
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    key: ValueKey<String>(
                                      snapshot.data.documents[_swiperIndex]['overview'],
                                    ),
                                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Palette.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      /* floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          int i = 0;
          /*   var data = FirebaseFirestore.instance.collection('MoviesData');
          data.get().then(
                (value) => value.docs.forEach(
                  (element) async {
                    if (element.exists)
                      await FirebaseFirestore.instance
                          .collection('MoviesData')
                          .doc(element.id)
                          .delete();
                  },
                ),
              ); */
          tmdbWithCustomLogs.v3.movies.getNowPlaying().then(
                (results) => results['results'].forEach(
                  (data) async {
                    await tmdbWithCustomLogs.v3.movies
                        .getDetails(data['id'], language: 'fr-FR')
                        .then(
                      (movieData) async {
                        await tmdbWithCustomLogs.v3.movies
                            .getVideos(data['id'])
                            .then(
                          (videosData) async {
                            await tmdbWithCustomLogs.v3.movies
                                .getImages(data['id'], language: '')
                                .then(
                              (imagesData) async {
                                await FirebaseFirestore.instance
                                    .collection('MoviesData')
                                    .add(movieData)
                                    .then(
                                  (docRef) {
                                    docRef.update(
                                      {
                                        "videos": videosData['results'],
                                        "backdrops": imagesData['backdrops'],
                                        "posters": imagesData['posters'],
                                        "cineType": _cineType[i % 3],
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                    i++;
                  },
                ),
              );
          /* _movies.forEach(
            (_id) async {
              await tmdbWithCustomLogs.v3.movies
                  .getDetails(_id, language: 'fr-FR')
                  .then(
                (movieData) async {
                  await tmdbWithCustomLogs.v3.movies.getVideos(_id).then(
                    (videosData) async {
                      await tmdbWithCustomLogs.v3.movies
                          .getImages(_id,
                              language: '', includeImageLanguage: '')
                          .then(
                        (imagesData) async {
                          await FirebaseFirestore.instance
                              .collection('MoviesData')
                              .add(movieData)
                              .then(
                            (docRef) {
                              docRef.update(
                                {
                                  "videos": videosData['results'],
                                  "backdrops": imagesData['backdrops'],
                                  "posters": imagesData['posters'],
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ); */
        },
        backgroundColor: Palette.darkRed,
        splashColor: Palette.red,
        foregroundColor: Palette.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        label: Text('Add Movie'),
      ), */
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius}) : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset = offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

/* return Swiper(
                    controller: _swiperController,
                    itemCount: snapshot.data.documents.length,
                    layout: SwiperLayout.CUSTOM,
                    itemWidth: .69 * (_screenWidth * 2 / 3),
                    //itemHeight: (_screenWidth * 2 / 3),
                    customLayoutOption: CustomLayoutOption(
                      startIndex: -1,
                      stateCount: snapshot.data.documents.length,
                    )
                        .addTranslate(
                          List.generate(
                            snapshot.data.documents.length,
                            (index) {
                              switch (index) {
                                case 0:
                                  return Offset(-_screenWidth * .75, 0);

                                  break;
                                case 1:
                                  return Offset(-_screenWidth * .25, 0);

                                  break;
                                case 2:
                                  return Offset(_screenWidth * .15, 0);

                                  break;
                                case 3:
                                  return Offset(_screenWidth * .425, 0);

                                  break;
                                default:
                                  return Offset(_screenWidth * .7, 0);
                              }
                            },
                          ),
                        )
                        .addScale(
                          List.generate(
                            snapshot.data.documents.length,
                            (index) {
                              switch (index) {
                                case 0:
                                  return .5;

                                  break;
                                case 1:
                                  return 1;

                                  break;
                                case 2:
                                  return .5;

                                  break;
                                case 3:
                                  return .5;

                                  break;
                                default:
                                  return .5;
                              }
                            },
                          ),
                          Alignment.center,
                        ),
                    loop: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MovieHome(
                                    movie: snapshot.data.documents[index]);
                              },
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            //  color: Palette.darkRed,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Hero(
                            tag:
                                'Poster${snapshot.data.documents[index]['id']}',
                            child: ProgressiveImage(
                              blur: 10,
                              alignment: Alignment.center,
                              placeholder:
                                  AssetImage('assets/Netflix_Symbol_RGB.png'),
                              // size: 1.87KB
                              thumbnail: NetworkImage(
                                  'http://image.tmdb.org/t/p/w92/' +
                                      snapshot.data.documents[index]
                                          ['poster_path']),
                              // size: 1.29MB
                              image: NetworkImage(
                                'http://image.tmdb.org/t/p/w780/' +
                                    snapshot.data.documents[index]
                                        ['poster_path'],
                              ),
                              height: 3000,
                              width: 5000,
                            ),
                          ),
                         
                        ),
                      );
                    },
                  );*/
