import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sis_system/Models/UserInfo.dart';
import 'package:sis_system/Models/UserModel.dart';
import 'package:sis_system/Widgets/CustomShape.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

//  name: snapshot.Name,
//                               email: snapshot.Email,
//                               phoneNumber: snapshot.PhoneNumber,
//                               ProfileImageUrl: snapshot.ProfileImageUrl,
//                               AccountType: snapshot.isAdmin == false
//                                   ? 'Teacher'
//                                   : 'Admin',
class BasicInfoScreen extends StatefulWidget {
  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  UserModel _infoModel = UserModel();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _infoModel = UserModel();
      _infoModel.GetUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Basic Information'),
      ),
      body: FutureBuilder(
        future: _infoModel.GetUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            LoadingWidget();
          }
          if (snapshot.hasError) {
            Center(
              child: Text(
                'No Data Recived',
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
            );
          }
          if (snapshot.hasData && snapshot.hasData != null) {
            userInfo info = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Hero(
                    tag: 'profile_image',
                    child: _buildProfileImage(info.ProfileImageUrl),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.indigo,
                        elevation: 5.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildAnimatedText(
                              icon: Icons.person_outline_outlined,
                              title: 'Name:',
                              subtitle: info.Name,
                            ),
                            Divider(
                              color: Colors.white,
                              indent: 10,
                              endIndent: 10,
                            ),
                            _buildAnimatedText(
                              icon: Icons.email_outlined,
                              title: 'Email:',
                              subtitle: info.Email,
                            ),
                            Divider(
                              color: Colors.white,
                              indent: 10,
                              endIndent: 10,
                            ),
                            _buildAnimatedText(
                              icon: Icons.phone_outlined,
                              title: 'Phone Number:',
                              subtitle: info.PhoneNumber,
                            ),
                            Divider(
                              color: Colors.white,
                              indent: 10,
                              endIndent: 10,
                            ),
                            _buildAnimatedText(
                              icon: Icons.account_box_outlined,
                              title: 'Account Type:',
                              subtitle: info.isAdmin.toString() == 'true'
                                  ? 'Admin'
                                  : 'Teacher',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return LoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildProfileImage(String url) {
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      radius: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child:Image.network(
            url,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child; // Image is fully loaded.
              } else {
                return CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                );
              }
            }
        )
        
      ),
    );
  }

  Widget _buildAnimatedText({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: 1.0,
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }
}
