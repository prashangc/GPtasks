import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/providers/comment_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/comment.dart';
import 'comment_widget.dart';

// Show comment bottom sheet helper
void showCommentBottomSheet({
  required BuildContext context,
  required String announcementId,
  required Stream<List<Comment>> commentsStream,
  required Function(String msg, String key) onCommentSubmit,
  required CommentProvider commentProvider,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color.fromARGB(255, 223, 220, 220),
    builder: (context) => CommentBottomSheet(
      commentProvider: commentProvider,
      announcementId: announcementId,
      commentsStream: commentsStream,
      onCommentSubmit: onCommentSubmit,
      onLike: (test) {},
    ),
  );
}

class CommentBottomSheet extends StatefulWidget {
  final String announcementId;
  final Stream<List<Comment>> commentsStream;
  final Function(String test, String replyKey) onCommentSubmit;
  final Function(bool) onLike;
  final CommentProvider commentProvider;

  const CommentBottomSheet({
    required this.announcementId,
    required this.commentsStream,
    required this.onCommentSubmit,
    required this.onLike,
    required this.commentProvider,
    super.key,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  late TextEditingController _commentController;
  String? _replyingTo;
  String? _replyKey;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;
    widget.onCommentSubmit(_commentController.text, _replyKey ?? "");
    _commentController.clear();
    setState(() {
      _replyingTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.spaceGrotesk(),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        StreamBuilder<List<Comment>>(
          stream: widget.commentsStream,
          builder: (context, snapshot) {
            final commentCount = snapshot.data?.length ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('$commentCount Comments',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: widget.commentsStream,
            builder: (context, snapshot) {
              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return Center(
                    child: Text('No comments yet. Be the first to comment!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor)));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: comments.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return CommentWidget(
                    commentKey: comments[index].commentKey,
                    commentProvider: widget.commentProvider,
                    comment: comments[index],
                    onLike: (isLiked) {
                      widget.onLike(isLiked);
                    },
                    onReply: (userName, key) {
                      setState(() {
                        _replyingTo = userName;
                        _replyKey = key;
                      });
                      _commentController.clear();
                    },
                  );
                },
              );
            },
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
        Padding(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_replyingTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Text('Replying to $_replyingTo',
                      style:
                          const TextStyle(color: Colors.black, fontSize: 12)),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyingTo = null;
                        });
                      },
                      child: const Icon(Icons.close, size: 16)),
                ]),
              ),
            Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12)),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (_replyingTo != null) {
                    widget.commentProvider.addReply(
                      announcementDocId: 'r7rBmg7ueno3PCNdcLxz',
                      parentCommentKey: _replyKey ?? "",
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      userName:
                          FirebaseAuth.instance.currentUser!.displayName ??
                              FirebaseAuth.instance.currentUser!.email ??
                              'User',
                      userImage: '',
                      message: _commentController.text,
                      replyToUsername: _replyingTo ?? "",
                    );
                    _commentController.clear();
                    setState(() {
                      _replyingTo = null;
                    });
                  } else {
                    _submitComment();
                  }
                },
                child:
                    const Icon(Icons.send, size: 20, color: Color(0xFF5CB85C)),
              ),
            ]),
            const SizedBox(height: 20),
          ]),
        ),
      ]),
    );
  }
}
