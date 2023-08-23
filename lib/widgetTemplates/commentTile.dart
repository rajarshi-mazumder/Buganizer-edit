import 'package:flutter/material.dart';
import 'package:buganizer/models/comment.dart';

class CommentTile extends StatelessWidget {
  final comment;
  final int index;

  CommentTile({required this.comment, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comment.commentor,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '#$index',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12), // Add more space
            Text(
              'Comment: ${comment.content}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
