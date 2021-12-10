import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';

import '../main.dart';
import 'detail.dart';

//NamedPush Doesn't work so i Changed push and import every single dart
import 'profile.dart';
import 'add.dart';
import 'market.dart';

import 'market_List.dart';

class FailPage extends StatefulWidget {
  const FailPage({Key? key}) : super(key: key);

  @override
  _FailPageState createState() => _FailPageState();
}

class _FailPageState extends State<FailPage> {
  String dropdownvalue = 'ASC';
  var items = [
    'ASC',
    'DESC',
  ];

  bool classDropDown = DropDownProvider().dropDown;
  List<String> searchTitleList = [];
  List<String> docList = [];
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('recipe')
        // .orderBy("name", descending: classDropDown)
        .snapshots();

    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text('loading'),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Consumer<LoginProvider>(
                builder: (_, appState, __) => Text(appState.name),
              ),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MarketListPage()));
                    },
                    icon: const Icon(Icons.shop_2)),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //검색창이랑 Dailey 추천 올리기
                  Container(
                    padding: EdgeInsets.all(20),
                    child: DropdownSearch<String>(
                      mode: Mode.BOTTOM_SHEET,

                      //to show search box
                      //여기서 부터
                      showSearchBox: true,
                      showSelectedItem: true,

                      items: searchTitleList,
                      label: "search",
                      onChanged: (data) {
                        int index = 0;
                        print(data);
                        for (int i = 0; i < searchTitleList.length; i++) {
                          if (data == searchTitleList[i]) {
                            index = i;
                          }
                        }
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                      docId: docList[index],
                                      userId: user!.uid,
                                    )),
                            (route) => false);
                      },

                      selectedItem: "",
                    ),
                  ),
                  //https://power-of-optimism.tistory.com/425
                  Expanded(
                    //count로 직접 다 할때
                    child: StaggeredGridView.count(
                      crossAxisSpacing: 6, //Cross축 ithem 사이 공간 간격
                      mainAxisSpacing: 6, //Main축 ithem 사이 공간 간격
                      crossAxisCount: 2,

                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        // titleList.add(data['title']);
                        // docList.add(document.id);
                        return Card(
                          color: Color(0xffFADFB3),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Image.network(
                              //   data['imageUrl'],
                              //   fit: BoxFit.fitHeight,
                              // ),
                              AspectRatio(
                                aspectRatio: 18 / 11,
                                child: Image.network(
                                  data['imageUrl'],
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(10.0, 15.0, 0, 0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        height: 50,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 20,
                                              child: Text(
                                                data['title'],
                                                // style: theme.textTheme.headline6,
                                                maxLines: 2,
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Container(
                                              height: 17,
                                              child: Text(
                                                "${data['strongPoint'].toString()}",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 25, 0, 0),
                                        child: TextButton(
                                          child: Text(
                                            'more',
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailPage(
                                                          docId: document.id,
                                                          userId: user!.uid,
                                                        )),
                                                (route) => false);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      //화면에 보여주는 각각 Tile의 크기와 Tile의 갯수
                      staggeredTiles: [
                        StaggeredTile.count(1, 2),
                        StaggeredTile.count(1, 1),
                        StaggeredTile.count(1, 2),
                        StaggeredTile.count(1, 2),
                        StaggeredTile.count(1, 1),
                        StaggeredTile.count(1, 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: false,
          );
        });
  }
}
