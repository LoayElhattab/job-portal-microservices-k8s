import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/profile_bloc.dart';
import '../manager/profile_event.dart';
import '../manager/profile_state.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // نداء الداتا عند فتح الصفحة
    context.read<ProfileBloc>().add(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            final user = state.profile;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _showEditDialog(context, user),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(user.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    background: Container(color: Colors.blueAccent),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ProfileHeaderCard(user: user),
                      ProfileInfoSection(
                        title: "About Me",
                        content: Text(
                            user.bio,
                            style: const TextStyle(height: 1.5, color: Colors.black87)
                        ),
                      ),
                      if (user.role == 'seeker')
                        ProfileInfoSection(
                          title: "Skills",
                          content: _buildSkillsWrap(user.skills),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is ProfileError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const Center(child: Text("Start loading profile..."));
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, user) {
    final nameController = TextEditingController(text: user.name);
    final bioController = TextEditingController(text: user.bio);
    final skillsController = TextEditingController(text: user.skills.join(', '));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'About Me'),
                    maxLines: 3,
                  ),
                  if (user.role == 'seeker') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills (e.g. Flutter, Node.js, AWS)',
                        hintText: 'Flutter, Node.js, AWS',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  List<String>? skillsList;
                  if (user.role == 'seeker') {
                    final text = skillsController.text.trim();
                    skillsList = text.isEmpty
                        ? <String>[]
                        : text.split(',').map((e) => e.trim()).toList();
                  }
                  context.read<ProfileBloc>().add(
                        UpdateProfileEvent(
                          name: nameController.text.trim(),
                          bio: bioController.text.trim(),
                          skills: skillsList,
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // الـ UI الخاص بالـ Skills اللي طلبته باللون الأزرق
  Widget _buildSkillsWrap(List<String> skills) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) => Chip(
        label: Text(
            skill,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600
            )
        ),
        backgroundColor: Colors.blue[50],
        side: const BorderSide(color: Colors.blue, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      )).toList(),
    );
  }
}