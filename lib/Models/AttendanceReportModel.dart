import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceReportModel {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GetStudentsWithTheDateTime(
      String dateTime, List AllStudents, String S_Name) async {
    try {
      var result = await _firestore
          .collection('AttendanceRecord')
          .doc(auth.currentUser!.uid)
          .get();
      Map Students = result.data() as Map;
      List myList = Students['Students'];
      myList.forEach((element) {
        if (element['SubjectName'] == S_Name) {
          Map StudentDetails = element['StudentDetails'];
          if (StudentDetails['DateTime'] ==
              dateTime.toString().substring(0, 10)) {
            AllStudents.add(element);
          }
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
