import 'dart:convert';
import 'dart:io';
import 'package:adminshop/screens/homepage.dart';
import 'package:adminshop/tabs/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Firebaseoperation with ChangeNotifier {
  UploadTask? task;
  String? urlDownload;
  String? inituserName;
  String? inituserEmail;
  String? inituserimage;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future createuser(String name, String email, String token) async {
    FirebaseFirestore.instance
        .collection("user")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'name': name,
      'email': email,
      'image': urlDownload,
      'token': token
    });
  }

  Future uploadimage(String imagepath, File image) async {
    try {
      final filename = imagepath;
      final destination = 'image/$filename';
      task = FirebaseApi.uploadTask(destination, image);
      if (task == null) return;
      final snapshot = await task!.whenComplete(() {});
      urlDownload = await snapshot.ref.getDownloadURL();
    } on Exception {
      return null;
    }
  }

  // FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future uploaditems(String name, String about, String image, List images,
      String price) async {
    FirebaseFirestore.instance.collection("Bestselling").add({
      "name": name,
      "about": about,
      "image": image,
      "images": FieldValue.arrayUnion(images),
      "price": price
    });
  }

  Future createmessageother(
      String otheruseruid, String message, String name) async {
    FirebaseFirestore.instance
        .collection("user")
        .doc(otheruseruid)
        .collection("message")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("chat")
        .add({
      "uid": firebaseAuth.currentUser!.uid,
      "name": name,
      "message": message,
      "time": DateTime.now()
    });
  }

  Future createmessagemyoreder(
    String otheruseruid,
    String message,
    String name,
  ) async {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("message")
        .doc(otheruseruid)
        .collection("chat")
        .add({
      "uid": firebaseAuth.currentUser!.uid,
      "name": name,
      "message": message,
      "time": DateTime.now()
    });
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAKcsxucE:APA91bGC5CNOoMGNSYrp4umy5xFY3lT2vVqPbGF2rOs3SClJpzfdFWRs3TiVzOg3SbvlKBdw9XEqh07xlN5AsVX4B8XJc2sYk0C-ypD7NMUecnn0zmaU37WNmdReGK679FF4nr3vUFiF',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      return null;
    }
  }

  final flutternotifaction = FlutterLocalNotificationsPlugin();
  initnotificaton(BuildContext context) {
    const androdidinitilize = AndroidInitializationSettings("ic_launcher");
    const initilazationsetting =
        InitializationSettings(android: androdidinitilize);
    flutternotifaction.initialize(
      initilazationsetting,
      onSelectNotification: (payload) {
        if (payload == null) {
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => const Chats())));
        }
      },
    );
  }

  Future addtoken() async {
    FirebaseFirestore.instance
        .collection("user")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({"token": FirebaseMessaging.instance.getToken()});
  }
}

class Authclass with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? token;
  getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      token = value;
      print(token);
    });
  }

  Future registeraccount(
      BuildContext context, String name, String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Provider.of<Firebaseoperation>(context, listen: false)
          .createuser(name, email, token!);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
          (route) => false);
    } on Exception catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(snackBar);
    }
  }
}

class FirebaseApi {
  static UploadTask? uploadTask(String destination, File image) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(image);
    } on Exception {
      return null;
    }
  }
}
