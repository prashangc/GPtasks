import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/providers/comment_provider.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../utils/date_utils.dart';
import 'comment_bottom_sheet.dart';

class AnnouncementUI extends StatelessWidget {
  const AnnouncementUI({
    super.key,
    required this.announcementModel,
  });

  final AnnouncementModel announcementModel;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final commentProvider = context.watch<CommentProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 1)),
              clipBehavior: Clip.hardEdge,
            ),
            const SizedBox(width: 7),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Main Post",
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w600)),
              Row(children: [
                Text("${announcementModel.postedBy}, ",
                    style: const TextStyle(fontSize: 10)),
                Text(formatDateTime(announcementModel.posted),
                    style: const TextStyle(fontSize: 10)),
              ]),
            ]),
          ]),
          Row(children: [
            GestureDetector(
                onTap: () {}, child: const Icon(Icons.edit, size: 18)),
            const SizedBox(width: 25),
            GestureDetector(
                onTap: () {},
                child: const Icon(Icons.delete, size: 18, color: Colors.red)),
          ])
        ]),
        const SizedBox(height: 8),

        Text(announcementModel.title,
            style:
                const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
        Text(announcementModel.message, style: const TextStyle(fontSize: 13.5)),
        if (announcementModel.imgurl.isNotEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: CachedNetworkImage(
                  imageUrl: announcementModel.imgurl,
                  width: double.infinity,
                  fit: BoxFit.cover),
            ),
          ),

        // Like & Comment row
        SizedBox(
          height: 40,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: commentProvider.streamPost(announcementModel.docID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final data = snapshot.data!.data()!;
              log(data.toString());
              final likes = List<String>.from(data['likes'] ?? []);
              final Map<String, dynamic> commentsMap =
                  Map<String, dynamic>.from(data['comments'] ?? {});
              final int commentsCount = commentsMap.length;
              final isLiked = likes.contains(currentUser.uid);

              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      commentProvider.likePostWithFireStoreSyncInBG(
                        id: announcementModel.docID,
                        isLiked: isLiked,
                      );
                    },
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isLiked
                              ? const Icon(Icons.thumb_up,
                                  size: 20, key: ValueKey('liked'))
                              : const Icon(Icons.thumb_up_off_alt,
                                  size: 20, key: ValueKey('unliked')),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          likes.length.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      showCommentBottomSheet(
                        commentProvider: commentProvider,
                        context: context,
                        announcementId: announcementModel.docID,
                        commentsStream: commentProvider
                            .streamComments(announcementModel.docID),
                        onCommentSubmit:
                            (String commentText, String key) async {
                          await commentProvider.addComment(
                            announcementDocId: announcementModel.docID,
                            userId: currentUser.uid,
                            userName: currentUser.displayName ??
                                currentUser.email ??
                                'User',
                            userImage: currentUser.photoURL ?? '',
                            message: commentText,
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.comment, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          commentsCount.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}
