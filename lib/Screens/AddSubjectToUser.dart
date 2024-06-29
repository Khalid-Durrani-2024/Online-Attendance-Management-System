import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sis_system/Screens/Subjects.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

class AddSubjectToUser extends StatefulWidget {
  const AddSubjectToUser({super.key});

  @override
  State<AddSubjectToUser> createState() => _AddSubjectToUserState();
}

class _AddSubjectToUserState extends State<AddSubjectToUser> {
  List UsersList = [];
  GetUsers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('Users').get();
    List myList = snapshot.docs;
    myList.forEach((element) {
      QueryDocumentSnapshot snapshot = element;
      UsersList.add(snapshot.data());
    });
    return UsersList;
  }

  @override
  void initState() {
    GetUsers();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teachers'),
        centerTitle: true,
      ),
      backgroundColor: Colors.indigo,
      body: FutureBuilder(
        future: GetUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingWidget(),
            );
          }
          if (snapshot.hasData)
            return ListView.builder(
              itemCount: UsersList.length,
              itemBuilder: (context, index) {
                Map map = UsersList[index];
                return GestureDetector(
                  onTap: () {
                    print(map);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SubjectScreen(
                        UserUid: map['Uid'],
                      ),
                    ));
                  },
                  child: Card(
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      leading: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        map['Name'],
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      subtitle: Text(
                        map['Email'],
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
          return Center(
            child: Text('No Data Recieved Please Wait'),
          );
        },
      ),
    );
  }
}
