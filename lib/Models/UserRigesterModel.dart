import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'CustomExceptions.dart';

class UserRigesterModel {
  bool isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  File? image;
  Future CreatingUser(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Created Successfully'),
          duration: Duration(seconds: 4),
        ),
      );
      return userCredential;
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        isLoading = false;

        throw FirebaseNetworkException(
          code: 'network-request-failed',
          message:
              'A network error has occurred. Please check your internet connection and try again.',
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email Already In Use try a different email address',
            ),
            showCloseIcon: true,
            duration: Duration(seconds: 4),
          ),
        );

        isLoading = false;
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid Email Address check your email and try again',
            ),
            showCloseIcon: true,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
            duration: const Duration(seconds: 4),
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
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> StoreUserData(BuildContext context) async {}
}
