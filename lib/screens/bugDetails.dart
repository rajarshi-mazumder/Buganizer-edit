import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buganizer/models/comment.dart';
import 'package:buganizer/models/bug.dart';
import 'package:buganizer/widgetTemplates/commentForm.dart';
import 'package:buganizer/widgetTemplates/commentsSection.dart';
import 'package:buganizer/widgetTemplates/editBugDetailsForm.dart';

class BugDetails extends StatefulWidget {
  BugDetails({super.key, required this.bug});
  var bug;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  State<BugDetails> createState() => _BugDetailsState();
}

class _BugDetailsState extends State<BugDetails> {
  final _formKey = GlobalKey<FormState>();
  bool _isTextFieldVisible = false;
  void toggleTextFieldVisibility() {
    setState(() {
      _isTextFieldVisible = !_isTextFieldVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.bug["heading"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: toggleTextFieldVisibility,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (_isTextFieldVisible)
                          BugDetailsForm(
                            formKey: _formKey,
                            bug: widget.bug,
                          ),
                        if (_isTextFieldVisible) SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${widget.bug['description']}"),
                            SizedBox(height: 20),
                            Text(
                              'Comments:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CommentsSection(bug: widget.bug),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text('Bug Details'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(null),
          child: Icon(Icons.comment),
        ),
      ),
    );
  }

  void showBottomSheet(int? id) async {
    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
            padding: EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommentForm(bug: widget.bug, context: context),
              ],
            )));
  }
}
