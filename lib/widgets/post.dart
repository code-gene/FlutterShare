import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/models/user.dart';

import 'custom_image.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.caption,
    this.mediaUrl,
    this.likes,
  });

  int getLikesCount(likes) {
    if(likes == null) return 0;
    int count = 0;
    likes.values.forEach((val){
      if(val == true) {
        count += 1;
      }
    });
    return count;
  }

  factory Post.fromDocument(doc) {
    return Post(
      postId: doc.data()['postId'],
      ownerId: doc.data()['ownerId'],
      username: doc.data()['username'],
      location: doc.data()['location'],
      caption: doc.data()['caption'],
      mediaUrl: doc.data()['mediaUrl'],
      likes: doc.data()['likes'],
    );
  }




  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    caption: this.caption,
    mediaUrl : this.mediaUrl,
    likes: this.likes,
    likeCount: getLikesCount(this.likes),
  );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;

  int likeCount;
  Map likes;
  bool isLiked;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.caption,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        );
      }
    );
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if(_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});

      removeLikeFromActivityFeed();

      setState(() {
        likeCount--;
        isLiked = false;
        likes[currentUserId] = false;
      });
    }
    else if(!isLiked){
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});

      addLikeToActivityFeed();

      setState(() {
        likeCount++;
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if(isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }
  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if(isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .set({
        'type': 'like',
        'username': currentUser.displayName,
        'photoUrl': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': mediaUrl,
        'timestamp': timestamp,
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment:  Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
        ],
      ),
    );
  }
  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                (isLiked) ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$likeCount likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  '$username ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(caption),
              ),
            ]
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  showComments(BuildContext context, {String postId, String ownerId, String mediaUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
        postId: postId,
        ownerId: ownerId,
        postMediaUrl: mediaUrl,
      );
    }));
  }
}
