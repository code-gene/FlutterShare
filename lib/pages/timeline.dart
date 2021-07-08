import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';

class Timeline extends StatefulWidget {

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  bool isLoading = false;

  List<Post> posts = [];

  @override
  void initState() {
    getFollowers();
    super.initState();
  }

  getFollowers() async {

    print('Start');
    print(currentUser.id);
    DocumentSnapshot snapshot = await followingRef
        .doc(currentUser.id).get();

    print(snapshot.data()["userFollowing"]);
    followingList = snapshot.data()["userFollowing"];

    print("FollowingList");
    print(followingList);

    getTimeline();
  }

  getTimeline()  async {

    setState(() {
      isLoading = true;
    });

    for(int i = 0; i < followingList.length; i++) {
      print("Following$i : ${followingList[i]}");

      QuerySnapshot snapshot = await postsRef.doc(followingList[i])
          .collection('userPosts').orderBy('timestamp', descending: true).get();

      print(snapshot.docs.length);
      List<Post> postRef = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

      print(postRef);
      posts.addAll(postRef);

      setState(() {
        isLoading = false;
      });

    }

    print("All Posts");
    print(posts);


  }
  buildTimeline() {
    if(isLoading) {
      return circularProgress();
    }
    else return ListView(children: posts);
  }

  @override
  Widget build(context) {
    print('Timeline');
    print(currentUser.id);

    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
