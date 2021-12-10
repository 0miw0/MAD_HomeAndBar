import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:reviews_slider/reviews_slider.dart';

import 'detail.dart';

class EditPage extends StatefulWidget {
  final String docId;
  final String title;
  final String strongPoint;
  final String recipe;
  final String youtubeLink;
  final int review;
  EditPage({
    Key? key,
    required this.docId,
    required this.title,
    required this.strongPoint,
    required this.recipe,
    required this.youtubeLink,
    required this.review,
  }) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  PickedFile? _image;
  String? imageName;
  String? imagePath;
  String? downloadURL;
  // late String name;
  // late String price;
  // late String description;

  late TextEditingController _nameController;

  late TextEditingController _strongController;
  late TextEditingController _recipeController;
  late TextEditingController _youtubeLinkController;
  late int _reviewController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.title);
    _strongController = TextEditingController(text: widget.strongPoint);
    _recipeController = TextEditingController(text: widget.recipe);
    _youtubeLinkController = TextEditingController(text: widget.youtubeLink);
  }

  Future getImageFromGallery() async {
    await Firebase.initializeApp();

    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!;
      imageName = _image!.path.split('/').last.toString();
    });
  }

  Future updateFireStore(String defaultURL, String docId) async {
    String? uploadURL;
    User? user = FirebaseAuth.instance.currentUser;
    if (_image == null) {
      uploadURL = defaultURL;
    } else {
      String dataTime = DateTime.now().timeZoneOffset.inMilliseconds.toString();
      firebase_storage.FirebaseStorage.instance.refFromURL(defaultURL).delete();
      await firebase_storage.FirebaseStorage.instance
          .ref(
              'images/${_nameController.text}${_strongController.text}${_image.toString()}')
          .putFile(File(_image!.path));
      downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(
              'images/${_nameController.text}${_strongController.text}${_image.toString()}')
          .getDownloadURL();
      uploadURL = downloadURL;
    }
    //모든 데이터 firestore에 올리기

    await firestore.collection('recipe').doc(docId).update({
      'title': _nameController.text,
      'recipe': _recipeController.text,
      'strongPoint': _strongController.text,
      'imageUrl': uploadURL,
      'youtubeLink': _youtubeLinkController.text,
      'review': _reviewController,
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('recipe');
    User? user = FirebaseAuth.instance.currentUser;

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

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailPage(
                                docId: widget.docId,
                                userId: user!.uid,
                              )),
                      (route) => false);
                },
              ),
              title: Text('Edit'),
              actions: [
                TextButton(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    updateFireStore(data['imageUrl'], widget.docId)
                        .then((value) => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                      docId: widget.docId,
                                      userId: user!.uid,
                                    )),
                            (route) => false));
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  //image가 나와야함
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    child: Center(
                      child: _image == null
                          ? Image.network(
                              data['imageUrl'],
                              // fit: BoxFit.fitHeight,
                            )
                          : Image.file(File(_image!.path)),
                    ),
                  ),
                  //만약 이미지 지정안하고 저장하면 default image로 저장되어야 한다.
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width / 8 * 6, 0, 0, 0),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: getImageFromGallery,
                    ),
                  ),
                  ReviewSlider(
                      initialValue: data['review'],
                      onChange: (int value) {
                        _reviewController = value;
                        // active value is an int number from 0 to 4, where:
                        // 0 is the worst review value
                        // and 4 is the best review value
                        print(value);
                      }),
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a Product Name';
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _strongController,
                          style: TextStyle(
                            color: Colors.indigo[700],
                            fontSize: 20,
                          ), // Only numbers can be entered
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter the strong';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _recipeController,
                          style: TextStyle(
                            color: Colors.indigo[600],
                            fontSize: 15,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a recipe';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _youtubeLinkController,
                          style: TextStyle(
                            color: Colors.indigo[600],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        //loading
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.indigo[300],
            title: Text('Detail'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
