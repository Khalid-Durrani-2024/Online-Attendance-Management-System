import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/UserInfo.dart';
import '../Models/UserModel.dart';
import '../Widgets/TextFields.dart';
import '../Widgets/TextWidget.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // UserModel _model = UserModel();
  // User? CurrentUser = FirebaseAuth.instance.currentUser;
  // Future SavingDataFirestore() async {
  //   try {
  //     if (CurrentUser!.uid != null && CurrentUser!.uid != '') {
  //       final user = userInfo(
  //           Uid: CurrentUser!.uid,
  //           Name: 'Admin',
  //           Email: 'admin@gmail.com',
  //           ProfileImageUrl: 'wwww.pingImage.code');
  //       _model.StoreUserData(user);
  //     } else {
  //       print('Error getting User Id');
  //     }
  //   } catch (e) {
  //     print('Error ' + e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              AppBarStock(),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    TextFields(
                      text: Text('Name'),
                      hint: 'Enter Name',
                    ),
                    TextFields(
                      text: Text('F/Name'),
                      hint: 'Enter Father Name',
                    ),
                    TextFields(
                      text: Text('Department'),
                      hint: 'Enter Department',
                    ),
                    TextFields(
                      text: Text('Contact'),
                      hint: 'Enter Contact',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 130,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      //   SavingDataFirestore();
                    },
                    child: Text(
                      'Next',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarStock extends StatelessWidget {
  const AppBarStock({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('lib/Assets/photoEdited.png'),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 60),
              child: TextWidget(
                  color: Colors.white,
                  size: 25,
                  text: 'Profile',
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 1.5),
                  shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.transparent,
                child: CircleAvatar(
                  backgroundImage: AssetImage('lib/Assets/avatar.png'),
                  radius: 60,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
