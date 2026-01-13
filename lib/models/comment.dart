import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userId;
  final String userName;
  final String userImage;
  final String message;
  final DateTime postedAt;
  final List<String> likes;
  final List<Comment> replies;
  final DateTime timestamp;
  final String commentKey;

  Comment({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.message,
    required this.postedAt,
    this.likes = const [],
    required this.timestamp,
    this.replies = const [],
    required this.commentKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'message': message,
      'postedAt': postedAt,
      'likes': likes,
      'replies': { for (var r in replies) r.commentKey : r.toMap() },
      'commentKey': commentKey,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map, String key) {
    // Support either 'postedAt' (preferred) or 'posted' keys & Timestamp or ISO strings
    DateTime posted = DateTime.now();
    if (map['postedAt'] is Timestamp) {
      posted = (map['postedAt'] as Timestamp).toDate();
    } else if (map['postedAt'] is String) {
      posted = DateTime.tryParse(map['postedAt']) ?? DateTime.now();
    } else if (map['posted'] is Timestamp) {
      posted = (map['posted'] as Timestamp).toDate();
    } else if (map['posted'] is String) {
      posted = DateTime.tryParse(map['posted']) ?? DateTime.now();
    }

    DateTime timestamp = DateTime.now();
    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      timestamp = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
    }

    List<Comment> replies = [];
    if (map['replies'] is Map) {
      final mp = Map<String, dynamic>.from(map['replies'] as Map);
      replies = mp.entries.map((e) {
        return Comment.fromMap(Map<String, dynamic>.from(e.value), e.key);
      }).toList();
    }

    return Comment(
      commentKey: key,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userImage: map['userImage']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      postedAt: posted,
      timestamp: timestamp,
      likes: List<String>.from(map['likes'] ?? []),
      replies: replies,
    );
  }
}

class AnnouncementModel {
  final String docID;
  final String title;
  final String message;
  final String imgurl;
  final String urlattachment;
  final String postedBy;
  final String postedById;
  final DateTime posted;
  final List<String> likes;
  final Map<String, Comment>? comments;

  AnnouncementModel({
    required this.docID,
    required this.title,
    required this.message,
    required this.imgurl,
    required this.urlattachment,
    required this.postedBy,
    required this.postedById,
    required this.posted,
    required this.likes,
    this.comments,
  });

  factory AnnouncementModel.fromMap(String id, Map<String, dynamic> map) {
    final commentMap = (map['comments'] as Map<String, dynamic>?) ?? {};
    final comments = commentMap.map((k, v) =>
        MapEntry(k, Comment.fromMap(Map<String, dynamic>.from(v), k)));
    return AnnouncementModel(
      docID: id,
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      imgurl: map['imgurl']?.toString() ?? '',
      urlattachment: map['urlattachment']?.toString() ?? '',
      postedBy: map['postedBy']?.toString() ?? '',
      postedById: map['postedById']?.toString() ?? '',
      posted: (map['posted'] is Timestamp)
          ? (map['posted'] as Timestamp).toDate()
          : DateTime.now(),
      likes: List<String>.from(map['likes'] ?? []),
      comments: comments,
    );
  }
}

class UserModel {
  String fullname;
  final String nickname;
  final String searchname;
  final String userImage;
  final String userEmail;
  final bool showRanking;
  final int userNameDisplay;
  final String sbUserID;
  String userID;

  UserModel({
    required this.fullname,
    required this.nickname,
    required this.searchname,
    required this.userImage,
    required this.userEmail,
    required this.showRanking,
    required this.userNameDisplay,
    required this.userID,
    required this.sbUserID,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    UserModel model = UserModel(
      fullname: map['fullname'] as String? ?? '',
      nickname: map['nickname'] as String? ?? '',
      searchname: map['searchname'] as String? ?? '',
      userImage: map['userImage'] as String? ?? '',
      userID: map['userID'] as String? ?? '',
      sbUserID: map['sbUserID'] as String? ?? '',
      userEmail: map['email'] as String? ?? '',
      showRanking: map['showRanking'] as bool? ?? true,
      userNameDisplay:
          map['userNameDisplay'] != null ? map['userNameDisplay'] as int : 0,
    );

    model.fullname = model.fullname == "" ? model.nickname : model.fullname;
    return model;
  }

  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'nickname': nickname,
      'searchname': searchname,
      'userImage': userImage,
      'email': userEmail,
      'userID': userID,
      'sbUserID': sbUserID,
      'showRanking': showRanking,
      'userNameDisplay': userNameDisplay,
    };
  }
}
