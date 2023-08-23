import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buganizer/models/comment.dart';
import 'package:buganizer/models/bug.dart';

class CommentForm extends StatefulWidget {
  CommentForm({super.key, required this.bug, required BuildContext context});
  var bug;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _formKey1 = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey1,
      child: Column(
        children: [
          TextFormField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Add a comment for ${widget.bug['id']}',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a comment';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey1.currentState!.validate()) {
                final newComment = {
                  "content": _commentController.text,
                  "date": DateTime.now(),
                  "commentor": widget.user?.email,
                };

                DocumentSnapshot bugSnapshot = await FirebaseFirestore.instance
                    .collection("bugs")
                    .doc(widget.bug['id'])
                    .get();
                List curComments = bugSnapshot['comments'];
                curComments.add(newComment);

                await FirebaseFirestore.instance
                    .collection("bugs")
                    .doc(widget.bug['id'])
                    .update({'comments': curComments});

                _commentController.clear();
              }
              Navigator.of(context).pop();
            },
            child: Text('Submit Comment'),
          ),
        ],
      ),
    );
  }
}
