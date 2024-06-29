import 'package:flutter/material.dart';
import 'package:sis_system/Authentication/Wrapper.dart';
import 'package:sis_system/Screens/SignIn.dart';
import '../Widgets/ButtonWidget.dart';
import '../Widgets/TextWidget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown, Colors.black54],
            end: Alignment.bottomRight,
            begin: Alignment.topLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: TextWidget(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                text:
                    'Welcome to Attendance Management System \n this system is special developed for Kunar Said Jamaluddin Afghan University \n Let"s Start from here',
                letterSpacing: 0.2,
                size: 22,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AuthWrapper(),
                  ));
                },
                child: ButtonWidget(
                  text: 'Get Started',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
