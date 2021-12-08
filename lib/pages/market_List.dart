import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_mad/pages/naviation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'home.dart';
import 'market.dart';

class MarketListPage extends StatefulWidget {
  @override
  _MarketListPageState createState() => _MarketListPageState();
}

class _MarketListPageState extends State<MarketListPage> {
  final launchSnackBar = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('market')
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
              title: Text('Market List'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 1,
                      padding: EdgeInsets.all(16),
                      childAspectRatio: 16.0 / 7.0,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Card(
                          color: Color(0xffFADFB3),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width ,
                                        child:ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                        child:Image.network(
                                          data['imageurl'],fit: BoxFit.cover,
                                        ),
                                        ),
                                      ),
 Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          // SizedBox(
                                          //   height: 20,
                                          //   child:
                                          TextButton(
                                            child: Text(
                                              data['title'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xffFADFB3),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MarketPage(
                                                          docId: document.id,
                                                          userId: user!.uid,
                                                        )),
                                              );
                                            },
                                          ),
                                          // ),

                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            height: 17,
                                            child: Text(
                                              "주소 : ${data['address'].toString()}",
                                              style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffFADFB3),
                                            ),
                                            ),
                                          ),
                                        ],
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
