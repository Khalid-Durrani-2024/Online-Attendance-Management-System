import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sis_system/Screens/HomePage.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';
import '../Widgets/ButtonWidget.dart';
import '../Widgets/TextWidget.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:permission_handler/permission_handler.dart';

class HelpAndSupport extends StatefulWidget {
  const HelpAndSupport({super.key});

  @override
  State<HelpAndSupport> createState() => _HelpAndSupportState();
}

var NameController = TextEditingController();
var SectionController = TextEditingController();
var ContactController = TextEditingController();
var DescriptionController = TextEditingController();
bool isLoading = false;
void ShowDialogBox(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.indigo,
        icon: Icon(
          Icons.done,
          size: 50,
          color: Colors.green,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Message Sent',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Thank you for reaching out to our support team. Your message has been successfully sent. We will review your inquiry or report and respond as soon as possible. Please check your email or this app for updates.  We appreciate your patience.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomePage(),
                ));
              },
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white),
              ))
        ],
      );
    },
  );
}

void ShowErrorDialogue(
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.indigo,
        icon: Icon(
          Icons.disabled_by_default_outlined,
          size: 50,
          color: Colors.red,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Message Not Sent',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'We apologize, but it seems that there was an issue sending your message to our support team. Please check your internet connection and try again. If the problem persists, please consider the following steps:1. Ensure a stable internet connection.2. Restart the app and try sending your message again.3. If the issue continues, you can also reach out to our support team via email at [SaidJamaluddinafghani@gmail.com].We appreciate your patience and apologize for any inconvenience.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white),
              ))
        ],
      );
    },
  );
}

class _HelpAndSupportState extends State<HelpAndSupport> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NameController.text = '';
    SectionController.text = '';
    ContactController.text = '';
    DescriptionController.text = '';
  }

  Future<void> sendEmail() async {
    if (NameController.text != '' &&
        SectionController.text != '' &&
        ContactController.text != '' &&
        DescriptionController.text != '') {
      setState(() {
        isLoading = true;
      });
      FirebaseAuth auth = await FirebaseAuth.instance;

      User? user = auth.currentUser;

      final smtpServer = gmail('SaidJamaluddinafghani@gmail.com', 'mfhh qhes rbbf kkyp');

      final message = Message()
        ..from = Address(user!.email.toString(), user!.email)
        ..recipients.add(
            'SaidJamaluddinafghani@gmail.com') // Replace with the recipient's email address
        ..subject = 'Help & Support'
        ..text = 'This is the plain text.\nThis is line 2 of the text part.'
        ..html =
            '<h1>From SIS System</h1>\n<p> Hi My Name is <b>${NameController.text}</b>  I have a Problem in <b>${SectionController.text}</b> section \n The Problem is <b>${DescriptionController.text}</b> if the Problem is Solved Contact me by <b>${ContactController.text}</b></p>';
      try {
        final sendReport = await send(message, smtpServer);
        setState(() {
          isLoading = false;
          ShowDialogBox(context);
        });
      } catch (e) {
        print(e.toString());
        setState(() {
          isLoading = false;
          ShowErrorDialogue(context);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All Fields Required To Be Filled'),
        duration: Duration(seconds: 4),
        showCloseIcon: true,
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Help & Support'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        child: Column(
          children: [
            isLoading == true ? LoadingWidget() : Container(),
            TextWidget(
              color: Colors.white,
              size: 22,
              fontWeight: FontWeight.bold,
              text: 'Hey!! How Can I Help You?',
              letterSpacing: 0.0,
            ),
            Icon(
              Icons.support_agent,
              size: 100,
              color: Colors.white,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    children: [
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: NameController,
                        decoration: InputDecoration(
                            hintText: 'Your Name',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: SectionController,
                        decoration: InputDecoration(
                            hintText: 'Problem In Section',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: ContactController,
                        decoration: InputDecoration(
                            hintText: 'Contact me by',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: DescriptionController,
                        decoration: InputDecoration(
                            hintText: 'Problem Description',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      InkWell(
                        onTap: () {
                          sendEmail();
                        },
                        child: ButtonWidget(
                            bgColor: Colors.indigo,
                            height: 70,
                            width: 200,
                            text: 'Send'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
