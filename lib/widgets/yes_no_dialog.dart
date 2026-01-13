import 'package:flutter/material.dart';

class FfYesNoDialogWidget extends StatelessWidget {
  final String infoTitle;
  final String infoMessage;
  final String positiveButton;
  final String negativeButton;
  final Future<void> Function() action;

  const FfYesNoDialogWidget({
    super.key,
    required this.infoTitle,
    required this.infoMessage,
    required this.positiveButton,
    required this.negativeButton,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(infoTitle),
      content: Text(infoMessage),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(negativeButton)),
        TextButton(
          onPressed: () async {
            await action();
          },
          child: Text(positiveButton),
        ),
      ],
    );
  }
}
