import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/appBar.dart';
import 'main.dart';

class ImageUploader extends StatefulWidget {
  String? uploadedImgURL = "";
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _image;
  final picker = ImagePicker();
  Reference _storageReference = FirebaseStorage.instance.ref().child('images');

  User? user = FirebaseAuth.instance.currentUser;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future uploadImage() async {
    if (_image == null) {
      // Handle the case when no image is selected
      return;
    }

    UploadTask uploadTask =
        _storageReference.child(user!.email!).putFile(_image!);

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Here you can use the `downloadURL` for further processing
    setState(() {
      widget.uploadedImgURL = downloadURL;
    });
    setUserProfileImage();
    print("Download URL: $downloadURL");
  }

  setUserProfileImage() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.email)
        .update({'profilePic': widget.uploadedImgURL});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarNav(
        goToHomePage: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePageWidget(
                      user: user,
                    )),
          );
        },
      ),
      body: Column(
        children: [
          _image != null
              ? Image.file(_image!)
              : Expanded(
                  child:
                      Placeholder(child: Image.network(widget.uploadedImgURL!)),
                ), // Display the selected image or a placeholder
          ElevatedButton(
            onPressed: getImage,
            child: Text("Select Image"),
          ),
          ElevatedButton(
            onPressed: uploadImage,
            child: Text("Upload Image"),
          ),
        ],
      ),
    );
  }
}
