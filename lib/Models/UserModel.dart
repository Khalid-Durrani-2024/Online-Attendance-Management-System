import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sis_system/Models/LocalImageFile.dart';
import 'package:sis_system/Screens/SignIn.dart';
import 'package:sis_system/Widgets/LocalImageFile.dart';
import 'CustomExceptions.dart';
import 'UserInfo.dart';

class UserModel {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//    FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  File? file;
  String downloadUrl = '';
  Future<User?> SecondSignInMethod(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw FirebaseNetworkException(
          code: 'network-request-failed',
          message:
              'A network error has occurred. Please check your internet connection and try again.',
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Wrong Password Entered'),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid Email Rigester Your Email First'),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ));
      } else if (e.code == 'user-disabled') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'The User is Temporarily Disabled Try a few minutes later or reset your password'),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ));
      } else if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User Not Found With The Provided Email and Password'),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ));
      } else if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Too Many Requests try again Later'),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Error Occured During Sign In Contact With Admin for Additional Info'),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error Occured During Sign In Contact with the admin: ' +
            e.toString()),
        duration: const Duration(seconds: 4),
        showCloseIcon: true,
      ));
    }
  }

  Future<User?> SignUpMethod(String name, String email, String password,
      bool isAdmin, String phonenumber, BuildContext context) async {
    try {
      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        await uploadImage(userCredential.user!.uid.toString());
        await getImage();
        userInfo user = userInfo(
          Uid: userCredential.user!.uid,
          Name: name,
          Email: email,
          ProfileImageUrl: downloadUrl,
          PhoneNumber: phonenumber,
          Password: password,
          isAdmin: isAdmin,
        );

        await StoreUserData(user);

        Navigator.pushReplacementNamed(context, '/HomePage');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw FirebaseNetworkException(
          code: 'network-request-failed',
          message:
              'A network error has occurred. Please check your internet connection and try again.',
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email Already In Use try a different email address',
            ),
            showCloseIcon: true,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid Email Address check your email and try again',
            ),
            showCloseIcon: true,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password Weak Try a Strong Password that greater than 6 digits',
            ),
            showCloseIcon: true,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error Occured During Sign Up ' + e.code,
            ),
            showCloseIcon: true,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Problem During Sign Up ' + e.toString(),
          ),
          showCloseIcon: true,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<User?> SignOut(BuildContext context) async {
    await auth
        .signOut()
        .whenComplete(() => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignInScreen(),
            )));
  }

  Future<void> StoreUserData(userInfo user) async {
    try {
      _firestore.collection('Users').doc(user.Uid).set({
        'Name': user.Name,
        'Email': user.Email,
        'ProfileImageUrl': user.ProfileImageUrl
      });
    } catch (e) {
      print('Error Occured During Saving Data to Firestore' + e.toString());
    }
  }

  Future<void> uploadImage(String ImageName) async {
    print('Indide Upload image methode' + PickeFileFromStorage.toString());
    if (PickeFileFromStorage != null) {
      print('indide if of upload image method');
      img.Image? originalImage =
          img.decodeImage(PickeFileFromStorage!.readAsBytesSync());

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
      print(await reference.getDownloadURL());

      return await reference.getDownloadURL();
    } catch (e) {
      print(e.toString());
    }
  }

  Future GetUserData() async {
    User? user = auth.currentUser;
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('Users').doc(user!.uid).get();
      if (snapshot.exists) {
        Map dataUser = snapshot.data() as Map;
        return userInfo.fromMap(dataUser);
      }
    } catch (e) {
      print('error in getting data' + e.toString());
    }
  }

  //Edit Profile Screen Activity

  Future UpdateUserData(userInfo info) async {
    User? user = auth.currentUser;
    try {
      if (user != null) {
        await _firestore.collection('Users/').doc(user.uid).update({
          'Uid': info.Uid ?? '',
          'Name': info.Name ?? '',
          'Email': info.Email ?? '',
          'ProfileImageUrl': info.ProfileImageUrl ?? '',
          'PhoneNumber': info.PhoneNumber ?? '',
          'Password': info.Password ?? '',
        });
      } else {
        return null;
      }
    } catch (e) {
      print('Error In Getting Current User Data' + e.toString());
    }
  }
}
