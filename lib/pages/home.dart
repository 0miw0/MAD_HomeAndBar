import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
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

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('recipe')
        // .orderBy("name", descending: classDropDown)
        .snapshots();

    User? user = FirebaseAuth.instance.currentUser;

    List<String> titleList = [];
    List<String> docList = [];

    return StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.person,
                    semanticLabel: 'Profile',
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage())
                        // Navigator.pushNamed(
                        //   context,
                        //   '/Profile',
                        );
                  },
                ),
                title: Consumer<LoginProvider>(
                  builder: (_, appState, __) => Text(appState.name),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      semanticLabel: 'Add Product',
                    ),
                    onPressed: () {},
                  ),
                ],
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
              leading: IconButton(
                icon: const Icon(
                  Icons.person,
                  semanticLabel: 'Profile',
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));

                  // Navigator.pushNamed(
                  //   context,
                  //   '/Profile',
                  // );
                },
              ),
              title: Consumer<LoginProvider>(
                builder: (_, appState, __) => Text(appState.name),
              ),
              actions: <Widget>[

                IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MarketListPage ()));

                }, icon: const Icon(Icons.document_scanner)),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    semanticLabel: 'Add Product',
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddPage()));
                    // Navigator.pushNamedAndRemoveUntil(
                    //   context,
                    //   '/Add',
                    //   (route) => false,
                    // );
                  },
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(16),
                  //   child: Consumer<DropDownProvider>(
                  //     builder: (_, appState, __) => DropdownButton(
                  //       value: dropdownvalue,
                  //       icon: Icon(Icons.keyboard_arrow_down),
                  //       items: items.map((String items) {
                  //         return DropdownMenuItem(
                  //             value: items, child: Text(items));
                  //       }).toList(),
                  //       onChanged: (String? newValue) {
                  //         setState(() {
                  //           dropdownvalue = newValue!;
                  //           appState.setDropDown(newValue);
                  //           classDropDown = appState.dropDown;
                  //         });
                  //       },
                  //     ),
                  //   ),
                  // ),

                  //검색창이랑 Dailey 추천 올리기
                  Container(
                    padding: EdgeInsets.all(20),
                    child: DropdownSearch<String>(
                      mode: Mode.BOTTOM_SHEET,

                      //to show search box
                      //여기서 부터
                      showSearchBox: true,
                      showSelectedItem: true,
                      //list of dropdown items
                      //db에서 가져와서 채워야 함.
                      // items: [
                      //   //firebase에서 제목만 가져와야함.
                      //   "americano",
                      //   "Longu",
                      //   "Latte",
                      //   "Caramel Macchiato",
                      //   "And... we need to change it"
                      // ],
                      items: titleList,
                      label: "search",
                      onChanged: (data) {
                        int index = 0;
                        print(data);
                        for (int i = 0; i < titleList.length; i++) {
                          if (data == titleList[i]) {
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
                        titleList.add(data['title']);
                        docList.add(document.id);
                        return Card(
                          color: Color(0xffFADFB3),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
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
                                                "\$ ${data['strongPoint'].toString()}",
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
                      // children: _buildGridCards(context),
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
