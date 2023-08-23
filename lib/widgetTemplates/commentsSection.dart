import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buganizer/models/comment.dart';
import 'package:buganizer/models/bug.dart';
import 'package:buganizer/widgetTemplates/commentTile.dart';

class CommentsSection extends StatefulWidget {
  final Map<String, dynamic> bug;

  CommentsSection({Key? key, required this.bug}) : super(key: key);

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late Stream<List<Comment>> commentsStream;

  Stream<List<Comment>> getCommentsStream() async* {
    DocumentReference<Map<String, dynamic>> bugRef = await getBugReference();
    Stream<DocumentSnapshot<Map<String, dynamic>>> snapshotStream =
        bugRef.snapshots();

    await for (DocumentSnapshot<Map<String, dynamic>> snapshot
        in snapshotStream) {
      List<dynamic> commentsDynamic = snapshot['comments'] ?? [];
      List<Comment> comments = commentsDynamic
          .map((comment) => Comment(
              content: comment['content'],
              date: comment['date'].toDate(),
              commentor: comment['commentor']))
          .toList();
      yield comments;
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> getBugReference() async {
    final DocumentReference<Map<String, dynamic>> bugQuery =
        FirebaseFirestore.instance.collection("bugs").doc(widget.bug['id']);

    return bugQuery;
  }

  @override
  void initState() {
    super.initState();
    commentsStream = getCommentsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: StreamBuilder<List<Comment>>(
        stream: commentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error loading comments');
          } else if (snapshot.hasData) {
            List<Comment> comments = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentTile(
                  comment: comments[index],
                  index: index,
                );
              },
            );
          } else {
            return Text('No comments available');
          }
        },
      ),
    );
  }
}
