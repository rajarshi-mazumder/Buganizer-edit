import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sidebar.dart';
import 'appBar.dart';
import 'package:buganizer/bugsList.dart';
import 'package:intl/intl.dart';
import 'assignedBugs.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key, this.goToHomePage});
  final scaffoldKey = GlobalKey<ScaffoldState>();
  User? user = FirebaseAuth.instance.currentUser;
  Function? goToHomePage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: bgz_drawer(),
      appBar: AppBarNav(
        goToHomePage: () {
          goToHomePage!();
        },
      ),
      body: SafeArea(
        top: true,
        child: Container(
          child: NotificationsSection(
            user: user,
          ),
        ),
      ),
    );
  }
}

class NotificationsSection extends StatefulWidget {
  User? user;
  NotificationsSection({Key? key, this.user}) : super(key: key);

  @override
  _NotificationsSectionState createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  late Stream<List<Notification>> notificationsStream;
  List<Notification> notifications = [];

  Stream<List<Notification>> getNotificationsStream() async* {
    DocumentReference<Map<String, dynamic>> userRef =
        FirebaseFirestore.instance.collection("users").doc(widget.user?.email);

    yield* userRef.snapshots().map((userInfo) {
      List<dynamic> userNotifications = userInfo['notifications'] ?? [];
      notifications = userNotifications.map((notification) {
        print(notification['dateCreated'].runtimeType);
        return Notification(
            notificationType: notification['notificationType'],
            notificationText: notification['notificationText'],
            dateCreated: notification['dateCreated'].toDate());
      }).toList();

      return notifications;
    });
  }

  void _deleteNotification(int index) async {
    setState(() {
      notifications.removeAt(index);
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user?.email)
        .update({
      'notifications': notifications.map((e) => {
            'notificationText': e.notificationText,
            'notificationType': e.notificationType,
            'dateCreated': e.dateCreated,
          })
    });
  }

  @override
  void initState() {
    super.initState();
    notificationsStream = getNotificationsStream();
    print(notificationsStream);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<Notification>>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error loading notifications');
          } else if (snapshot.hasData) {
            List<Notification> notifications = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _deleteNotification(index);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserAssignedBugs(
                                user: widget.user,
                              )),
                    );
                  },
                  child: NotificationItem(
                      index: index,
                      notification: notifications[index],
                      onDelete: (index) {
                        _deleteNotification(index);
                      }),
                );
              },
            );
          } else {
            return Text('No notifications available');
          }
        },
      ),
    );
  }
}

class Notification {
  String? notificationText;
  String? notificationType;
  DateTime? dateCreated;
  Notification(
      {this.notificationText, this.notificationType, this.dateCreated});
}

class NotificationItem extends StatelessWidget {
  final int index;
  final Notification notification;
  final Function(int) onDelete;

  NotificationItem({
    required this.index,
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notification.notificationType!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              IconButton(
                onPressed: () {
                  onDelete(index);
                },
                icon: Icon(Icons.delete),
                color: Color.fromARGB(163, 5, 180, 243), // Delete icon color
              ),
            ],
          ),
          SizedBox(height: 6.0),
          // Text('Case#: '),
          // Display date and time

          Text(notification.notificationText!),
          SizedBox(height: 6.0),
          Text(
              '${DateFormat('yy-MM-dd – kk:mm').format(notification.dateCreated!)}'),
        ],
      ),
    );
  }
}
