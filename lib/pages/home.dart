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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                // leading: IconButton(
                //   icon: const Icon(
                //     Icons.person,
                //     semanticLabel: 'Profile',
                //   ),
                // onPressed: () {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (context) => ProfilePage())
                //       // Navigator.pushNamed(
                //       //   context,
                //       //   '/Profile',
                //       );
                // },
                // ),
                // title: Consumer<LoginProvider>(
                //   builder: (_, appState, __) => Text(appState.name),
                // ),
                // actions: <Widget>[
                //   IconButton(
                //     icon: const Icon(
                //       Icons.add,
                //       semanticLabel: 'Add Product',
                //     ),
                //     onPressed: () {},
                //   ),
                // ],
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
              // leading: IconButton(
              //   icon: const Icon(
              //     Icons.person,
              //     semanticLabel: 'Profile',
              //   ),
              //   onPressed: () {
              //     for (int i = 0; i < titleList.length; i++) {
              //       print(titleList[i]);
              //       print(imageList[i]);
              //     }
              //   },
              // ),
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
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(16),
                      childAspectRatio: 8.0 / 9.0,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        searchTitleList.add(data['title']);
                        docList.add(document.id);
                        return Container(
                          // padding: EdgeInsets.all(8),
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(8),
                                height: MediaQuery.of(context).size.width / 2,
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  color: Color(0xffFADFB3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    data['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => DetailPage(
                                                    docId: document.id,
                                                    userId: user!.uid,
                                                  )),
                                          (route) => false);
                                    },
                                    child: Text(
                                      data['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFF4B556),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
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
