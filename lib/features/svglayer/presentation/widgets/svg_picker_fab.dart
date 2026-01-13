import 'package:flutter/material.dart';

class SvgPickerFab extends StatelessWidget {
  final VoidCallback onPressed;
  const SvgPickerFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: const Text('Pick SVG'),
    );
  }
}
