import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cool_alert/cool_alert.dart';

import '../main.dart';

class ProfilePage extends StatefulWidget {
  @override
  State createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('user');

    User? user = FirebaseAuth.instance.currentUser;
    bool isAnonymous = user!.isAnonymous;
    String? googleimage = user.photoURL;

    Future deleteUser() async {
      await Firebase.initializeApp();

      FirebaseFirestore.instance.collection('user').doc(user.uid).delete();
      await FirebaseAuth.instance.currentUser!.delete();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user.uid).get(),
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

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Profile"),
            ),
            body: SingleChildScrollView(
              child: Container(
                // color: Colors.black87,
                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: isAnonymous
                              ? Text(
                                  'Anonymous name',
                                  style: TextStyle(
                                    // color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                )
                              : Text(
                                  data['name'],
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: isAnonymous
                              ? Image.network(
                                  "http://handong.edu/site/handong/res/img/logo.png")
                              : Image.network(googleimage!),
                        ),
                      ],
                    ),

                    //uid

                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Consumer<ApplicationState>(
                            builder: (context, appState, _) =>
                                StatusMessageChange(
                              editState: appState.editState,
                              startEdit: appState.startEdit,
                              finishEdit: appState.finishEdit,
                            ),
                          ),

                          SizedBox(
                            height: 20,
                          ),

                          Divider(
                            thickness: 1.5,
                            // color: Colors.white,
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: ElevatedButton(
                                onPressed: () {
                                  CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.info,
                                      text:
                                          "???1??? (??????) ??? ????????? ??????????????????(?????? ??????????????? ???)??? ???????????? ??????????????????????????? ?????? ?????? ?????? ??? ?????????(?????? ?????????????????? ???)??? ???????????? ?????? ???????????? ??????_?????? ??? ????????? ?????? ????????? ???????????? ???????????? ?????????.????????????, ???????????????, ????????? ??? ????????? ?????? ?????? ???????????? ?????????????????? ???????????? ??? ????????? ????????? ?????? ??? ??? ????????? ??????????????????");
                                },
                                child: Text(
                                  "????????????",
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffFDF2E0),
                                  onPrimary: Color(0xffFDF2E3),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          //?????????
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 35,
                            padding: EdgeInsets.all(10),
                            child: isAnonymous
                                ? Text(
                                    'Anonymous',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      // color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  )
                                : Text(
                                    data['email'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      // color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                            decoration: BoxDecoration(
                              color: Color(0xffFDF2E0),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                  bottomLeft: Radius.circular(3),
                                  bottomRight: Radius.circular(3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0.5,
                                  blurRadius: 1,
                                  offset: Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (user.isAnonymous) {
                                    deleteUser().then((value) =>
                                        FirebaseAuth.instance.signOut());
                                  } else {
                                    FirebaseAuth.instance.signOut();
                                  }
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  "????????????",
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffFDF2E0),
                                  onPrimary: Color(0xffFDF2E3),
                                )),
                          ),
                        ])
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Profile"),
          ),
          body: Center(
            child: Text(
              'Loading',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}

enum ApplicationEditState {
  toEdit,
  toSave,
}

class StatusMessageChange extends StatelessWidget {
  const StatusMessageChange(
      {Key? key,
      required this.editState,
      required this.startEdit,
      required this.finishEdit})
      : super(key: key);

  final ApplicationEditState editState;
  final void Function() startEdit;
  final void Function(String statusUpdate, String docId) finishEdit;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    switch (editState) {
      case ApplicationEditState.toEdit:
        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('user')
              .doc(user!.uid)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  Text(
                    data['message'],
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    child: Text('edit'),
                    onPressed: () {
                      startEdit();
                    },
                  ),
                ],
              );
            }
            return CircularProgressIndicator();
          },
        );

      case ApplicationEditState.toSave:
        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('user')
              .doc(user!.uid)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              final TextEditingController _statusController;
              _statusController = TextEditingController(text: data['message']);
              return Column(
                children: [
                  TextFormField(
                    controller: _statusController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a message';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text('save'),
                    onPressed: () {
                      finishEdit(_statusController.text, user.uid);
                    },
                  ),
                ],
              );
            }
            return CircularProgressIndicator();
          },
        );
    }
  }
}
