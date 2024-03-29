import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {

  getActivityFeed() async {
    print(currentUser.id);

    QuerySnapshot snapshot = await activityFeedRef
      .doc(currentUser.id)
      .collection('feedItems')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .get();

    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    print("FeedItems");
    print(feedItems);
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    print('Activity Feed');
    return Scaffold(
      appBar: header(context, titleText : 'Activity Feed'),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          }
        )
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {

  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String photoUrl;
  final String comment;
  final Timestamp timestamp;

  const ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.photoUrl,
    this.comment,
    this.timestamp
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc.data()['username'],
      userId: doc.data()['userId'],
      type: doc.data()['type'],
      mediaUrl: doc.data()['mediaUrl'],
      postId: doc.data()['postId'],
      photoUrl: doc.data()['photoUrl'],
      comment: doc.data()['comment'],
      timestamp: doc.data()['timestamp'],
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if(type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    }
    else {
      mediaPreview = Text('');
    }

    if(type == 'like') {
      activityItemText = ' liked your post';
    }
    else if(type == 'follow') {
      activityItemText = ' is following you';
    }
    else if(type == 'comment') {
      activityItemText = ' replied: $comment';
    }
    else {
      activityItemText = ' Error: Unknown type $type';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize:  14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '$activityItemText',
                  ),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,

        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
          profileId: profileId,
      ),
    ),
  );
}
