import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sis_system/Models/UserInfo.dart';
import 'package:sis_system/Screens/AddSubjectToUser.dart';
import 'package:sis_system/Screens/AttendanceReport.dart';
import 'package:sis_system/Screens/BasicInfoScreen.dart';
import 'package:sis_system/Screens/EditProfile.dart';
import 'package:sis_system/Screens/HelpAndSupport.dart';
import 'package:sis_system/Screens/NotificationScreen.dart';
import 'package:sis_system/Screens/ProfileScreen.dart';
import 'package:sis_system/Screens/SignIn.dart';
import 'package:sis_system/Screens/Subjects.dart';
import 'package:sis_system/Screens/TakeAttendance.dart';
import 'package:sis_system/Screens/UpdateAcademicTerm.dart';
import 'package:sis_system/Widgets/BarCharSample2.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';
import 'package:http/http.dart' as http;
import '../Models/HomePageMenus.dart';
import '../Models/UserModel.dart';
import '../Widgets/ButtonWidget.dart';
import '../Widgets/TextWidget.dart';
import 'AddStudent.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

var UserData;

class _HomePageState extends State<HomePage> {
  UserModel _model = UserModel();
  @override
  void initState() {
    setState(() {
      setState(() {
        _model.GetUserData();
        _model = UserModel();
        GetTeacherOrAdmin();
      });
      super.initState();
    });
  }

  GetTeacherOrAdmin() async {
    try {
      FirebaseFirestore firestore = await FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      Map map = snapshot.data() as Map;
      setState(() {
        isTeacher = map['isAdmin'];
      });
    } catch (e) {
      setState(() {
        isTeacher = false;
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    _showConfirmationDialog(BuildContext context) async {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(
              Icons.logout,
              size: 50,
              color: Colors.white,
            ),
            backgroundColor: Colors.indigo,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Log Out',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are You Sure Log Out?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              BasicDialogAction(
                title: Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  isTeacher = false;
                  await _model.SignOut(context);
                },
              ),
              BasicDialogAction(
                title: Text('No', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      );
    }

    void NavigatingNextScreen(int index) async {
      switch (myList[index]) {
        case 'Add Student':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddUniversityStudentScreen(),
          ));
        case 'Take Attendance':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TakeAttendance(),
          ));
        case 'Edit Profile':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditProfile(),
          ));
          break;
        case 'Teachers':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddSubjectToUser(),
          ));
          break;
        case 'Notification & Remainder':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NotificationScreen(),
          ));
          break;

        case 'Attendance Report':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AttendanceReport(),
          ));
          break;

        case 'Help & Support':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HelpAndSupport(),
          ));
          break;
        case 'Update Academic Term':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UpdateSemesterScreen(),
          ));
          break;
        case 'Log Out':
          setState(() {
            _showConfirmationDialog(context);
          });
          break;
      }
    }
    //End of the Admin Panel Navigating

    void NavigatingTeacherNextScreen(int index) async {
      switch (TeachersDataList[index]) {
        case 'Take Attendance':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TakeAttendance(),
          ));
        case 'Edit Profile':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditProfile(),
          ));
          break;
        case 'Notification & Remainder':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NotificationScreen(),
          ));
          break;

        case 'Attendance Report':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AttendanceReport(),
          ));
          break;

        case 'Help & Support':
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HelpAndSupport(),
          ));
          break;
        case 'Log Out':
          setState(() {
            _showConfirmationDialog(context);
          });
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //       onPressed: () {}, icon: Icon(Icons.keyboard_option_key_sharp))
        // ],
      ),
      // drawer: Drawer(),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            image: DecorationImage(
              image: AssetImage('lib/Assets/HomePageBackground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
              ),
              Container(
                height: 230,
                width: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    opacity: 0.8,
                    image: AssetImage('lib/Assets/IndigoColor.png'),
                  ),
                ),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: _model.GetUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Problem Occured');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {}
                        if (snapshot.hasData && snapshot.hasData != null) {
                          userInfo user = snapshot.data;
                          var imageData;
                          print(isTeacher);
                          try {
                            imageData = user.ProfileImageUrl;
                          } on FormatException catch (e) {
                            imageData = '';
                          }

                          return Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 45,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: imageData == ''
                                        ? Icon(
                                            Icons.person,
                                            size: 80,
                                          )
                                        : Image.network(
                                            scale: 1.0,
                                            user.ProfileImageUrl,
                                            fit: BoxFit.cover,
                                          )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                user.Name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return LoadingWidget();
                        }
                      },
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BasicInfoScreen(),
                            ));
                          },
                          child: ButtonWidget(
                            radius: 8,
                            text: 'Basic Info',
                            fontWeight: FontWeight.normal,
                            width: 100,
                            height: 30,
                            size: 17,
                            letterSpacing: 0.0,
                            bgColor: Colors.transparent,
                            brColor: Colors.redAccent,
                          ),
                        ),
                        ButtonWidget(
                          radius: 8,
                          letterSpacing: 0.0,
                          text: DateTime.now().toString().substring(0, 10),
                          fontWeight: FontWeight.normal,
                          width: 100,
                          height: 30,
                          size: 17,
                          bgColor: Colors.red,
                          brColor: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              isTeacher == true
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      height: h / 2,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: myList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              NavigatingNextScreen(index);
                            },
                            child: Card(
                              elevation: 5,
                              shadowColor: Colors.indigo,
                              child: ListTile(
                                leading: Icon(
                                  icons[index],
                                  color: Colors.green,
                                ),
                                title: Text(
                                  myList[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  //End of the Admin Panel
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      height: h / 2,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: TeachersDataList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              NavigatingTeacherNextScreen(index);
                            },
                            child: Card(
                              elevation: 5,
                              shadowColor: Colors.indigo,
                              child: ListTile(
                                leading: Icon(
                                  TeachersIcons[index],
                                  color: Colors.green,
                                ),
                                title: Text(
                                  TeachersDataList[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

              //End of the Teacher Panel
            ],
          ),
        ),
      ),
    );
  }
}
