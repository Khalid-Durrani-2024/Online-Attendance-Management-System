import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sis_system/Authentication/Wrapper.dart';
import 'package:sis_system/Screens/AddStudentToClass.dart';
import 'package:sis_system/Screens/EditProfile.dart';
import 'package:sis_system/Screens/HelpAndSupport.dart';
import 'package:sis_system/Screens/HomePage.dart';
import 'package:sis_system/Screens/PasswordReset.dart';
import 'package:sis_system/Screens/ProfileScreen.dart';
import 'package:sis_system/Screens/SignIn.dart';
import 'package:sis_system/Screens/SignUp.dart';
import 'package:sis_system/Screens/SplashScreen.dart';
import 'package:sis_system/Screens/Subjects.dart';
import 'package:sis_system/Screens/TakeAttendance.dart';
import 'package:sis_system/Screens/TestingPurpose.dart';
import 'package:sis_system/Widgets/BarCharSample2.dart';
import 'package:sis_system/firebase_options.dart';

import 'Screens/AttendanceReport.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const MyApp());
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        '/ProfileScreen': ((context) => ProfileScreen()),
        '/TakeAttendance': ((context) => TakeAttendance()),
        '/HomePage': ((context) => HomePage()),
      },
    );
  }
}
