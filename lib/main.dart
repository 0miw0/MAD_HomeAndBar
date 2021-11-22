import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_mad/pages/profile.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/login.dart';
import 'pages/naviation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoginProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ApplicationState(),
        ),
        ChangeNotifierProvider(
          create: (context) => DropDownProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Final 21600223',
        initialRoute: '/',
        routes: {
          '/': (context) =>
              //HomePage(),
              LoginPage(),
          '/Navi': (context) => NavigationPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class DropDownProvider extends ChangeNotifier {
  bool _dropDown = true;
  bool get dropDown => _dropDown;
  void setDropDown(String setDrop) {
    if (setDrop == "ASC") {
      _dropDown = true;
    } else if (setDrop == 'DESC') {
      _dropDown = false;
    }
  }
}

class LoginProvider extends ChangeNotifier {
  late String _name;
  String get name => _name;
  void setName(String? setName) {
    _name = "Welcome " + setName! + "!";
    notifyListeners();
  }
}

class ApplicationState extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
  }

  ApplicationEditState _editState = ApplicationEditState.toEdit;
  ApplicationEditState get editState => _editState;

  void startEdit() {
    _editState = ApplicationEditState.toSave;
    notifyListeners();
  }

  void finishEdit(String statusUpdate, String docId) {
    firestore.collection('user').doc(docId).update({
      'status_message': statusUpdate,
    });

    _editState = ApplicationEditState.toEdit;
    notifyListeners();
  }
}
