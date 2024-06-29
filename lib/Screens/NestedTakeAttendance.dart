import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sis_system/Screens/EditProfile.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

class AttendanceScreen extends StatefulWidget {
  String SubjectCode;
  String SubjectName;
  int SubjectCredits;
  AttendanceScreen(
      {required this.SubjectCode,
      required this.SubjectName,
      required this.SubjectCredits});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List StudentsOfTheCurrentSubject = [];
  List StudentDetailsOfTheCurrentSubject = [];
  List<bool> isExists = [];
  bool IsLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List AttendanceValidation = [];
  List temAttend = [];
  bool DisableEnable = false;
  int selectedOption = 1;
  List<int> CreditsCountsRemaining = [];
  ValidationId() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot ExistsOrNot = await firestore
          .collection('AttendanceCreditValidation')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!ExistsOrNot.exists) {
        await firestore
            .collection('AttendanceCreditValidation')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({});
      } else {
        print('Do nothing');
      }
    } catch (e) {
      print(
          'Exception Occured getting id from credit validation' + e.toString());
    }
  }

  CreditCounts() {
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Credits Remaining ' + CreditsCountsRemaining.length.toString(),
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'The Subject ${widget.SubjectName} has ${widget.SubjectCredits} Credits how much attendance you want to take',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              DropdownButton<int>(
                borderRadius: BorderRadius.circular(30),
                icon: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  color: Colors.white,
                ),
                dropdownColor: Colors.indigo,
                style: TextStyle(color: Colors.white),
                hint: Text(
                    'Select a Credit'), // Displayed when no item is selected
                value: selectedOption,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedOption = newValue!;
                    Navigator.pop(context);
                    CreditCounts();
                  });
                },
                items: CreditsCountsRemaining.map<DropdownMenuItem<int>>(
                    (int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      'Credits ${value}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 10,
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white), // Border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: () {
                  print(selectedOption);
                  if (selectedOption == 1) {
                    Navigator.pop(context);
                    AttendanceRecord();
                    CheckAttendanceValidation();
                  } else if (selectedOption == 2) {
                    Navigator.pop(context);
                    AttendanceRecord();
                    CheckAttendanceValidation();
                    AttendanceRecord();
                    CheckAttendanceValidation();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('You Can Only Take 2 Times attendance in a Day'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                      showCloseIcon: true,
                    ));
                    Navigator.pop(context);
                  }
                  ;

                  child:
                  Text(
                    'Take',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
                icon: Icon(
                  Icons.done,
                  color: Colors.green,
                ),
                label: Text(
                  'Take',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ]);
      },
    );
  }

  Future CheckCounts() async {
    List CurrentSubjects = [];
    Map firstMap = {};
    int counts = 0;
    List filter = [];
    //Step 1 getting data and differentiate date and time
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('AttendanceCreditValidation')
          .doc(user!.uid)
          .get();
      Map map = snapshot.data() as Map;
      if (map['AttendanceValidation'] != null && map != {}) {
        List myList = map['AttendanceValidation'];
        if (myList.length > 0) {
          myList.forEach((element) {
            try {
              Map map = element[widget.SubjectCode];
              CurrentSubjects.add(map);
            } catch (e) {
              DisableEnable = true;
            }
          });
          counts = CurrentSubjects
              .length; //the Length of the current subject which times is taken
          int remain = widget.SubjectCredits -
              counts; //this varibale is used to initialize the list for take attendance
          if (remain == 1) {
            CreditsCountsRemaining = [1];
          } else if (remain == 2) {
            CreditsCountsRemaining = [1, 2];
          } else if (remain == 3) {
            CreditsCountsRemaining = [1, 2, 3];
          } else if (remain == 4) {
            CreditsCountsRemaining = [1, 2, 3, 4];
          } else if (remain == 5) {
            CreditsCountsRemaining = [1, 2, 3, 4, 5];
          } else {
            if (widget.SubjectCredits == 1) {
              CreditsCountsRemaining = [1];
            } else if (widget.SubjectCredits == 2) {
              CreditsCountsRemaining = [1, 2];
            } else if (widget.SubjectCredits == 3) {
              CreditsCountsRemaining = [1, 2, 3];
            } else if (widget.SubjectCredits == 4) {
              CreditsCountsRemaining = [1, 2, 3, 4];
            }
          }
          firstMap = CurrentSubjects[0];

          DateTime time = DateTime.now();
          int year = time.year;
          int month = time.month;
          int day = time.day;
          DateTime dateTime = DateTime(year, month, day);
          //the above DateTime was the extraction of dateTime.now
          String FirstDateFromMap = firstMap['DateTime'].toString();
          int dyear = int.parse(FirstDateFromMap.substring(0, 4));

          int dmonth = int.parse(FirstDateFromMap.substring(5, 7));
          int dday = int.parse(FirstDateFromMap.substring(8, 10));
          DateTime ddatetime = DateTime(dyear, dmonth, dday);
          Duration difference = dateTime.difference(ddatetime);
          int DaysDifference =
              difference.inDays; //Difference between days in a week

          List removeMapsByKey(List list, String keyToRemove) {
            // Filter out maps with the specified key
            return list.where((map) => !map.containsKey(keyToRemove)).toList();
          }

//Step 2   Using Conditions

          if (counts >= widget.SubjectCredits && DaysDifference < 6) {
            print('Inside First If Condition : ' + DaysDifference.toString());
            DisableEnable = false;
          } else if (counts >= widget.SubjectCredits && DaysDifference >= 6) {
            print('Inside UPdating map Section: ' + DaysDifference.toString());
            DisableEnable = false;
            AttendanceValidation = removeMapsByKey(
                AttendanceValidation, widget.SubjectCode); //updating maps
            await CheckAttendanceValidation(); //updating the in firebase
          } else {
            print('Inside Else Section of If Function  ' +
                DaysDifference.toString());
            DisableEnable = true;
          }
        } //If AttendanceValidation List No Empty
        else {
          DisableEnable = true;
        }
      } //If AttendanceValidation Map Exists it mean fresh user
      else {
        DisableEnable = true;
      }
    } catch (e) {
      print('Error Getting Data' + e.toString());
    }
  }

  Future GettingTemporaryAttendance() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('AttendanceCreditValidation')
          .doc(user!.uid)
          .get();
      Map map = snapshot.data() as Map;
      temAttend.add(map['AttendanceValidation']);
      List list = temAttend[0];
      list.forEach((element) {
        AttendanceValidation.add(element);
      });
    } catch (e) {
      print('Error Getting Data' + e.toString());
    }
  }

  Future CheckAttendanceValidation() async {
    try {
      Map myMap = {
        widget.SubjectCode: {
          'SubjectName': widget.SubjectName,
          'SubjectCredits': widget.SubjectCredits,
          'DateTime': DateTime.now().toString().substring(0, 10)
        }
      };
      if (DisableEnable == true) {
        AttendanceValidation.add(myMap);
      }

      _firestore
          .collection('AttendanceCreditValidation')
          .doc(user!.uid)
          .set({'AttendanceValidation': AttendanceValidation});
    } catch (e) {
      print('Error Checking Attendance Status' + e.toString());
    }
  }

  Future GetStudentsFromDatabase() async {
    try {
      var result = await _firestore
          .collection('Classes')
          .doc(auth.currentUser!.uid)
          .get();
      if (result.data() != null) {
        Map allData = result.data() as Map;
        List myList = allData['Students'];
        myList.forEach((element) {
          if (element['SubjectCode'] == widget.SubjectCode) {
            StudentsOfTheCurrentSubject.add(element);
            Map map = element['StudentDetails'];
            map['IsPresent'] = false;
            map['DateTime'] = DateTime.now().toString().substring(0, 10);
            isExists.add(map['IsPresent']);
            StudentDetailsOfTheCurrentSubject.add(map);
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future AttendanceRecord() async {
    setState(() {
      IsLoading = true;
    });
    List list = [];
    try {
      for (int i = 0; i < StudentsOfTheCurrentSubject.length; i++) {
        list.add(StudentsOfTheCurrentSubject[i]['StudentDetails']);
      }
      for (int j = 0; j < list.length; j++) {
        list[j]['IsPresent'] = isExists[j];
      }

      if (StudentsOfTheCurrentSubject != []) {
        List myList = [];
        var result = await _firestore
            .collection('AttendanceRecord')
            .doc(auth.currentUser!.uid)
            .get();
        if (result.data() != null) {
          Map map = result.data() as Map;
          myList = map['Students'];
          StudentsOfTheCurrentSubject.forEach((element) {
            myList.add(element);
          });
        } else {
          StudentsOfTheCurrentSubject.forEach((element) {
            myList.add(element);
          });
        }

        await _firestore
            .collection('AttendanceRecord')
            .doc(auth.currentUser!.uid)
            .set({'Students': myList}).then((value) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Attendance Taken Successfully '),
                duration: Duration(seconds: 4),
                showCloseIcon: true,
              ),
            );
            setState(() {
              isLoading = false;
              Navigator.pop(context);
            });
          });
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    ValidationId();
    temAttend = [];
    AttendanceValidation = [];
    GettingTemporaryAttendance();
    CheckCounts();
    // TODO: implement initState
    super.initState();
    GetStudentsFromDatabase().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        centerTitle: true,
      ),
      floatingActionButton: DisableEnable == true
          ? FloatingActionButton(
              onPressed: () async {
                setState(() {
                  CreditCounts();
                });
              },
              child: Icon(Icons.check),
            )
          : FloatingActionButton(
              backgroundColor: Colors.grey,
              onPressed: () {},
              child: Icon(
                Icons.check,
              ),
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[200]!, Colors.blue[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IsLoading == true ? LoadingWidget() : Container(),
            Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: StudentDetailsOfTheCurrentSubject.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        StudentDetailsOfTheCurrentSubject[index]['FirstName'] +
                            '  ' +
                            StudentDetailsOfTheCurrentSubject[index]
                                ['LastName'],
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        'ID: ${StudentsOfTheCurrentSubject[index]['id']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Checkbox(
                        value: isExists[index],
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            isExists[index] = value!;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Model {
  bool IsPresent = false;

  Attend(Map map) {
    IsPresent:
    map['IsPresent'];
    return IsPresent;
  }
}
