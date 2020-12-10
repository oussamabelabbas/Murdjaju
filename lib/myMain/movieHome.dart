import 'dart:ui';

import 'package:murdjaju/myMain/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MovieHome extends StatefulWidget {
  final DocumentSnapshot movie;
  final Image poster;
  MovieHome({Key key, this.movie, this.poster}) : super(key: key);

  @override
  _MovieHomeState createState() => _MovieHomeState();
}

class _MovieHomeState extends State<MovieHome> {
  double get _screenHeight => MediaQuery.of(context).size.height;
  double get _screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: _screenHeight,
        width: _screenWidth,
        child: Stack(
          children: [
            Container(
              height: _screenHeight,
              width: _screenWidth,
              color: Palette.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                      tag: 'Poster${widget.movie['id']}', child: widget.poster),
                ],
              ),
            ),
            DraggableScrollableSheet(
              minChildSize: .2,
              maxChildSize: .8,
              initialChildSize: .2,
              builder: (context, _sc) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                        color: Palette.white,
                      ),
                      height: _screenHeight,
                      child: ListView(
                        padding: EdgeInsets.all(5),
                        controller: _sc,
                        children: [
                          Hero(
                            tag: 'title${widget.movie['id']}',
                            child: Text(
                              widget.movie['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(color: Palette.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                return Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                    color: Palette.white,
                  ),
                  height: _screenHeight,
                  child: ListView(
                    padding: EdgeInsets.all(5),
                    controller: _sc,
                    children: [
                      Hero(
                        tag: 'title${widget.movie['id']}',
                        child: Text(
                          widget.movie['title'],
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              .copyWith(color: Palette.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
