import 'package:flutter/material.dart';
import '../../domain/entities/profile.dart';

class ProfileHeaderCard extends StatelessWidget {
  final Profile user;
  const ProfileHeaderCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
                user.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            Text(user.email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                user.role.toUpperCase(),
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}