// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sis_system/Models/AttendanceReportModel.dart';
import 'package:excel/excel.dart' as excel_package;
import 'package:path_provider/path_provider.dart';
import 'package:sis_system/Screens/HomePage.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

import '../Widgets/ButtonWidget.dart';
import '../Widgets/TextWidget.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

DateTime? dateTime = DateTime(2023, 9, 31);
String marked = '';
String Enrolled = '';
List Students = [];
List StudentDetails = [];
bool IsLoading = false;
List Subjects = [];
String SelectedSubject = Subjects[0];

class _AttendanceReportState extends State<AttendanceReport> {
  getDate() async {
    try {
      dateTime = await showDatePicker(
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(2022, 9, 1),
          lastDate: DateTime(2030, 1, 1));
    } catch (e) {
      print(e.toString());
    }
  }

  GetSubjects() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot result = await firestore
          .collection('Subjects')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      Map map = result.data() as Map;
      List myList = map['Subjects'];
      myList.forEach((element) {
        Subjects.add(element['SubjectName']);
      });
    } catch (e) {
      print('Error Getting Subjects');
    }
  }

  SubjectsDialogue() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
              insetAnimationDuration: Duration(seconds: 2),
              backgroundColor: Colors.indigo,
              icon: Icon(
                Icons.question_mark_outlined,
                size: 50,
                color: Colors.yellow,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Select a Subject ',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Please Select a Subject From the List',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                DropdownButton<String>(
                  borderRadius: BorderRadius.circular(30),
                  icon: Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.indigo,
                  style: TextStyle(color: Colors.white),
                  hint: Text(
                      'Select Subject'), // Displayed when no item is selected
                  value: SelectedSubject,
                  onChanged: (newValue) {
                    setState(() {
                      SelectedSubject = newValue!;
                      Navigator.pop(context);
                      SubjectsDialogue();
                    });
                  },
                  items: Subjects.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        '${value}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 10,
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white), // Border color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      getStudents();
                      setState(() {});
                      Navigator.pop(context);
                    });
                  },
                  child: Text(
                    'Ok',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ]);
        });
  }

  getStudents() async {
    int smarked = 0;

    AttendanceReportModel model = AttendanceReportModel();
    await model.GetStudentsWithTheDateTime(
        dateTime.toString(), Students, SelectedSubject);
    for (int i = 0; i < Students.length; i++) {
      StudentDetails.add(Students[i]['StudentDetails']);
    }
    for (int i = 0; i < StudentDetails.length; i++) {
      if (StudentDetails[i]['IsPresent'] == true) {
        smarked++;
      }
    }

    setState(() {
      marked = smarked.toString();
      Enrolled = Students.length.toString();
    });
  }

  Future<void> generateExcelReport() async {
    setState(() {
      IsLoading = true;
    });
    if (Students.isEmpty && StudentDetails.isEmpty) {
      setState(() {
        IsLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please Select a Date First'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        showCloseIcon: true,
      ));
    } else {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          final excel = excel_package.Excel.createExcel();
          final sheet = excel['Sheet1'];

          // Add headers
          sheet.appendRow([
            'Subject Name',
            'Subject Code',
            'ID',
            'Name ',
            'Email',
            'Phone',
            'Gender',
            'Year',
            'Attendance',
            'Date'
          ]);

          Students.forEach((element) {
            Map StdDetail = element['StudentDetails'];

            final row = sheet.appendRow([
              element['SubjectName'],
              element['SubjectCode'],
              element['id'],
              StdDetail['FirstName'] + ' ' + StdDetail['LastName'],
              StdDetail['Email'],
              StdDetail['Phone'],
              StdDetail['Gender'],
              StdDetail['Year'],
              StdDetail['IsPresent'] == true ? 'Present' : 'Absent',
              StdDetail['DateTime']
            ]);
          });

          final directory = await getExternalStorageDirectory();
          final mainInternalStorageDirectory = Directory('${directory!.path}');

          // Create the directory if it doesn't exist
          final Reports =
              Directory('${mainInternalStorageDirectory.path}/my_directory');

          if (!(await Reports.exists())) {
            await Reports.create(recursive: true);
          }
          final filePath =
              '${Reports.path}/' + DateTime.now().toString() + '.xlsx';
          File(filePath).writeAsBytesSync(excel.encode()!);
          setState(() {
            IsLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report Generated Sucessfully')));
          });
        } catch (e) {
          print('Error Occured ' + e.toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission Denied'),
            duration: Duration(seconds: 4),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    getStudents();
    GetSubjects();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Students = [];
    StudentDetails = [];
    Subjects = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: TextWidget(
          fontWeight: FontWeight.bold,
          text: 'Attendance Report',
          size: 22,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
      body: Container(
        child: Column(
          children: [
            IsLoading == true ? LoadingWidget() : Container(),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextWidget(
                  color: Colors.white,
                  size: 18,
                  text: 'Daily Attendance Report',
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  TextWidget(
                      color: Colors.white,
                      size: 18,
                      text: 'Select Date',
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.0),
                  SizedBox(
                    width: 40,
                  ),
                  InkWell(
                    onTap: () async {
                      await getDate();
                      await SubjectsDialogue();

                      Students = [];
                      StudentDetails = [];
                    },
                    child: ButtonWidget(
                      bgColor: Colors.indigo,
                      width: 200,
                      height: 30,
                      brColor: Colors.transparent,
                      text: dateTime != null
                          ? dateTime.toString().substring(0, 16)
                          : DateTime.now().toString().substring(0, 16),
                      fontWeight: FontWeight.normal,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 116,
                  width: 154,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextWidget(
                          color: Colors.white,
                          size: 24,
                          text: 'Marked',
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.0),
                      TextWidget(
                          color: Colors.white,
                          size: 24,
                          text: marked,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.0),
                    ],
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 116,
                  width: 154,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextWidget(
                          color: Colors.white,
                          size: 24,
                          text: 'Enrolled',
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.0),
                      TextWidget(
                          color: Colors.white,
                          size: 24,
                          text: Enrolled,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.0),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: TextWidget(
                  color: Colors.white,
                  size: 18,
                  text: 'Attendance List',
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.0),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                      color: Colors.white,
                      size: 17,
                      text: 'ID',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.0),
                  TextWidget(
                      color: Colors.white,
                      size: 17,
                      text: 'Name',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.0),
                  TextWidget(
                      color: Colors.white,
                      size: 17,
                      text: 'Class',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.0),
                  TextWidget(
                      color: Colors.white,
                      size: 17,
                      text: 'Status',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.0),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Students.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                            color: Colors.white,
                            size: 17,
                            text: Students[index]['id'],
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.0),
                        TextWidget(
                            color: Colors.white,
                            size: 17,
                            text: StudentDetails[index]['FirstName'],
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.0),
                        TextWidget(
                            color: Colors.white,
                            size: 17,
                            text: Students[index]['SubjectName'],
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.0),
                        TextWidget(
                            color: Colors.white,
                            size: 17,
                            text: StudentDetails[index]['IsPresent'] == true
                                ? 'Present'
                                : 'Absent',
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.0),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Generate Report'),
        onPressed: () {
          generateExcelReport().then((value) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              )));
        },
        icon: Icon(Icons.print_rounded),
      ),
    );
  }
}
