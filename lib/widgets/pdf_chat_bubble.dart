import 'package:flutter/material.dart';

class PDFChatBubble extends StatelessWidget {
  final String roomName;
  final VoidCallback? onTap;
  final bool isUser;

  const PDFChatBubble({
    super.key,
    required this.roomName,
    this.onTap,
    this.isUser = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.green.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(150),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 15,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roomName,
                      style: TextStyle(
                        color: isUser ? Colors.black : Colors.green,
                        fontSize: 14,
                        fontWeight: isUser ? FontWeight.w400 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text("File Size : 200 KB",
                        style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.black54 : Colors.green)),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.download,
                color: Colors.grey,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

