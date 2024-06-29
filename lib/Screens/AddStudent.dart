import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sis_system/Models/CustomExceptions.dart';
import 'package:sis_system/Screens/TestingPurpose.dart';

class UniversityStudent {
  String studentId = '';
  String firstName = '';
  String lastName = '';
  String gender = '';
  String email = '';
  String phone = '';
  String department = ''; // SE or IT
  int year = 0; // 4
}

class AddUniversityStudentScreen extends StatefulWidget {
  @override
  _AddUniversityStudentScreenState createState() =>
      _AddUniversityStudentScreenState();
}

class _AddUniversityStudentScreenState
    extends State<AddUniversityStudentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UniversityStudent _student = UniversityStudent();
  List<String> _departments = ['SE', 'IT'];
  List<String> _Gender = ['Male', 'Female'];
  List<int> _Semester = [1, 2, 3, 4,5,6,7,8];
  bool Exist = false;
  void _submitForm() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();

      if (await getStudentById() as bool == false) {
        AddStudentToDatabase()
            .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    showCloseIcon: true,
                    content: Text('Student Saved In Database'),
                    duration: Duration(seconds: 4),
                  ),
                ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            showCloseIcon: true,
            content: Text(
              'Student Already Exist With the Provided ID',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }

      form.reset();
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future AddStudentToDatabase() async {
    try {
      await _firestore.collection('Students').doc(_student.studentId).set({
        'StudentId': _student.studentId,
        'StudentDetails': {
          'FirstName': _student.firstName,
          'LastName': _student.lastName,
          'Gender': _student.gender,
          'Email': _student.email,
          'Phone': _student.phone,
          'Department': _student.department,
          'Year': _student.year,
        }
      });
    } on FirebaseNetworkException catch (e) {
      print('Network Problem : ' + e.toString());
    } catch (e) {
      print('Error Occured ' + e.toString());
    }
  }

//Search Id
  Future getStudentById() async {
    final CollectionReference _studentsCollection =
        FirebaseFirestore.instance.collection('Students');
    List<String> _studentIds = []; // Array to store student IDs
    String id = _student.studentId.trim();
    print(id);
    try {
      QuerySnapshot querySnapshot = await _studentsCollection.get();
      List<DocumentSnapshot> documents = querySnapshot.docs;

      for (var document in documents) {
        _studentIds.add(document.id);
        Map<String, dynamic> studentData =
            document.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting students: $e');
    }

    for (String i in _studentIds) {
      if (i == id) {
        Exist = true;
        print('Id Found of Student');
        break;
      } else {
        print('Not Found ');
        Exist = false;
      }
    }

    return Exist;
  }

  @override
  void initState() {
    super.initState();

    _student.department = _departments[0];
    _student.gender = _Gender[0];
    _student.year = _Semester[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(centerTitle: true, title: Text('Add Student')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Student ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a student ID';
                    }
                    return null;
                  },
                  onSaved: (value) => _student.studentId = value ?? '',
                ),
                SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a first name';
                    }
                    return null;
                  },
                  onSaved: (value) => _student.firstName = value ?? '',
                ),
                SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a last name';
                    }
                    return null;
                  },
                  onSaved: (value) => _student.lastName = value ?? '',
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  icon: Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  dropdownColor: Colors.indigo,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Gender'),
                  value: _student.gender,
                  items: _Gender.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _student.gender = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a Gender';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _student.email = value ?? '',
                ),
                SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                  onSaved: (value) => _student.phone = value ?? '',
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(30),
                  icon: Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.indigo,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Department'),
                  value: _student.department,
                  items: _departments.map((String department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _student.department = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a department';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  icon: Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  dropdownColor: Colors.indigo,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Semester'),
                  value: _student.year,
                  items: _Semester.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _student.year = value ?? 0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value == 0) {
                      return 'Please select a Semester';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Student'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
