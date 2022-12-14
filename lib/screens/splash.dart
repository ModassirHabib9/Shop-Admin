import 'dart:async';
import 'package:adminshop/screens/homepage.dart';
import 'package:adminshop/screens/loginpage.dart';
import 'package:adminshop/tabs/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  late StreamSubscription<User?> user;
  @override
  void initState() {
    Timer(const Duration(seconds: 6), () {
      user = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Registerpage()),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
              (route) => false);
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    user.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Welcome to Admin App")));
  }
}
