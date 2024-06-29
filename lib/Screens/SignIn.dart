import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sis_system/Models/UserModel.dart';
import 'package:sis_system/Screens/HomePage.dart';
import 'package:sis_system/Screens/PasswordReset.dart';
import 'package:sis_system/Screens/ProfileScreen.dart';
import 'package:sis_system/Screens/WaitingVerificationScreen.dart';
import 'package:sis_system/Widgets/LoadingWidget.dart';

import '../Models/CustomExceptions.dart';
import '../Widgets/ButtonWidget.dart';
import '../Widgets/TextWidget.dart';
import 'SignUp.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var EmailController = TextEditingController();

  var PasswordController = TextEditingController();
  bool PasswordVisibility = true;

  FirebaseAuth auth = FirebaseAuth.instance;
  UserModel _userModel = UserModel();

  void _handleSignIn(BuildContext context) async {
    if (EmailController.text != '' &&
        EmailController.text.contains('@') &&
        EmailController.text.contains('.')) {
      if (PasswordController.text.length >= 6) {
        setState(() {
          _userModel.isLoading = true;
        });
        try {
          final user = await _userModel.SecondSignInMethod(
              EmailController.text.trim(),
              PasswordController.text.trim(),
              context);
          if (user != null && user.emailVerified) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
                (route) => false);
          } else {
            setState(() {
              _userModel.isLoading = false;
            });
            if (user != null && !user.emailVerified) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => WaitingVerificationScreen(),
                  ),
                  (route) => false);
            }
          }
        } on FirebaseNetworkException catch (e) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              iconColor: Colors.red,
              icon: Icon(
                Icons.error_outline,
                size: 50,
                shadows: [
                  BoxShadow(
                    color: Colors.red,
                  )
                ],
              ),
              backgroundColor: Colors.indigo,
              title: const Text(
                'Network Error',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                e.message,
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
          setState(() {
            _userModel.isLoading = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error Occured: ' + e.toString()),
            duration: const Duration(seconds: 4),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Incorrect Password Check Your Password and try again'),
            duration: Duration(seconds: 4),
            showCloseIcon: true,
          ),
        );
      } // Nested If Condition
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect Email Address'),
          duration: Duration(seconds: 4),
          showCloseIcon: true,
        ),
      );
    } //First If
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown, Colors.blueGrey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        _userModel.isLoading == true
                            ? const LoadingWidget()
                            : Container(),
                      ],
                    )),
                Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Container(
                          width: 250,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              opacity: 0.7,
                              image: AssetImage(
                                'lib/Assets/logoEdited23.png',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          style:
                              TextStyle(color: Colors.white, letterSpacing: .4),
                          controller: EmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.indigo),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style:
                              TextStyle(color: Colors.white, letterSpacing: .4),
                          controller: PasswordController,
                          obscureText: PasswordVisibility,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.indigo),
                            suffixIcon: InkWell(
                              onTap: () {
                                if (PasswordVisibility == true) {
                                  PasswordVisibility = false;
                                } else {
                                  PasswordVisibility = true;
                                }
                                setState(() {});
                              },
                              child: Icon(
                                PasswordVisibility == true
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () async {
                            _handleSignIn(context);
                          },
                          child: ButtonWidget(
                            size: 22,
                            text: "Sign In",
                            height: 65,
                            width: 200,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(),
                            ));
                          },
                          child: const Text('Forgot Password?'),
                          style: TextButton.styleFrom(primary: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignUp(),
                            ));
                          },
                          child: TextWidget(
                            text: 'Sign Up',
                            size: 16,
                            color: Colors.indigo.shade100,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
