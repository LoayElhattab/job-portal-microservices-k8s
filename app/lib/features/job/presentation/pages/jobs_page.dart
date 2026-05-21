import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../manager/job_bloc.dart';
import '../widgets/job_card.dart';
import '../../../profile/presentation/manager/profile_bloc.dart';
import '../../../profile/presentation/manager/profile_event.dart';
import '../../../profile/presentation/manager/profile_state.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';
import '../../../../core/network/auth_storage.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final AuthStorage _authStorage = AuthStorage();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    context.read<JobBloc>().add(GetJobsEvent());
    context.read<ProfileBloc>().add(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        String role = 'seeker';
        String currentUserId = '';
        String userName = 'User';

        if (profileState is ProfileLoaded) {
          role = profileState.profile.role;
          currentUserId = profileState.profile.id;
          userName = profileState.profile.name;
        }

        final isEmployer = role == 'employer';

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              isEmployer ? 'Manage My Jobs' : 'Jobs Dashboard',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            actions: [
              NotificationBadge(
                onTap: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => context.push('/profile'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _authStorage.deleteToken();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: BlocBuilder<JobBloc, JobState>(
              builder: (context, jobState) {
                if (jobState is JobLoading || profileState is ProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (jobState is JobLoaded) {
                  final allJobs = jobState.jobs;
                  final displayJobs = isEmployer
                      ? allJobs.where((job) => job.employerId == currentUserId).toList()
                      : allJobs;

                  if (displayJobs.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEmployer ? Icons.work_off_outlined : Icons.search_off_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isEmployer
                                    ? "You haven't posted any jobs yet."
                                    : 'No jobs available at the moment.',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              if (isEmployer) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Tap the '+' button below to post your first job.",
                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: displayJobs.length,
                    itemBuilder: (context, index) {
                      final job = displayJobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JobCard(
                          job: job,
                          onTap: () {
                            if (isEmployer) {
                              context.push('/applicants');
                            } else {
                              context.push('/apply', extra: {
                                'jobId': job.id,
                                'employerId': job.employerId,
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                } else if (jobState is JobError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          jobState.message,
                          style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Please wait...'));
              },
            ),
          ),
          floatingActionButton: isEmployer
              ? FloatingActionButton(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  onPressed: () => context.push('/create-job'),
                  child: const Icon(Icons.add, size: 28),
                )
              : null,
        );
      },
    );
  }
}