import 'package:flutter/material.dart';
import 'notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppBarNav extends StatefulWidget implements PreferredSizeWidget {
  AppBarNav({super.key, required this.goToHomePage});
  User? user = FirebaseAuth.instance.currentUser;
  VoidCallback goToHomePage;

  @override
  _AppBarNavState createState() => _AppBarNavState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBarNavState extends State<AppBarNav> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      title: IconButton(
        icon: Icon(
          Icons.home,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () {
          widget.goToHomePage();
        },
      ),
      actions: [
        Stack(
          children: [
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsScreen(
                              goToHomePage: () {
                                widget.goToHomePage();
                              },
                            )),
                  );
                },
                icon: Icon(Icons.notifications),
                color: Colors.white,
              ),
            ),
            NotificationsCount(user: widget.user),
          ],
        ),
        SizedBox(width: 20),
        Icon(
          Icons.person,
          color: Colors.white,
          size: 24,
        ),
        SizedBox(width: 10),
      ],
      centerTitle: true,
      elevation: 4,
    );
  }
}

class NotificationsCount extends StatefulWidget {
  NotificationsCount({super.key, this.user});
  User? user;
  int? unreadNotificationsCount = 0;

  @override
  State<NotificationsCount> createState() => _NotificationsCountState();
}

class _NotificationsCountState extends State<NotificationsCount> {
  getUnreadNotificationCount() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user?.email)
        .get()
        .then((userInfo) {
      setState(() {
        widget.unreadNotificationsCount = userInfo['notifications'].length;
      });
    });

    print("unreadNotificationsCount: ${widget.unreadNotificationsCount}");
  }

  @override
  void initState() {
    super.initState();

    getUnreadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          widget.unreadNotificationsCount.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
