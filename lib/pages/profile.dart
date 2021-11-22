import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Text(
        'Profile page test',
      ),
    );
  }
}

// class Profile extends StatefulWidget {
//   @override
//   State createState() => ProfileState();
// }

// class ProfileState extends State<Profile> {
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference users = FirebaseFirestore.instance.collection('user');

//     User? user = FirebaseAuth.instance.currentUser;
//     bool isAnonymous = user!.isAnonymous;
//     String? googleimage = user.photoURL;
//     String? googleEmail = user.email;

//     Future deleteUser() async {
//       await Firebase.initializeApp();

//       FirebaseFirestore.instance.collection('user').doc(user.uid).delete();
//       await FirebaseAuth.instance.currentUser!.delete();
//     }

//     return FutureBuilder<DocumentSnapshot>(
//       future: users.doc(user.uid).get(),
//       builder:
//           (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Text("Something went worng");
//         }
//         if (snapshot.hasData && !snapshot.data!.exists) {
//           return Text("Document does not exist");
//         }
//         if (snapshot.connectionState == ConnectionState.done) {
//           Map<String, dynamic> data =
//               snapshot.data!.data() as Map<String, dynamic>;

//           return Scaffold(
//             appBar: AppBar(
//               centerTitle: true,
//               backgroundColor: Colors.black87,
//               elevation: 0,
//               actions: [
//                 IconButton(
//                   icon: Icon(Icons.exit_to_app),
//                   onPressed: () async {
//                     if (user.isAnonymous) {
//                       deleteUser()
//                           .then((value) => FirebaseAuth.instance.signOut());
//                     } else {
//                       FirebaseAuth.instance.signOut();
//                     }
//                     Navigator.pushNamedAndRemoveUntil(
//                       context,
//                       '/',
//                       (route) => false,
//                     );
//                   },
//                 ),
//               ],
//             ),
//             body: Container(
//               color: Colors.black87,
//               padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
//               child: Column(
//                 // mainAxisAlignment: MainAxisAlignment.center,

//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height / 4,
//                     child: isAnonymous
//                         ? Image.network(
//                             "http://handong.edu/site/handong/res/img/logo.png")
//                         : Image.network(googleimage!),
//                   ),
//                   //uid
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         data['uid'],
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       //구분선
//                       Divider(
//                         thickness: 1.5,
//                         color: Colors.white,
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       //이메일
//                       isAnonymous
//                           ? Text(
//                               'Anonymous',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 12,
//                               ),
//                             )
//                           : Text(
//                               data['email'],
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 12,
//                               ),
//                             ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       //이름
//                       isAnonymous
//                           ? Text(
//                               'Anonymous name',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 15,
//                               ),
//                             )
//                           : Text(
//                               data['name'],
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                               ),
//                             ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       //문구
//                       //함수를 만들어서 구현
//                       // Text("I promise to take the test honestly before God"),
//                       Consumer<ApplicationState>(
//                         builder: (context, appState, _) => StatusMessageChange(
//                           editState: appState.editState,
//                           startEdit: appState.startEdit,
//                           finishEdit: appState.finishEdit,
//                         ),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           );
//         }
//         return Scaffold(
//           appBar: AppBar(
//             centerTitle: true,
//             // title: Text('Google Sign In'),
//             backgroundColor: Colors.black87,
//             elevation: 0.0,
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.exit_to_app),
//                 onPressed: () {
//                   if (user.isAnonymous) {
//                     FirebaseFirestore.instance
//                         .collection('user')
//                         .doc(user.uid)
//                         .delete();
//                   }
//                   FirebaseAuth.instance.signOut();
//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/',
//                     (route) => false,
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: Container(
//             color: Colors.black87,
//             child: Text('Loading'),
//           ),
//         );
//       },
//     );
//   }
// }

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
                    data['status_message'],
                    style: TextStyle(
                      color: Colors.white,
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
              _statusController =
                  TextEditingController(text: data['status_message']);
              return Column(
                children: [
                  TextFormField(
                    controller: _statusController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a status_message';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: Colors.white,
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
