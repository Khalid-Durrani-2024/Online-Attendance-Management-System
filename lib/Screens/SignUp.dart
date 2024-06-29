import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sis_system/Models/CustomExceptions.dart';
import 'package:sis_system/Models/UserRigesterModel.dart';
import 'package:sis_system/Screens/HomePage.dart';
import 'package:sis_system/Screens/WaitingVerificationScreen.dart';
import 'package:sis_system/Widgets/LocalImageFile.dart';

import '../Models/UserInfo.dart';
import '../Widgets/ButtonWidget.dart';
import '../Widgets/LoadingWidget.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var NameController = TextEditingController();
  var EmailController = TextEditingController();
  var PasswordController = TextEditingController();
  UserRigesterModel _userRigesterModel = UserRigesterModel();
  FirebaseAuth auth = FirebaseAuth.instance;
  File? _pickedFile;
  User? user;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    try {
      final PickedImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (PickedImage != null) {
        setState(() {
          _pickedFile = File(PickedImage.path);
        });
      } else {
        print('CHeck Image is not Selected');
      }
    } catch (e) {
      print('Image is Not Selected + ' + e.toString());
    }
  }

  Future<void> uploadImage(String ImageName) async {
    print('Indide Upload image methode' + PickeFileFromStorage.toString());
    if (_pickedFile != null) {
      print('indide if of upload image method');
      img.Image? originalImage =
          img.decodeImage(_pickedFile!.readAsBytesSync());

      if (originalImage != null) {
        img.Image resizedImage =
            img.copyResize(originalImage, width: 600, height: 600);
        List<int> compressedImageData =
            img.encodeJpg(resizedImage, quality: 80);

        FirebaseStorage firebaseStorage = FirebaseStorage.instance;
        Reference reference =
            firebaseStorage.ref().child('Users/Images/' + ImageName + '.jpg');
        await reference
            .putData((Uint8List.fromList(compressedImageData)))
            .whenComplete(() => print('Image Successfully uploaded'));
      }
    } else {
      print('Image is not selected' + PickeFileFromStorage.toString());
    }
  }

  getImage() async {
    User? user = auth.currentUser;
    try {
      FirebaseStorage firebaseStorage = FirebaseStorage.instance;
      Reference reference =
          firebaseStorage.ref().child('Users/Images/${user!.uid}.jpg');

      return await reference.getDownloadURL();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> StoreUserData(userInfo user) async {
    try {
      _firestore.collection('Users').doc(user.Uid).set({
        'Name': user.Name,
        'Email': user.Email,
        'ProfileImageUrl': user.ProfileImageUrl,
        'isAdmin': false,
        'Uid': user.Uid
      });
    } catch (e) {
      print('Error Occured During Saving Data to Firestore' + e.toString());
    }
  }

  Future<void> SignUp() async {
    try {
      if (NameController.text != '') {
        if (EmailController.text != '') {
          if (PasswordController.text != '' &&
              PasswordController.text.length >= 6) {
            if (_pickedFile != null && _pickedFile != '') {
              try {
                setState(() {
                  _userRigesterModel.isLoading = true;
                });
                UserCredential userCredential =
                    await _userRigesterModel.CreatingUser(
                        EmailController.text.trim(),
                        PasswordController.text.trim(),
                        context);
                User? myUser = auth.currentUser;

                if (myUser != null) {
                  await uploadImage(myUser.uid.toString());
                  String imageName = await getImage();
                  userInfo CustomUser = userInfo(
                      Uid: auth.currentUser!.uid.toString(),
                      Name: NameController.text,
                      Email: EmailController.text.trim(),
                      ProfileImageUrl: imageName,
                      PhoneNumber: '',
                      Password: PasswordController.text.trim(),
                      isAdmin: false);
                  await StoreUserData(CustomUser);
                  userCredential.user!.sendEmailVerification();
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (context) => WaitingVerificationScreen(),
                  ))
                      .whenComplete(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('User Created Successfully'),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  });

                  setState(() {
                    isLoading = false;
                  });
                } else {
                  setState(() {
                    _userRigesterModel.isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error User didn"t Fetched'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              } on FirebaseNetworkException catch (e) {
                setState(() {
                  _userRigesterModel.isLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Colors.indigo,
                        icon: Icon(
                          Icons.error_outline_outlined,
                          color: Colors.red,
                          size: 50,
                        ),
                        title: Text(
                          'Network Error',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          e.message,
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Ok',
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      );
                    });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please Select an Image for Profile'),
                  duration: Duration(seconds: 4),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Password Required And Should be atleast 6 digits'),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email Required'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set a Name for Your Profile'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseNetworkException catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Network Error'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown, Colors.blueGrey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    )),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _userRigesterModel.isLoading == true
                          ? LoadingWidget()
                          : Container(),
                      InkWell(
                        onTap: () async {
                          PermissionStatus status =
                              await Permission.storage.request();
                          try {
                            if (status.isGranted) {
                              await _pickImage();
                            } else if (status.isDenied) {
                              print('Permission Denied');
                            } else if (status.isPermanentlyDenied) {
                              openAppSettings();
                            }
                          } catch (e) {
                            print('Exception Occured in Permission Handler');
                          }
                        },
                        child: _pickedFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _pickedFile!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.indigo,
                                    child: Center(
                                        child: Text(
                                      'No Image',
                                      style: TextStyle(color: Colors.white),
                                    ))),
                              ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: NameController,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: EmailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: PasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 24),
                      InkWell(
                        onTap: () async {
                          SignUp();
                        },
                        child: ButtonWidget(
                          size: 22,
                          text: "Sign Up",
                          height: 65,
                          width: 200,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Have Account? Sign In'),
                        style: TextButton.styleFrom(primary: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
