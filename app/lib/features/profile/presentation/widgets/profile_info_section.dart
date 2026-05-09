import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final Widget content;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.content
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const Divider(height: 20),
            content,
          ],
        ),
      ),
    );
  }
}