import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sis_system/Models/HomePageMenus.dart';
import 'package:sis_system/Screens/AddStudentToClass.dart';
import 'package:sis_system/Screens/EditProfile.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

class SubjectScreen extends StatefulWidget {
  var UserUid;

  SubjectScreen({required this.UserUid});
  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

List Subjects = [];

class _SubjectScreenState extends State<SubjectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String SubjectName = '';
  String SubjectCode = '';
  int SubjectCredit = 1;
  SubjectModel model = SubjectModel();
  SubmitForm() async {
    final key = _formKey.currentState;

    if (key != null && key.validate()) {
      key.save();
      Subjects.add(model.AddSubjects(SubjectName, SubjectCode, SubjectCredit));
      print(Subjects);
      key.reset();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    model.GetSubjects(widget.UserUid).then((value) {
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
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              model.UploadSubjects(widget.UserUid)
                  .whenComplete(
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Subjects Added to Database'),
                        duration: Duration(seconds: 4),
                        showCloseIcon: true,
                      ),
                    ),
                  )
                  .then((value) => isLoading = false)
                  .then((value) => Navigator.pop(context));
            },
            icon: Icon(Icons.upload),
            tooltip: 'Upload Data',
          ),
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          'Subjects',
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
      body: isLoading == true
          ? Center(
              child: LoadingWidget(),
            )
          : FutureBuilder(
              future: model.GetSubjects(widget.UserUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingWidget(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error Try Again'),
                  );
                }

                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Subjects == [] && Subjects.isEmpty
                        ? Center(
                            child: LoadingWidget(),
                          )
                        : ListView.builder(
                            itemCount: Subjects.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => StudentScreen(
                                      SubjectName: Subjects[index]
                                          ['SubjectName'],
                                      SubjectCode: Subjects[index]
                                          ['SubjectCode'],
                                      UserUid: widget.UserUid,
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
                                        borderRadius:
                                            BorderRadius.circular(30.0),
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
                                      'Tap to Add Students to this class',
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
                          ));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.indigo,
            context: context,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Color(0xFF1E88E5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.1,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 25,
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      flex: 5,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.white),
                                  labelText: 'Subject Name'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a Subject Name';
                                }
                                return null;
                              },
                              onSaved: (value) => SubjectName = value ?? '',
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.white),
                                  labelText: 'Subject Code'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the Subject Code';
                                }
                                return null;
                              },
                              onSaved: (value) => SubjectCode = value ?? '',
                            ),
                            TextFormField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Colors.white),
                                    labelText: 'Subject Credits'),
                                validator: (value) {
                                  int IntegerValue;
                                  try {
                                    IntegerValue = int.parse(value.toString());
                                  } catch (e) {
                                    return 'Please Enter a valid Credit';
                                  }
                                },
                                onSaved: (newValue) {
                                  int credits;
                                  credits = int.parse(newValue.toString());
                                  try {
                                    SubjectCredit = credits;
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                }),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: SubmitForm,
                              child: Text('Add Subject'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        label: Text('Add Subject'),
        icon: Icon(Icons.add),
      ),
    );
  }
}

class SubjectModel {
  AddSubjects(String SubjectName, String SubjectCode, int SubjectCredit) {
    return {
      'SubjectName': SubjectName,
      'SubjectCode': SubjectCode,
      'SubjectCredit': SubjectCredit
    };
  }

  Future UploadSubjects(var UserUid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      if (Subjects != [] && Subjects != null) {
        await firestore
            .collection('Subjects')
            .doc(UserUid)
            .set({'Subjects': Subjects});
      } else {
        print('No Subject add');
      }
    } catch (e) {
      print('Exception Occured During Uploading Subjects' + e.toString());
    }
  }

  Future GetSubjects(var UserUid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot snapshot =
          await firestore.collection('Subjects').doc(UserUid).get();
      if (snapshot.exists) {
        Map map = snapshot.data() as Map<String, dynamic>;
        Subjects = map['Subjects'];
        print(Subjects);
      } else {
        return null;
      }
    } catch (e) {
      print('Error Occured During Getting Subjects from Firebase ' +
          e.toString());
    }
  }
}
