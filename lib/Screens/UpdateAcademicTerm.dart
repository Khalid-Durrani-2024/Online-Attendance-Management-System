import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class UpdateSemesterScreen extends StatefulWidget {
  const UpdateSemesterScreen({super.key});

  @override
  State<UpdateSemesterScreen> createState() => _UpdateSemesterScreenState();
}

class _UpdateSemesterScreenState extends State<UpdateSemesterScreen> {
  bool isSwitch = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List UpdateStudents = [];
  @override
  void initState() {
    UpdateStudents = [];
    // TODO: implement initState
    super.initState();
  }

  Future UpdateSemester() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('Students').get();
      snapshot.docs.forEach((element) {
        Map map = element.data() as Map;
        print(map); //checking if changes made or not
        Map StudentDetails = map['StudentDetails'];
        int year = StudentDetails['Year'] + 1;
        StudentDetails['Year'] = year.toString();
        UpdateStudents.add({
          'StudentDetails': StudentDetails,
          'StudentId': map['StudentId'],
        });
      });
      print('After Changes');
      UpdateStudents.forEach(
        (element) {
          print(element);
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  ConfirmationDialogue() {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
            insetAnimationDuration: Duration(seconds: 2),
            backgroundColor: Colors.indigo,
            icon: Icon(
              Icons.sync_outlined,
              size: 50,
              color: Colors.yellow,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Update Academic Semester ',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to update to the next academic semester? This action will transfer all student data from the existing semester to the next semester. Please make sure before proceeding',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white)),
                onPressed: () {
                  UpdateSemester();
                },
                child: Text('Update'),
              )
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Semester'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
            color: Colors.blue.shade700, shape: BoxShape.rectangle),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Include Deprived Students',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.2,
                      fontSize: 18),
                ),
                Switch.adaptive(
                  activeColor: Colors.green,
                  value: isSwitch,
                  onChanged: (value) {
                    isSwitch = value;
                    setState(() {});
                  },
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Update Semester'),
        onPressed: () {
          ConfirmationDialogue();
        },
      ),
    );
  }
}
