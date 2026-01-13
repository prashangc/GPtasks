import 'package:flutter/material.dart';

class CustomYearButton extends StatelessWidget {
  final Color color;
  final VoidCallback callback;
  final String value;
  final bool selected;
  const CustomYearButton({
    super.key,
    required this.color,
    required this.value,
    required this.callback,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border:
              Border.all(color: selected ? Colors.green : Colors.transparent),
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 7.0,
              backgroundColor: color,
            ),
            SizedBox(width: 8.0),
            Text(
              value,
              style: TextStyle(
                color: selected ? Colors.green : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
