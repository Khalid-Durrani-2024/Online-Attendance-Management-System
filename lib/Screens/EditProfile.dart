import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sis_system/Models/UserInfo.dart';
import 'package:sis_system/Models/UserModel.dart';
import 'package:sis_system/Screens/HomePage.dart';
import 'package:sis_system/Screens/SignUp.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';
import 'package:sis_system/Widgets/LocalImageFile.dart';

import '../Models/LocalImageFile.dart';
import '../Widgets/ButtonWidget.dart';
import '../Widgets/TextFields.dart';
import '../Widgets/TextWidget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

var NameController = TextEditingController();
var PhoneNumberController = TextEditingController();
var NewPasswordController = TextEditingController();
var OldPasswordController = TextEditingController();
var ConfirmNewPasswordController = TextEditingController();
var testing = TextEditingController();
UserModel _model = UserModel();
FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;
bool StateChanging = true;
bool isLoading = false;
File? _pickedFile;
String downloadImageUrl = '';
bool isImageSelecting = false;
bool isAdmin = false;
GetCurrentData() async {
  User? user = await auth.currentUser;
  userInfo map = await _model.GetUserData();
  NameController.text = map.Name;
  PhoneNumberController.text = map.PhoneNumber;
  OldPasswordController.text = '';
  NewPasswordController.text = '';
  ConfirmNewPasswordController.text = '';
  isAdmin = map.isAdmin;
}

Future<void> uploadImage(String ImageName) async {
  print('Indide Upload image methode' + PickeFileFromStorage.toString());
  if (_pickedFile != null) {
    print('indide if of upload image method');
    img.Image? originalImage = img.decodeImage(_pickedFile!.readAsBytesSync());

    if (originalImage != null) {
      img.Image resizedImage =
          img.copyResize(originalImage, width: 600, height: 600);
      List<int> compressedImageData = img.encodeJpg(resizedImage, quality: 80);

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
    downloadImageUrl = await reference.getDownloadURL();
    return await reference.getDownloadURL();
  } catch (e) {
    print(e.toString());
  }
}

Future UpdateData(BuildContext context) async {
  if (NameController.text != null && //Check For Fields
      NameController.text != '') {
    if (OldPasswordController.text != null &&
        OldPasswordController.text != '') {
      if (NewPasswordController.text != null &&
          NewPasswordController.text != '' &&
          ConfirmNewPasswordController.text != null &&
          ConfirmNewPasswordController.text != '' &&
          NewPasswordController.text == ConfirmNewPasswordController.text) {
        //If User wants to change password
        try {
          userInfo UserData = userInfo(
            Uid: user!.uid,
            Name: NameController.text,
            Email: user!.email.toString(),
            ProfileImageUrl: downloadImageUrl,
            PhoneNumber: PhoneNumberController.text.trim(),
            Password: ConfirmNewPasswordController.text.trim(),
            isAdmin: isAdmin,
          );

          try {
            AuthCredential credential = EmailAuthProvider.credential(
                email: user!.email!,
                password: OldPasswordController.text.trim());
            await user!
                .reauthenticateWithCredential(credential)
                .then((value) async {
              await uploadImage(user!.uid);
              await getImage();
              await auth.currentUser!
                  .updatePassword(NewPasswordController.text.trim());
              await _model.UpdateUserData(UserData).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    showCloseIcon: true,
                    content: Text('User Updated'),
                    duration: Duration(seconds: 4),
                  ),
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              });
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                showCloseIcon: true,
                content: Text('Old Password Incorrect'),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          print('Error Occured Stacke is : ' + e.toString());
        }
      } else {
        //if User don't want to change password
        try {
          userInfo UserData = userInfo(
              Uid: user!.uid,
              Name: NameController.text,
              Email: user!.email.toString(),
              ProfileImageUrl: downloadImageUrl,
              PhoneNumber: PhoneNumberController.text.trim(),
              Password: OldPasswordController.text.trim(),
              isAdmin: isAdmin);
          try {
            AuthCredential credential = EmailAuthProvider.credential(
                email: user!.email!,
                password: OldPasswordController.text.trim());
            await user!
                .reauthenticateWithCredential(credential)
                .then((value) async {
              await uploadImage(user!.uid);
              await getImage();
              await _model.UpdateUserData(UserData).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    showCloseIcon: true,
                    content: Text('User Updated'),
                    duration: Duration(seconds: 4),
                  ),
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              });
            });
          } catch (e) {
            print(e.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                showCloseIcon: true,
                content: Text('Old Password Incorrect  '),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          print('Error Occured Stacke is : ' + e.toString());
        }
      }
      //Code Login For Updating Data in Firebase and Firestore
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter Your Old Password to Confirm'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Name Required'),
        duration: Duration(seconds: 4),
      ),
    );
  }
}

class _EditProfileState extends State<EditProfile> {
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

  @override
  void initState() {
    isImageSelecting = false;
    GetCurrentData();
    StateChanging = true;
    super.initState();
    isLoading = false;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: TextWidget(
              text: 'Edit Profile',
              color: Colors.white,
              size: 25,
              letterSpacing: 0.4,
              fontWeight: FontWeight.bold),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Column(
              children: [
                isLoading == true ? LoadingWidget() : Container(),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                    onTap: () async {
                      setState(() {
                        _pickImage();
                        isImageSelecting = true;
                      });
                    },
                    child: isImageSelecting == false
                        ? FutureBuilder(
                            future: getImage(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Problem Occured');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return LoadingWidget();
                              }
                              if (snapshot.hasData &&
                                  snapshot.hasData != null) {
                                return CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  radius: 45,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      snapshot.data.toString(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              } else {
                                return Icon(Icons.person);
                              }
                            },
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 45,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _pickedFile != null
                                    ? Image.file(
                                        _pickedFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : Text('Selecting...')),
                          )),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: NameController,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: 'User Name',
                            label: Text('Name')),
                      ),
                      TextFormField(
                        controller: PhoneNumberController,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            hintText: 'Phone Number',
                            label: Text('Phone')),
                      ),
                      TextFormField(
                        controller: OldPasswordController,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Old Password',
                          label: Text('Old Password'),
                        ),
                        obscureText: true,
                      ),
                      TextFormField(
                        controller: NewPasswordController,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'New Password',
                          label: Text('New Password'),
                        ),
                        obscureText: true,
                      ),
                      TextFormField(
                        obscureText: true,
                        controller: ConfirmNewPasswordController,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'Confirm New Password',
                            label: Text('Confirm')),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                InkWell(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                        UpdateData(context).whenComplete(
                          () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                        );
                      });
                    },
                    child: ButtonWidget(text: 'Update', height: 60, size: 25)),
              ],
            ),
          ),
        ));
  }
}
