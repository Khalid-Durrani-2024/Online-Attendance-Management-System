
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sis_system/Screens/HomePage.dart';
import 'package:sis_system/Screens/ProfileScreen.dart';
import 'package:sis_system/Screens/SplashScreen.dart';
import 'package:sis_system/Screens/WaitingVerificationScreen.dart';

import '../Screens/SignIn.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return SignInScreen();
          }
          if (user != null && user.emailVerified) {
            return HomePage();
          } else {
            return WaitingVerificationScreen();
          }
        } else {
          // Handle loading state
          return SplashScreen();
        }
      },
    );
  }
}
