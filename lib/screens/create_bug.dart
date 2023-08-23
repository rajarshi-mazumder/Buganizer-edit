import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'package:buganizer/models/bug.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buganizer/main.dart';
import 'package:buganizer/screens/appBar.dart';
import 'package:buganizer/utilities/sendNotifications.dart';

class BugCreation extends StatefulWidget {
  BugCreation({super.key});
  User? user = FirebaseAuth.instance.currentUser;
  @override
  State<BugCreation> createState() => _BugCreationState();
}

class _BugCreationState extends State<BugCreation> {
  final _formKey = GlobalKey<FormState>();
  String _component = "";
  String _heading = '';
  String _description = '';
  String selectedPriority = "";
  String selectedBugType = "";
  late List<Map<String, dynamic>> totalBugs;
  String leastBugsUserEmail = "";
  List assignedBugsList = [];

  List currentUserCreatedBugs = [];

  bool _isTextFieldVisible = false;

  Future<List<Map<String, dynamic>>> getUserWLeastBugs() async {
    late List<Map<String, dynamic>> allUsers;
    final QuerySnapshot<Map<String, dynamic>> allUsersQuery =
        await FirebaseFirestore.instance.collection('users').get();

    allUsers = allUsersQuery.docs.map((doc) => doc.data()).toList();

    int min = 99999999;
    print(allUsers.length);
    allUsers.forEach((element) {
      if (element['assignedBugs'].length <= min &&
          element['email'] != widget.user?.email) {
        min = element['assignedBugs'].length;
        leastBugsUserEmail = element['email'];
        assignedBugsList = element['assignedBugs'];
      } else if (allUsers.length == 1) {
        leastBugsUserEmail = element['email'];
        assignedBugsList = element['assignedBugs'];
      }
    });

    var currentUserQuery = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user?.email)
        .get();

    currentUserCreatedBugs = currentUserQuery['createdBugs'];

    return allUsers;
  }

  void createAndSaveNewBug() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final QuerySnapshot<Map<String, dynamic>> totalBugsQuery =
          await FirebaseFirestore.instance.collection('totalBugs').get();

      totalBugs = totalBugsQuery.docs.map((doc) => doc.data()).toList();
      if (totalBugs.isEmpty) {
        await FirebaseFirestore.instance.collection("totalBugs").doc("0").set({
          "totalBugs": 0,
        });
      } else {
        Bug.totalBugs = totalBugs[0]["totalBugs"] + 1;
      }
      Bug newBug = Bug(
        id: "bug_${Bug.totalBugs}",
        heading: _heading.toString(),
        description: _description.toString(),
        createdBy: widget.user!.email,
        assignedTo: leastBugsUserEmail,
        dateCreated: DateTime.now(),
        priority: selectedPriority,
        bugType: selectedBugType,
        component: _component,
      );

      if (widget.user != null) {
        await FirebaseFirestore.instance.collection('bugs').doc(newBug.id).set({
          'id': "${newBug.id}",
          'heading': _heading.toString(),
          'description': _description.toString(),
          'assignedTo': leastBugsUserEmail,
          'createdBy': widget.user?.email,
          'comments': [],
          'dateCreated': newBug.dateCreated,
          'priority': newBug.priority,
          'bugType': newBug.bugType,
          'component': newBug.component
        });
      }

      await FirebaseFirestore.instance.collection("totalBugs").doc("0").set({
        "totalBugs": Bug.totalBugs,
      });
      assignedBugsList.add(newBug.id);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(leastBugsUserEmail)
          .update({'assignedBugs': assignedBugsList});

      currentUserCreatedBugs.add(newBug.id);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user?.email)
          .update({'createdBugs': currentUserCreatedBugs});

      if (leastBugsUserEmail != widget.user?.email) {
        sendNotificationToAssignedUser("New bug ${newBug.heading} assigned",
            "New Bug Assigned", leastBugsUserEmail);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePageWidget(
                  user: widget.user,
                )),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    getUserWLeastBugs();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBarNav(
        goToHomePage: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePageWidget(
                      user: widget.user,
                    )),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Create bug"),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 8),
                    Row(children: <Widget>[
                      Container(
                        width: screenWidth * 0.25,
                        child: DropdownButtonFormField<String>(
                          // value: selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value!;
                            });
                          },
                          items: priorityOpts.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            //border: OutlineInputBorder(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Select one option';
                            }
                            return null;
                          },
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: screenWidth * 0.65,
                        child: DropdownButtonFormField<String>(
                          // value: selectedBugType,
                          onChanged: (value) {
                            setState(() {
                              selectedBugType = value!;
                            });
                          },
                          items: bugTypeOpts.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Bug Type',
                            //border: OutlineInputBorder(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Select one option';
                            }
                            return null;
                          },
                        ),
                      ),
                    ]),
                    SizedBox(height: 30),
                    Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              child: Icon(Icons.settings),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Component',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This is mandatory';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _component = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              child: Icon(Icons.title),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Title',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This is mandatory';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _heading = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              child: Icon(Icons.description),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This is mandatory';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _description = value;
                                    });
                                  },
                                  maxLines: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: createAndSaveNewBug,
                              child: Text('Create'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                createAndSaveNewBug();
                                // reset the Form and create new
                                _formKey.currentState!.reset();
                              },
                              child: Text('Create & Start Another'),
                            ),
                            TextButton(
                              onPressed: () {
                                _formKey.currentState!.reset();
                              },
                              child: Text('Discard'),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: bgz_drawer(),
    );
  }
}
