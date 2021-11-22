import 'dart:async';
import 'dart:convert' show json;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';

import '../main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Container(
                  height: 250,
                  width: 250,
                  child: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/mobile-final-7747c.appspot.com/o/images%2Fmilkyway.jpg?alt=media&token=74a90b2c-ff67-4f4d-8911-b6b8f60ddda6',
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('final.....plz....'),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 15,
            ),
            Column(
              children: [
                //여기에 넣어야함.
                _OtherProvidersSignInSection(),
                _AnonymouslySignInSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnonymouslySignInSection extends StatefulWidget {
  const _AnonymouslySignInSection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnonymouslySignInSectionState();
}

class _AnonymouslySignInSectionState extends State<_AnonymouslySignInSection> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool? _success;
  String _userID = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 16),
            alignment: Alignment.center,
            child: Consumer<LoginProvider>(
              builder: (_, appState, __) => SignInButtonBuilder(
                text: 'Sign In',
                icon: Icons.person_outline,
                backgroundColor: Colors.deepPurple,
                onPressed: () {
                  _signInAnonymously();
                  appState.setName("Guest");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Example code of how to sign in anonymously.
  Future<void> _signInAnonymously() async {
    try {
      final User user = (await _auth.signInAnonymously()).user!;
      await FirebaseAuth.instance.signInAnonymously(); //${user.uid}

      firestore.collection('user').doc(user.uid).set(<String, dynamic>{
        'status_message': "I promise to take the test honestly before GOD",
        'uid': user.uid,
      });

      // ChangeNotifierProvider(
      //   create: (context) => LoginProvider(),
      // );
      LoginProvider().setName("Guest");

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/Navi',
        (route) => false,
      );
    } catch (e) {
      print('Failed to sign in Anonymously');
    }
  }
}

class _OtherProvidersSignInSection extends StatefulWidget {
  const _OtherProvidersSignInSection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OtherProvidersSignInSectionState();
}

class _OtherProvidersSignInSectionState
    extends State<_OtherProvidersSignInSection> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late String plzName = "asdf";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 16),
            alignment: Alignment.center,
            child: Consumer<LoginProvider>(
              builder: (_, appState, __) => SignInButton(
                Buttons.Google,
                text: 'Sign In',
                onPressed: () async {
                  _signInWithGoogle().then((value) {
                    appState.setName(plzName);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        var googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;
        final googleAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(googleAuthCredential);
      }

      final user = userCredential.user;

      firestore.collection('user').doc(user!.uid).set(<String, dynamic>{
        'email': user.email,
        'name': user.displayName,
        'status_message': "I promise to take the test honestly before GOD",
        'uid': user.uid,
      });
      plzName = user.displayName!;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/Navi',
        (route) => false,
      );
    } catch (e) {
      print(e);
    }
  }
}
