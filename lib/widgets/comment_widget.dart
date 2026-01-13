import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/providers/comment_provider.dart';

import '../models/comment.dart';
import '../utils/date_utils.dart';
import 'web_view_aware.dart';
import 'yes_no_dialog.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Function(String msg, String key) onReply;
  final Function(bool)? onLike;
  final CommentProvider commentProvider;
  final String commentKey;

  const CommentWidget({
    required this.comment,
    required this.onReply,
    required this.onLike,
    required this.commentProvider,
    required this.commentKey,
    super.key,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final List<String> likes = widget.comment.likes;
    final bool isLiked = likes.contains(FirebaseAuth.instance.currentUser!.uid);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.comment.userImage.isNotEmpty
                      ? Image.network(widget.comment.userImage,
                          fit: BoxFit.cover)
                      : _buildAvatarFallback(widget.comment.userName))),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.comment.userName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(widget.comment.message,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  )),
              const SizedBox(height: 8),
              Row(children: [
                GestureDetector(
                  onTap: () async {
                    await widget.commentProvider.toggleCommentLike(
                      announcementDocId: "r7rBmg7ueno3PCNdcLxz",
                      commentKey: widget.comment.commentKey,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      isLiked: isLiked,
                    );
                    widget.onLike?.call(!isLiked);
                  },
                  child: isLiked
                      ? const Icon(Icons.favorite, color: Colors.red, size: 15)
                      : const Icon(Icons.favorite_outline, size: 14),
                ),
                const SizedBox(width: 4),
                Text(widget.comment.likes.length.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 11)),
                const SizedBox(width: 15),
                Text(timeAgo(widget.comment.postedAt),
                    style: const TextStyle(color: Colors.black, fontSize: 11)),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    widget.onReply(
                        widget.comment.userName, widget.comment.commentKey);
                  },
                  child: const Text('Reply',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
            ]),
          ),
          GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return Dialog(
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      child: WebViewAware(
                          child: FfYesNoDialogWidget(
                        infoTitle: "Warning",
                        infoMessage: "Do you sure want to delete ?",
                        positiveButton: "Yes",
                        negativeButton: "No",
                        action: () async {
                          await widget.commentProvider.deleteComment(
                              "r7rBmg7ueno3PCNdcLxz",
                              widget.comment.commentKey);
                          Navigator.of(dialogContext).pop();
                        },
                      )),
                    );
                  },
                );
              },
              child: Icon(Icons.delete, color: Colors.red[300], size: 20)),
        ]),
        if (widget.comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 52),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!_showReplies)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showReplies = true;
                    });
                  },
                  child: Row(children: [
                    Text('View ${widget.comment.replies.length} reply',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    const Icon(Icons.expand_more, size: 16),
                  ]),
                ),
              if (_showReplies)
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        widget.comment.replies.asMap().entries.map((entry) {
                      final reply = entry.value;
                      final isLiked = reply.likes
                          .contains(FirebaseAuth.instance.currentUser!.uid);
                      final isLast =
                          entry.key == widget.comment.replies.length - 1;
                      return Padding(
                        padding:
                            EdgeInsets.only(top: 12, bottom: isLast ? 0 : 0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: reply.userImage.isNotEmpty
                                          ? Image.network(reply.userImage,
                                              fit: BoxFit.cover)
                                          : _buildAvatarFallback(
                                              reply.userName))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Row(children: [
                                      Text(reply.userName,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_right_outlined,
                                          size: 18),
                                      const SizedBox(width: 4),
                                      Text(widget.comment.userName,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(reply.message,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await widget.commentProvider
                                              .likeReply(
                                                  announcementDocId:
                                                      "r7rBmg7ueno3PCNdcLxz",
                                                  parentCommentKey:
                                                      widget.comment.commentKey,
                                                  replyKey: reply.commentKey,
                                                  userId: FirebaseAuth.instance
                                                      .currentUser!.uid);
                                        },
                                        child: isLiked
                                            ? const Icon(Icons.favorite,
                                                size: 14, color: Colors.red)
                                            : const Icon(Icons.favorite_outline,
                                                size: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(reply.likes.length.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11)),
                                      const SizedBox(width: 12),
                                      Text(timeAgo(reply.postedAt),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11)),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                          onTap: () {
                                            widget.onReply(reply.userName,
                                                reply.commentKey);
                                          },
                                          child: const Text('Reply',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ]),
                                    const SizedBox(height: 10),
                                  ])),
                            ]),
                      );
                    }).toList()),
            ]),
          ),
      ]),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initials = (name.isNotEmpty ? name[0] : 'U').toUpperCase();
    return Container(
      color: const Color(0xFF5CB85C),
      child: Center(
          child: Text(initials,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600))),
    );
  }
}
