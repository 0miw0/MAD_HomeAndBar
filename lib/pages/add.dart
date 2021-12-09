import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:reviews_slider/reviews_slider.dart';

//same namepush error
import 'home.dart';
import 'naviation.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  PickedFile? _image;
  String? imageName;
  String? imagePath;
  String? downloadURL;

  Future getImageFromGallery() async {
    await Firebase.initializeApp();
    //사진 고르기
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!;
      imageName = _image!.path.split('/').last.toString();
    });
  }

  Future uploadFireStore() async {
    // await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;
//사진 storage에 올리고 URL 가져오기
    String? uploadURL;
    if (_image == null) {
      uploadURL = "http://handong.edu/site/handong/res/img/logo.png";
    } else {
      print("Image Choosed");
      String dataTime = DateTime.now().timeZoneOffset.inMilliseconds.toString();
      await firebase_storage.FirebaseStorage.instance
          .ref(
              'images/${_nameController.text}${_strongController.text}${_image.toString()}')
          .putFile(File(_image!.path));
      print("Image Uploaded");
      downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(
              'images/${_nameController.text}${_strongController.text}${_image.toString()}')
          .getDownloadURL();
      uploadURL = downloadURL;
    }
    //모든 데이터 firestore에 올리기
    List<dynamic> forCreateList = [];

    firestore.collection('recipe').add(<String, dynamic>{
      'title': _nameController.text,
      'strongPoint': _strongController.text,
      'recipe': _descriptionController.text,
      'imageUrl': uploadURL,
      'uid': user!.uid,
      'youtubeLink': _youtubeLinkController.text,
      // 'review': _reviewController,

      // 'whoLike': FieldValue.arrayUnion(obg),
    });

    // firestore.collection('user').doc('user!.uid')
  }

  final _nameController = TextEditingController();
  final _strongController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  late int _reviewController=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // leading: TextButton(
        //   child: Text(
        //     'Cancel',
        //     style: TextStyle(
        //       color: Colors.black87,
        //       fontSize: 12,
        //     ),
        //   ),
        //   onPressed: () {
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => NavigationPage()));
        //     // Navigator.pushNamedAndRemoveUntil(
        //     //   context,
        //     //   '/HomePage',
        //     //   (route) => false,
        //     // );
        //   },
        // ),
        title: Text('Add'),
        actions: [
          TextButton(
            child: Text(
              'save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              //저장으로 보내기 위한 트릭거
              uploadFireStore();

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NavigationPage()));
              // Navigator.pushNamedAndRemoveUntil(
              //   context,
              //   '/HomePage',
              //   (route) => false,
              // );
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
                          "https://firebasestorage.googleapis.com/v0/b/mobilefinalproject-c80da.appspot.com/o/DefaultImage%2FDrinkImage.jpg?alt=media&token=a2bce4fc-30b1-4707-86af-721df2948017",                          // fit: BoxFit.fitHeight,
                        )
                      : Image.file(File(_image!.path))),
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
      // ReviewSlider(
      //     onChange: (int value){
      //       _reviewController=value;
      //       // active value is an int number from 0 to 4, where:
      //       // 0 is the worst review value
      //       // and 4 is the best review value
      //       print(value);
      //     }),

            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Title of Recipe',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a Product Name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _strongController,
                    decoration: const InputDecoration(
                      hintText: 'Strong',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter the Strong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a Description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _youtubeLinkController,
                    decoration: const InputDecoration(
                      hintText: 'YoutubeVideo Link',
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
}
