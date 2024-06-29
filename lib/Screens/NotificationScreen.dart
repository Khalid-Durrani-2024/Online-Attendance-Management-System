import 'package:flutter/material.dart';
import 'package:sis_system/Models/NotificationModel.dart';
import 'package:sis_system/Screens/AddStudentToClass.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

import '../Widgets/TextWidget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

bool? isSelected = false;
NotificationModel model = new NotificationModel();

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    model = new NotificationModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade700,
        appBar: AppBar(
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          centerTitle: true,
          title: TextWidget(
            color: Colors.white,
            size: 22,
            letterSpacing: 0.4,
            text: 'Notifications',
            fontWeight: FontWeight.bold,
          ),
        ),
        body: FutureBuilder(
          future: model.GetNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingWidget();
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'There is No Notification Yet!!',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 36,
                    )
                  ],
                ),
              );
            }

            Map map = snapshot.data;
            List StudenList = [];

            map.forEach((key, value) {
              StudenList.add(key);
            });

            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Map SingleStudent = map[StudenList[index]];
                Map absentees = SingleStudent['Absences'];
                bool ifDanger = false;
                final mapAsString = absentees.entries.map((entry) {
                  if (entry.value > 6) {
                    ifDanger = true;

                    return 'Subject ' + '${entry.key}: Absent (${entry.value})';
                  } else {
                    return 'Subject ' + '${entry.key}: Absent (${entry.value})';
                  }
                }).join(', \n');

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 4,
                  child: ExpansionTile(
                    leading: ClipRRect(
                      child: SingleStudent['Gender'] == 'female' ||
                              SingleStudent['Gender'] == 'Female'
                          ? Image.asset('lib/Assets/femalePic.png')
                          : Image.asset('lib/Assets/malePic.png'),
                    ),
                    title: ifDanger == true
                        ? Text(
                            SingleStudent['Name'],
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(SingleStudent['Name']),
                    subtitle: Text(StudenList[index]),
                    children: [
                      Text(mapAsString),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}
