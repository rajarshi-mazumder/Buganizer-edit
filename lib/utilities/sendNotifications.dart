import 'package:flutter/material.dart';
import 'package:buganizer/models/bug.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

sendNotificationToAssignedUser(
    String notifText, String notifType, String? userEmail) async {
  List notifications = [];
  DocumentReference<Map<String, dynamic>> userRef =
      await FirebaseFirestore.instance.collection("users").doc(userEmail);
  // print("userRef: ${userRef.get().then((value) => null)['email']}");
  userRef.get().then((userInfo) {
    notifications = userInfo['notifications'] ?? [];
    notifications.add({
      'notificationType': notifType,
      'notificationText': notifText,
      'dateCreated': DateTime.now(),
    });
    userRef.update({'notifications': notifications});
  });
}
