import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sis_system/Screens/AttendanceReport.dart';

class NotificationModel {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List StudentsData = [];
  Map Students = {};
  List AbsentStudents = [];
  Future GetNotifications() async {
    try {
      var data = await _firestore
          .collection('AttendanceRecord')
          .doc(_auth.currentUser!.uid)
          .get();
      Students = data.data() as Map;
      StudentsData = Students['Students'];

      for (int i = 0; i < StudentsData.length; i++) {
        Map map = StudentsData[i]['StudentDetails'];
        if (map['IsPresent'] == false) {
          map['Subject'] = StudentsData[i]['SubjectName'];
          map['Code'] = StudentsData[i]['SubjectCode'];

          AbsentStudents.add(map);
        }
      }

      //Start of Cod

      List absenteesList = AbsentStudents;

      Map studentAbsences = {};

      // Iterate through the list of absentees
      for (var student in absenteesList) {
        final studentEmail = student['Email'];
        final subject = student['Subject'];
        final name = student['FirstName'];
        final Gender = student['Gender'];
        final code = student['Code'];

        if (studentEmail != null &&
            subject != null &&
            name != null &&
            code != null) {
          // Check if the student is already in the map
          if (!studentAbsences.containsKey(studentEmail)) {
            // If not, add the student to the map and initialize their absence details for the subject
            studentAbsences[studentEmail] = {
              'Name': name,
              'Gender': Gender,
              'Code': code,
              'Absences': {subject: 1},
            };
          } else {
            // If the student is already in the map, check if they are absent in the subject
            if (!studentAbsences[studentEmail]!['Absences']
                .containsKey(subject)) {
              // If not, initialize their absence count for the subject
              studentAbsences[studentEmail]!['Absences'][subject] = 1;
            } else {
              // If they are absent in the subject, increment their absence count
              studentAbsences[studentEmail]!['Absences'][subject] =
                  (studentAbsences[studentEmail]!['Absences'][subject] ?? 0) +
                      1;
            }
          }
        }
      }

      return studentAbsences;
      //End of Chat
    } catch (e) {
      print(e.toString());
    }
  }
}
