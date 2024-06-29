import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sis_system/Authentication/Wrapper.dart';
import 'package:sis_system/Screens/SignIn.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

class WaitingVerificationScreen extends StatefulWidget {
  @override
  State<WaitingVerificationScreen> createState() =>
      _WaitingVerificationScreenState();
}

class _WaitingVerificationScreenState extends State<WaitingVerificationScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  bool isLoading = false;

  Future ResendVerificationEmail() async {
    try {
      User? user = auth.currentUser;

      await user!.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  void restartApp() {
    if (Platform.isAndroid) {
      // For Android, use the following method to restart the app
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      // For iOS, use the following method to restart the app
      exit(0);
    } else {
      // For web or other platforms, you may implement a different behavior
      // or display a message indicating that app restart is not supported.
      // You can also trigger a hot reload if you are in a development environment.
      // For example:
      // if (kDebugMode) {
      //   runApp(MyApp());
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Email Verification'),
       
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.email,
              size: 100.0,
              color: Colors.blue,
            ),
            SizedBox(height: 20.0),
            Text(
              'Waiting for Email Verification',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Please check your email and click on the verification link. After Verifying ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            TextButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ));
            }, child: Text('Click Here')),
            SizedBox(height: 30.0),
            isLoading == true ? LoadingWidget() : Container(),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                ResendVerificationEmail().whenComplete(
                  () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AboutDialog(
                          applicationName: 'From Attendance Management System',
                          applicationIcon: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 30,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                'lib/Assets/appIcon.png',
                              ),
                            ),
                          ),
                          applicationVersion: '1.0',
                          children: [
                            Text(
                                'Email Verification Has Been Sent to Your Gmail ${auth.currentUser!.email}'),
                          ],
                        );
                      },
                    );
                    setState(() {
                      isLoading = false;
                    });
                  },
                );
              },
              child: Text('Resend Verification Email'),
            ),
            
          ],
        ),
      ),
    );
  }
}
