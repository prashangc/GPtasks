import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/comment.dart';

class CommentProvider extends ChangeNotifier {
  late AnnouncementModel announcementModel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'announcements';

  final Map<String, List<Comment>> _commentsByAnnouncement = {};
  Map<String, List<Comment>> get commentsByAnnouncement =>
      _commentsByAnnouncement;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<String> _likes = [];
  List<String> _comments = [];
  List<String> get likes => _likes;
  List<String> get comments => _comments;
  int get likeCount => _likes.length;
  int get commentCount => comments.length;
  bool get isLiked => _likes.contains(currentUserUid);

  bool isInitial = false;

  String get currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Get comments list for specific announcement
  List<Comment> getComments(String announcementDocId) {
    return _commentsByAnnouncement[announcementDocId] ?? [];
  }

  Future<void> fetchPostDetails() async {
    if (!isInitial) {
      _isLoading = true;
      isInitial = true;
    }
    // notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc("r7rBmg7ueno3PCNdcLxz")
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        announcementModel = AnnouncementModel.fromMap(snapshot.id, data);
        setInitialLikes(announcementModel.likes);
        setInitialComments(announcementModel.comments);

        final comments = announcementModel.comments ?? {};

        int totalReplies = 0;
        if (comments.isNotEmpty) {
          totalReplies = comments.values
              .map((comment) => comment.replies.length)
              .fold(0, (a, b) => a + b);
        }
        // _commentCount = comments.length + totalReplies;

        print('Comments: ${comments.map((k, v) => MapEntry(k, v.toMap()))}');
        print('Replies: $totalReplies');
        // print('Total Comment Count: $_commentCount');
      } else {
        // _commentCount = 0;
        print('No announcement found.');
      }
    } catch (e) {
      print('Error fetching post: $e');
      // _commentCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComments(String announcementDocId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore.collection(_collection).doc(announcementDocId).get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final commentsData = (data?['comments'] as Map<String, dynamic>?) ?? {};

        final comments = commentsData.entries
            .map((entry) => Comment.fromMap(
                  Map<String, dynamic>.from(entry.value as Map),
                  entry.key,
                ))
            .toList();

        comments.sort((a, b) => b.postedAt.compareTo(a.postedAt));

        _commentsByAnnouncement[announcementDocId] = comments;
        print(
            'Fetched comments for announcement $announcementDocId: $comments');

        notifyListeners();
      }
    } catch (e) {
      print(' Error fetching comments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Comment>> streamComments(String announcementDocId) {
    return _firestore
        .collection(_collection)
        .doc(announcementDocId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final commentsData = (data?['comments'] as Map<String, dynamic>?) ?? {};
        final comments = commentsData.entries
            .map((entry) => Comment.fromMap(
                Map<String, dynamic>.from(entry.value as Map), entry.key))
            .toList();
        comments.sort((a, b) => b.postedAt.compareTo(a.postedAt));
        return comments;
      }
      return <Comment>[];
    });
  }

  Future<void> likeComment({
    required String announcementDocId,
    required String commentKey,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(announcementDocId).update({
        'comments.$commentKey.likes': FieldValue.arrayUnion([userId]),
      });

      print('✅ Comment liked');
      notifyListeners();
    } catch (e) {
      print('❌ Error liking comment: $e');
    }
  }

  Future<void> unlikeComment({
    required String announcementDocId,
    required String commentKey,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(announcementDocId).update({
        'comments.$commentKey.likes': FieldValue.arrayRemove([userId]),
      });

      print('✅ Comment unliked');
      notifyListeners();
    } catch (e) {
      print(' Error unliking comment: $e');
    }
  }

  Future<void> toggleCommentLike({
    required String announcementDocId,
    required String commentKey,
    required String userId,
    required bool isLiked,
  }) async {
    if (isLiked) {
      await unlikeComment(
        announcementDocId: announcementDocId,
        commentKey: commentKey,
        userId: userId,
      );
    } else {
      await likeComment(
        announcementDocId: announcementDocId,
        commentKey: commentKey,
        userId: userId,
      );
    }
  }

  Future<void> addComment({
    required String announcementDocId,
    required String userId,
    required String userName,
    required String userImage,
    required String message,
  }) async {
    final String commentKey = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      _comments.add(commentKey);
      notifyListeners();

      await _firestore.collection(_collection).doc(announcementDocId).update({
        'comments.$commentKey': {
          'userId': userId,
          'userName': userName,
          'userImage': userImage,
          'message': message,
          'postedAt': DateTime.now(),
          'likes': [],
        }
      });

      print('✅ Comment added');
      await fetchComments(announcementDocId);

      print(
          'Comments after adding: ${_commentsByAnnouncement[announcementDocId]}');
    } catch (e) {
      _comments.remove(commentKey);
      notifyListeners();
      print('❌ Error adding comment: $e');
    }
  }

  Future<void> deleteComment(
    String announcementDocId,
    String commentKey, {
    bool isReply = false,
    String? replyKey,
  }) async {
    try {
      await _firestore.collection(_collection).doc(announcementDocId).update({
        'comments.$commentKey': FieldValue.delete(),
      });

      print('✅ Comment deleted');
      await fetchComments(announcementDocId);
    } catch (e) {
      print('❌ Error deleting comment: $e');
    }
  }

  // Set comment count
  setInitialComments(Map<String, dynamic>? comments) {
    if (comments == null) {
      _comments = [];
    } else {
      _comments = comments.values.map((comment) => comment.toString()).toList();
    }
    notifyListeners();
  }

  // Set like count
  void setInitialLikes(List<String> likes) {
    _likes = List.from(likes);
    notifyListeners();
  }

  // void likePost(String id, bool isLike) async {
  //   try {
  //     await _firestore.collection(_collection).doc(id).update({
  //       'likes': isLike
  //           ? FieldValue.arrayUnion([currentUserUid])
  //           : FieldValue.arrayRemove([currentUserUid])
  //     });
  //     await fetchPostDetails();
  //     log("Post liked status: $isLike");
  //     notifyListeners();
  //   } catch (e) {
  //     log("Error liking post: $e");
  //   }
  // }

  void likePostWithFireStoreSyncInBG(String id) {
    if (isLiked) {
      _likes.remove(currentUserUid);
    } else {
      _likes.add(currentUserUid);
    }
    notifyListeners();

    _firestore.collection(_collection).doc(id).update({
      'likes': isLiked
          ? FieldValue.arrayUnion([currentUserUid])
          : FieldValue.arrayRemove([currentUserUid])
    }).catchError((e) {
      notifyListeners();
      log("Like update failed: $e");
    });
  }

  Future<void> addReply({
    required String announcementDocId,
    required String parentCommentKey,
    required String userId,
    required String userName,
    required String userImage,
    required String message,
    required String replyToUsername,
    String? replyToUserId,
  }) async {
    try {
      final replyKey = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore.collection(_collection).doc(announcementDocId).update({
        'comments.$parentCommentKey.replies.$replyKey': {
          'userId': userId,
          'userName': userName,
          'userImage': userImage,
          'message': message,
          'postedAt': DateTime.now(),
          'likes': [],
          'replyTo': replyToUsername,
          'replyToUserId': replyToUserId,
        },
      });

      print('✅ Reply added successfully');
      notifyListeners();
      await fetchComments(announcementDocId);
    } catch (e) {
      print('❌ Error adding reply: $e');
    }
  }

  Future<void> likeReply({
    required String announcementDocId,
    required String parentCommentKey,
    required String replyKey,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(announcementDocId).update({
        'comments.$parentCommentKey.replies.$replyKey.likes':
            FieldValue.arrayUnion([userId]),
      });

      print('✅ Reply liked');
      notifyListeners();
    } catch (e) {
      print('❌ Error liking reply: $e');
    }
  }

  Future<void> unlikeReply({
    required String announcementDocId,
    required String parentCommentKey,
    required String replyKey,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(announcementDocId).update({
        'comments.$parentCommentKey.replies.$replyKey.likes':
            FieldValue.arrayRemove([userId]),
      });

      print('✅ Reply unliked');
      notifyListeners();
    } catch (e) {
      print('❌ Error unliking reply: $e');
    }
  }
}
