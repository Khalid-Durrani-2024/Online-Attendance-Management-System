import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sis_system/Screens/EditProfile.dart';
import 'package:sis_system/Screens/NestedTakeAttendance.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

class TakeAttendance extends StatefulWidget {
  const TakeAttendance({super.key});

  @override
  State<TakeAttendance> createState() => _TakeAttendanceState();
}

List Subjects = [];

class _TakeAttendanceState extends State<TakeAttendance> {
  String SubjectName = '';
  String SubjectCode = '';
  SubjectModel model = SubjectModel();

  @override
  void initState() {
    model.GetSubjects().whenComplete(() {
      setState(() {});
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    Subjects = [];
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Take Attendance',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.indigo,
        ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: FutureBuilder(
              future: model.GetSubjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return LoadingWidget();

                snapshot.hasError
                    ? Center(
                        child: Text('Error Getting Data From Database'),
                      )
                    : Container();
                return ListView.builder(
                  itemCount: Subjects.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AttendanceScreen(
                              SubjectCode: Subjects[index]['SubjectCode'],
                              SubjectName: Subjects[index]['SubjectName'],
                              SubjectCredits: Subjects[index]['SubjectCredit'],
                              ),
                        ));
                      },
                      child: Card(
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 24),
                          leading: Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Center(
                              child: Text(
                                Subjects[index]['SubjectCode'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            Subjects[index]['SubjectName'],
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          subtitle: Text(
                            'Tap to Take Attendance',
                            style: TextStyle(
                              color: Color(0xFF555555),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward,
                            size: 32.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )));
  }
}

class SubjectModel {
  Future GetSubjects() async {
    User? user = auth.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot snapshot =
        await firestore.collection('Subjects').doc(user!.uid).get();
    if (snapshot.exists) {
      Map map = snapshot.data() as Map<String, dynamic>;
      Subjects = map['Subjects'];
      print(Subjects);
    } else {
      return null;
    }
  }
}
