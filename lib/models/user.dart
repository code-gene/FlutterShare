class User {
  final String id;
  final String username;
  final  String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

  factory User.fromDocument(doc) {
    return User(
      id: doc.data()['id'],
      username: doc.data()['username'],
      email: doc.data()['email'],
      photoUrl: doc.data()['photoUrl'],
      displayName: doc.data()['displayName'],
      bio: doc.data()['bio'],
    );
  }
}
