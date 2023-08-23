import 'package:buganizer/screens/bugDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buganizer/models/comment.dart';
import 'package:buganizer/models/bug.dart';
import 'package:buganizer/utilities/sendNotifications.dart';
import 'package:buganizer/screens/assignedBugs.dart';

class BugDetailsForm extends StatefulWidget {
  BugDetailsForm({super.key, required this.formKey, required this.bug});
  var formKey;
  var bug;
  User? user = FirebaseAuth.instance.currentUser;
  @override
  State<BugDetailsForm> createState() => _BugDetailsFormState();
}

class _BugDetailsFormState extends State<BugDetailsForm> {
  bool _isTextFieldVisible = true;
  String bugHeading = "";
  String selectedPriority = "P4"; // Initialize with your default value
  String selectedBugType = "None"; // Initialize with your default value
  String selectedBugStatus = "Open"; // Initialize with your default value
  String assignedTo = "Not assigned";
  String bugDescription = "No description";
  List<Map<String, dynamic>>? allUsers;
  void _toggleTextFieldVisibility() {
    setState(() {
      _isTextFieldVisible = !_isTextFieldVisible;
    });
  }

  Future<void> getAllUsers() async {
    final QuerySnapshot<Map<String, dynamic>> allUsersQuery =
        await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      allUsers = allUsersQuery.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    bugHeading =
        widget.bug['heading'] != null ? widget.bug['heading'] : "No heading";
    assignedTo = widget.bug['assignedTo'] != null
        ? widget.bug['assignedTo']
        : "Not assigned";
    selectedPriority = widget.bug['priority'] != null
        ? widget.bug['priority'] ?? "Priority not set"
        : "P4";
    selectedBugStatus =
        widget.bug['status'] != null ? widget.bug['status'] : "Open";
    bugDescription = widget.bug["description"] != null
        ? widget.bug["description"]
        : "No description";
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    print("selectedPriority: ${selectedPriority}");
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          Container(
            child: DropdownButtonFormField<String>(
              value: assignedTo,
              onChanged: (value) {
                setState(() {
                  assignedTo = value!;
                });
              },
              items: allUsers?.map((option) {
                return DropdownMenuItem(
                  value: option['email'].toString(),
                  child: Text(option['email'].toString()),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Assigned to',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Select one option';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 20),
          Row(children: <Widget>[
            Container(
              width: screenWidth * 0.25,
              child: DropdownButtonFormField<String>(
                value: selectedPriority,
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select one option';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Container(
                width: screenWidth * 0.5,
                child: DropdownButtonFormField<String>(
                  value: selectedBugStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedBugStatus = value!;
                    });
                  },
                  items: bugStatusOpts.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select one option';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ]),
          SizedBox(height: 30),
          Row(
            children: [
              Container(
                child: Icon(Icons.title),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    initialValue: bugHeading,
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
                        bugHeading = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                child: Icon(Icons.settings),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    initialValue: bugDescription,
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
                        bugDescription = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (widget.formKey.currentState!.validate()) {
                DocumentSnapshot bugSnapshot = await FirebaseFirestore.instance
                    .collection("bugs")
                    .doc(widget.bug['id'])
                    .get();

                SendOutNotifications(
                    widget: widget,
                    bugSnapshot: bugSnapshot,
                    selectedPriority: selectedPriority,
                    user: widget.user);

                await FirebaseFirestore.instance
                    .collection("bugs")
                    .doc(widget.bug['id'])
                    .update({
                  'heading': bugHeading,
                  'description': bugDescription,
                  'priority': selectedPriority,
                  'status': selectedBugStatus,
                  'assignedTo': assignedTo,
                });

                //_commentController.clear();
              }
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Bug updated'),
                  content: const Text('Successfully changed bug'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserAssignedBugs(
                                  user: widget.user,
                                )),
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Update Bug'),
          ),
        ],
      ),
    );
  }
}

void SendOutNotifications(
    {var bugSnapshot, var selectedPriority, var widget, User? user}) {
  if (bugSnapshot['priority'] != selectedPriority &&
      bugSnapshot['assignedTo'] != user) {
    sendNotificationToAssignedUser(
        "Priority for ${widget.bug['heading']} changed",
        "Priority Changed",
        widget.bug['assignedTo']);
  }
}
