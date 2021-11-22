import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
      await firebase_storage.FirebaseStorage.instance
          .ref(
              'images/${_nameController.text}${_priceController.text}${_image.toString()}')
          .putFile(File(_image!.path));
      downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(
              'images/${_nameController.text}${_priceController.text}${_image.toString()}')
          .getDownloadURL();
      uploadURL = downloadURL;
    }
    //모든 데이터 firestore에 올리기
    List<dynamic> forCreateList = [];

    firestore.collection('cafe').add(<String, dynamic>{
      'createdTime': FieldValue.serverTimestamp(),
      'modifiedTime': FieldValue.serverTimestamp(),
      'whoLike': forCreateList,
      'name': _nameController.text,
      'price': int.parse(_priceController.text),
      'description': _descriptionController.text,
      'url': uploadURL,
      'userId': user!.uid,
      // 'whoLike': FieldValue.arrayUnion(obg),
    });
  }

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.indigo[300],
        leading: TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/Home',
              (route) => false,
            );
          },
        ),
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/Home',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          //image가 나와야함
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3,
            child: Center(
              child: _image == null
                  ? Image.network(
                      "http://handong.edu/site/handong/res/img/logo.png",
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

          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Product Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a Product Name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    hintText: 'Price',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // Only numbers can be entered
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the Price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}