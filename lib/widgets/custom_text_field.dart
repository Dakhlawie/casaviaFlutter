import 'package:flutter/material.dart';
import 'app_text.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextField(
        readOnly: readOnly,
        controller: controller,
        decoration: InputDecoration(
          label: AppText.small(label, fontSize: 14),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontWeight: FontWeight.bold),
        onTap: onTap,
      ),
    );
  }
}
