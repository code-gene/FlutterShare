import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';

class Profile extends StatefulWidget {

  final String profileId;
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

List followersList = [];
List followingList = [];

class _ProfileState extends State<Profile> {

  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  String postOrientation = 'list';
  
  @override
  void initState() {
    super.initState();
    print('Inside Profile');
    print(widget.profileId);
    print('CurrentUserId: $currentUserId');
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  getFollowing() async {
    var snapshot = await followingRef
        .doc(widget.profileId).get();

    followingList =snapshot['userFollowing'];

    setState(() {
      followingCount = followingList.length;
    });
  }

  getFollowers() async {
    var snapshot = await followersRef
      .doc(widget.profileId).get();

    followersList =snapshot['userFollowers'];

    setState(() {
      followerCount = followersList.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
      .doc(widget.profileId)
      .collection('userFollowers')
      .doc(currentUserId).get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
      print("Profile Posts");
      print(posts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText : 'Profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(
                      user.photoUrl,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildCountColumn("posts", postCount),
                            buildCountColumn("followers", followerCount),
                            buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              )
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId),
        ),
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child:Container(
          width: 245,
          height: 30,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.red : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.red : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        )
      )
    );
  }

  Widget buildProfileButton() {
    // if viewing own profile, should show edit profile buttons
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    }
    else if(isFollowing){
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    }
    else if(!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
    else return Text('');
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });

    followersRef.doc(widget.profileId).set({
      "userFollowers": FieldValue.arrayUnion([
      currentUserId
    ]),
    }, SetOptions(merge: true));

    followingRef.doc(currentUserId).set({
      "userFollowing": FieldValue.arrayUnion([
        widget.profileId
      ]),
    }, SetOptions(merge: true));

    // followingRef.doc(currentUserId)
    //   .collection('userFollowing')
    //   .doc(widget.profileId).set({});

    activityFeedRef.doc(widget.profileId)
      .collection('feedItems')
      .doc(currentUserId).set({
        "type": "follow",
        "ownerId": widget.profileId,
        "username": currentUser.username,
        "userId": currentUserId,
        "userPhotoUrl": currentUser.photoUrl,
        "timestamp": timestamp,
      });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });

    followersRef.doc(widget.profileId).set({
      "userFollowers": FieldValue.arrayRemove([
        widget.profileId
      ]),
    }, SetOptions(merge: true));

    // followersRef.doc(widget.profileId)
    //     .collection('userFollowers')
    //     .doc(currentUserId).delete();
    //
    // followingRef.doc(currentUserId)
    //     .collection('userFollowing')
    //     .doc(widget.profileId).delete();

    followingRef.doc(currentUserId).set({
      "userFollowing": FieldValue.arrayRemove([
        widget.profileId
      ]),
    }, SetOptions(merge: true));

    activityFeedRef.doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId).delete();
  }

  buildProfilePosts() {
    if(isLoading) {
      return circularProgress();
    }
    else if(postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post: post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    else if(postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }
  buildTogglePostOrientation() {
    print(postOrientation);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid' ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () => setPostOrientation('grid'),
        ),
        IconButton(
          icon: Icon(Icons.list),
          color: postOrientation == 'list' ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () => setPostOrientation('list'),
        ),
      ],
    );
  }
}
