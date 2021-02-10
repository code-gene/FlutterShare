import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/models/user.dart';
import 'home.dart';

class Timeline extends StatefulWidget {

  final User currentUser;
  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  List<String> usersFollowersId;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getUsersFollowersId();
  }

  getUsersFollowersId() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.currentUser.id)
        .collection('userFollowers').get();

    setState(() {
      this.usersFollowersId = usersFollowersId;
    });
  }

  getTimeline() async {
    for(int i = 0; i < usersFollowersId.length; i++) {

      QuerySnapshot snapshot = await postsRef
          .doc(usersFollowersId[i])
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .get();
    }

    setState(() {
      this.posts = posts;
    });
  }


  buildTimeline() {
    if(posts == null) {
      return circularProgress();
    }
    return ListView(children: posts);
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
          child: buildTimeline(),
      ),
    );
  }
}
