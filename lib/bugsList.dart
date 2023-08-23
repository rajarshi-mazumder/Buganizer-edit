import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgetTemplates/bugDisplayCard.dart';

class BugsListScreen extends StatefulWidget {
  BugsListScreen({this.user, required this.contextType});
  User? user;
  String contextType;
  @override
  _BugsListScreenState createState() => _BugsListScreenState();
}

class _BugsListScreenState extends State<BugsListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _bugsStream;

  @override
  void initState() {
    super.initState();
    _bugsStream = _firestore
        .collection('bugs')
        .orderBy("dateCreated", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _bugsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final bugs = snapshot.data?.docs ?? [];
        List thisUsersBugs = [];

        if (widget.contextType == "Assigned") {
          bugs.forEach((bug) {
            if (bug['assignedTo'] == widget.user?.email) {
              thisUsersBugs.add(bug);
            }
          });
        } else if (widget.contextType == "Created") {
          bugs.forEach((bug) {
            if (bug['createdBy'] == widget.user?.email) {
              thisUsersBugs.add(bug);
            }
          });
        } else if (widget.contextType == "All") {
          thisUsersBugs = bugs;
        }
        if (bugs.isEmpty) {
          return Center(child: Text('No bugs found.'));
        }

        return ListView.builder(
          itemCount: thisUsersBugs.length,
          itemBuilder: (context, index) {
            final bugData = thisUsersBugs[index].data() as Map<String, dynamic>;
            final bugHeading = bugData['heading'] ?? 'No Heading';
            final bugDescription = bugData['description'] ?? 'No description';

            // return BugDisplayCard(bug: bugData);
            return BugDisplayCard(bug: bugData);
          },
        );
      },
    );
  }
}
