import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sis_system/Widgets/CustomShape.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

class StudentScreen extends StatefulWidget {
  final SubjectName;
  final SubjectCode;
  var UserUid;
  StudentScreen(
      {required this.SubjectName,
      required this.SubjectCode,
      required this.UserUid});
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  int selectedYear = 1; // Default year
  String selectedDepartment = 'SE'; // Default department
  List myList = [];
  List AllStudents = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isWaiting = false;
  bool isExists = false;
  Future EditStudents() async {
    Map mymap = {};
    for (int i = 0; i < SelectedStudents.length; i++) {
      mymap = SelectedStudents[i];
      mymap['SubjectCode'] = widget.SubjectCode;
      mymap['SubjectName'] = widget.SubjectName;
      AllStudents.add(mymap);
    }
    mymap = {};
  }

  Future GetStudents() async {
    try {
      Map map = {};
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var result =
          await firestore.collection('Classes').doc(widget.UserUid).get();

      if (result.data() != null) {
        map = result.data() as Map;
        List myList = map['Students'];
        myList.forEach((element) {
          AllStudents.add(element);
        });
        map = {};
      }
    } catch (e) {
      print('Error Occured Stack is : ' + e.toString());
      return null;
    }
  }

  List<List<Map<String, dynamic>>> uniqueStudentsPerSubject = [];
  List FinalUniqueStudents = [];
  void FilterStudents() {
    Map<String, List<Map<String, dynamic>>> uniqueSubjects =
        {}; // Map to store unique subjects

    for (var map in AllStudents) {
      String subjectCode = map['SubjectCode'];
      String subjectName = map['SubjectName'];
      String subjectKey = '$subjectCode-$subjectName';

      if (!uniqueSubjects.containsKey(subjectKey)) {
        uniqueSubjects[subjectKey] = [];
      }

      // Check if the student is not already in the subject list
      bool isDuplicateStudent = uniqueSubjects[subjectKey]!
          .any((student) => student['id'] == map['id']);

      if (!isDuplicateStudent) {
        uniqueSubjects[subjectKey]!.add(map);
      }
    }

    // Create a list of unique students for each subject
    uniqueSubjects.forEach((subjectKey, students) {
      uniqueStudentsPerSubject.add(students);
    });

    // Print the list of unique students for each subject
    uniqueStudentsPerSubject.forEach((students) {
      students.forEach((student) {
        FinalUniqueStudents.add(student);
      });
    });
  }

  Future AddStudentsToDatabase() async {
    try {
      setState(() {
        isWaiting = true;
      });
      await await EditStudents();
      FilterStudents();
      await firestore
          .collection('Classes')
          .doc(widget.UserUid)
          .set({
            'Students': FinalUniqueStudents,
          })
          .whenComplete(
            () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Students Added Successfully to The Class '),
                duration: Duration(seconds: 4),
                showCloseIcon: true,
              ),
            ),
          )
          .then((value) {
            setState(() {
              isWaiting = false;
              SelectedStudents = [];
              Navigator.pop(context);
            });
          });
    } catch (e) {
      setState(() {
        isWaiting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error During saving Data ' + e.toString()),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetStudents();

    AllStudents = [];
  }

  @override
  void dispose() {
    AllStudents = [];
    uniqueStudentsPerSubject = [];
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: Text('All Students'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          isWaiting == true ? LoadingWidget() : Container(),
          Flexible(child: StudentList(selectedYear, selectedDepartment)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddStudentsToDatabase();
          //   GetStudents();
        },
        icon: Icon(Icons.add),
        label: Text('Add Students'),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 3,
          shape: CustomAlertDialogShape(radiuos: 30),
          backgroundColor: Colors.indigo,
          title: Text(
            'Filter Students',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                dropdownColor: Colors.indigo,
                value: selectedYear,
                style: TextStyle(color: Colors.white),
                onChanged: (newValue) {
                  setState(() {
                    selectedYear = newValue!;
                  });
                },
                items: [1, 2, 3, 4, 5, 6, 7, 8]
                    .map((year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text(
                            'Semester $year',
                            style: TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                dropdownColor: Colors.indigo,
                value: selectedDepartment,
                style: TextStyle(color: Colors.white),
                onChanged: (newValue) {
                  setState(() {
                    selectedDepartment = newValue!;
                  });
                },
                items: ['SE', 'IT'] // Replace with your departments
                    .map((dept) => DropdownMenuItem<String>(
                          value: dept,
                          child: Text('Department: $dept'),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

List SelectedStudents = [];

class StudentList extends StatefulWidget {
  final int selectedYear;
  final String selectedDepartment;
  Set<String> markedStudents = Set<String>();
  StudentList(this.selectedYear, this.selectedDepartment);

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Students').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LoadingWidget());
        }
        final students;
        if (snapshot.hasData) {
          students = snapshot.data?.docs;
        } else {
          return LoadingWidget();
        }
        final filteredStudents = students!.where((student) {
          final studentData = student['StudentDetails'] as Map<String, dynamic>;

          final studentYear = studentData['Year'] ?? 1;

          final studentDepartment = studentData['Department'] ?? 'SE';
          return studentYear.toString() == widget.selectedYear.toString() &&
              studentDepartment == widget.selectedDepartment;
        }).toList();

        return ListView.builder(
          itemCount: filteredStudents.length,
          itemBuilder: (context, index) {
            final studentData = filteredStudents[index]['StudentDetails']
                as Map<String, dynamic>;
            final student = StudentModel.fromMap(studentData);
            final isMarked =
                widget.markedStudents.contains(filteredStudents[index].id);

            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  student.FirstName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${student.Department} - Semester ${student.Year}'),
                trailing: Checkbox(
                  value: widget.markedStudents
                      .contains(filteredStudents[index].id),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        Map student = studentData as Map;

                        SelectedStudents.add({
                          'id': filteredStudents[index].id,
                          'StudentDetails': student
                        });

                        widget.markedStudents.add(filteredStudents[index].id);
                      } else {
                        SelectedStudents.removeWhere(
                          (element) =>
                              element['id'] == filteredStudents[index].id,
                        );

                        widget.markedStudents
                            .remove(filteredStudents[index].id);
                      }
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class StudentModel {
  final String Department;
  final String Email;
  final String FirstName;
  final String Gender;
  final String LastName;
  final String Phone;
  final int Year;
  StudentModel({
    required this.Department,
    required this.Email,
    required this.FirstName,
    required this.Gender,
    required this.LastName,
    required this.Phone,
    required this.Year,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
        Department: map['Department'],
        Email: map['Email'],
        FirstName: map['FirstName'],
        Gender: map['Gender'],
        LastName: map['LastName'],
        Phone: map['Phone'],
        Year: map['Year']);
  }
}
