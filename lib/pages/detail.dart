import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_mad/pages/naviation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:reviews_slider/reviews_slider.dart';


import 'edit.dart';

//same error about Named Push
import 'home.dart';

class DetailPage extends StatefulWidget {
  final String docId;
  final String userId;
  const DetailPage({Key? key, required this.docId, required this.userId})
      : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final launchSnackBar = GlobalKey<ScaffoldState>();
  Future deleteProduct(String userId, String url) async {
    await Firebase.initializeApp();

    firebase_storage.FirebaseStorage.instance.refFromURL(url).delete();
    FirebaseFirestore.instance.collection('recipe').doc(widget.docId).delete();
  }

  // late int likeCount;

  Future updateList(List<dynamic> likeList, String userId, String docId) async {
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // for (int i = 0; i < likeList.length; i++) {
    //   if (likeList[i] == userId) {
    //     return ScaffoldMessenger.of(context).showSnackBar(alreadySnackBar());
    //   }
    // }

    firestore.collection('recipe').doc(docId).update({
      "whoLike": FieldValue.arrayUnion([userId])
    });

    ScaffoldMessenger.of(context).showSnackBar(firstSnackBar());
  }

  SnackBar firstSnackBar() {
    return SnackBar(content: Text('I LIKE IT!'));
  }

  SnackBar alreadySnackBar() {
    return SnackBar(content: Text('You can only do it once!!'));
  }

  late YoutubePlayerController _controller;

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('recipe');
    User? user = FirebaseAuth.instance.currentUser;
    String link = 'https://youtu.be/WkNO63qlTZc';
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.docId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went worng");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          // likeCount = data['whoLike'].length;
          _controller = YoutubePlayerController(
            initialVideoId: data['youtubeLink'].toString().split('/').last,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: true,
            ),
          );
          return Scaffold(
            key: launchSnackBar,
            appBar: AppBar(
              centerTitle: true,
              // backgroundColor: Colors.indigo[300],
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => NavigationPage()));
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/Navi',
                    (route) => false,
                  );
                },
              ),
              title: Text('Detail'),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // edit page로 넘어가는 거
                    if (user!.uid == data['uid']) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditPage(
                                    docId: widget.docId,
                                    title: data['title'],
                                    strongPoint: data['strongPoint'].toString(),
                                    recipe: data['recipe'],
                                    youtubeLink: data['youtubeLink'],
                                    review:data['review'],
                                  )),
                          (route) => false);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (user!.uid == data['uid']) {
                      deleteProduct(data['uid'], data['imageUrl']);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                      // Navigator.pushNamedAndRemoveUntil(
                      //   context,
                      //   '/Home',
                      //   (route) => false,째
                      // );
                    }
                  },
                ),
              ],
            ),
            body: Container(
              child: new SingleChildScrollView(
                child: Column(
                  children: [
                    //image가 나와야함
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3,
                      child: Image.network(
                        data['imageUrl'],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                      child: Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children:[
                              ReviewSlider(
                                initialValue: data['review'],

                              ),
                                Container(),
                              ],
                            ),
                            Row(
                              children: [

                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 5 * 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        data['title'],
                                        style: TextStyle(
                                          color: Colors.indigo[900],
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Strong Point:',
                                        style: TextStyle(
                                          color: Colors.indigo[700],
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        '${data['strongPoint']}',
                                        style: TextStyle(
                                          color: Colors.indigo[700],
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(
                                //   width: 20,
                                // ),
                                // IconButton(
                                //   icon: Icon(
                                //     Icons.thumb_up,
                                //     color: Colors.red,
                                //   ),
                                //   onPressed: () {
                                //     //
                                //     updateList(
                                //       data['whoLike'],
                                //       widget.userId,
                                //       widget.docId,
                                //     );
                                //     setState(() {
                                //       likeCount = data['whoLike'].length;
                                //     });
                                //   },
                                // ),
                                //array의 길이를 가져오면 되지 않을까.
                                // Text(
                                //   likeCount.toString(),
                                //   style: TextStyle(
                                //     color: Colors.red,
                                //     fontSize: 20,
                                //   ),
                                // ),
                              ],
                            ),
                            Divider(
                              thickness: 2.0,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Recipe',
                              style: TextStyle(
                                color: Colors.indigo[600],
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              data['recipe'],
                              style: TextStyle(
                                color: Colors.indigo[600],
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 8,
                            ),
                            Text(
                              data['uid'],
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                              ),
                            ),
                            // Text(
                            //   "${DateFormat('yyyy.MM.dd.hh.mm.ss').format(data['createdTime'].toDate())} Created",
                            //   style: TextStyle(
                            //     color: Colors.black26,
                            //     fontSize: 10,
                            //   ),
                            // ),
                            // Text(
                            //   "${DateFormat('yyyy.MM.dd.hh.mm.ss').format(data['modifiedTime'].toDate())} Modified",
                            //   style: TextStyle(
                            //     color: Colors.black26,
                            //     fontSize: 10,
                            //   ),
                            // ),
                            if (data["youtubeLink"]
                                    .toString()
                                    .split('/')
                                    .length ==
                                4)
                              if (data["youtubeLink"]
                                      .toString()
                                      .split('/')[2] ==
                                  'youtu.be')
                                YoutubePlayer(
                                  controller: _controller,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: Colors.blueAccent,
                                  topActions: <Widget>[
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        _controller.metadata.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.settings,
                                        color: Colors.white,
                                        size: 25.0,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                  onReady: () {},
                                  onEnded: (data) {},
                                ),
                            Container(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        //loading
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            // backgroundColor: Colors.indigo[300],
            title: Text('Detail'),
          ),
          body: Center(
            child: Text('loading..'),
          ),
        );
      },
    );
  }
}
