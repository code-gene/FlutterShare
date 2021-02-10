import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {

  final String postId;
  final String ownerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.ownerId,
    this.postMediaUrl
  });

  @override
  CommentsState createState() => CommentsState(
    postId: this.postId,
    ownerId: this.ownerId,
    postMediaUrl: this.postMediaUrl
  );
}

class CommentsState extends State<Comments> {

  TextEditingController commentController = TextEditingController();

  final String postId;
  final String ownerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
    this.ownerId,
    this.postMediaUrl
  });

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  buildComments() {
    return StreamBuilder(
      stream: commentsRef.doc(postId).collection('comments')
      .orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef
      .doc(postId)
      .collection('comments')
      .add({
        'username': currentUser.username,
        'comment': commentController.text,
        'timestamp': timestamp,
        'photoUrl': currentUser.photoUrl,
        'userId': currentUser.id,
      });

    bool isNotPostOwner = currentUser.id != ownerId;
    if(isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection('feedItems').add({
        'type': 'comment',
        'comment': commentController.text,
        'username': currentUser.id,
        'photoUrl': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': postMediaUrl,
        'timestamp': timestamp,
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment here..',
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          ),
          SizedBox(height: 10),
        ],
      )
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String photoUrl;
  final String comment;
  final Timestamp timestamp;

  const Comment({
    this.username,
    this.userId,
    this.photoUrl,
    this.comment,
    this.timestamp
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc.data()['username'],
      userId: doc.data()['userId'],
      comment: doc.data()['comment'],
      timestamp: doc.data()['timestamp'],
      photoUrl: doc.data()['photoUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
      ],
    );
  }
}
