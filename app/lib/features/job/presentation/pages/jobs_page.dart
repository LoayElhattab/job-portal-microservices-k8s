import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/job_bloc.dart';
import '../widgets/job_card.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(GetJobsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Jobs Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          if (state is JobLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JobLoaded) {
            if (state.jobs.isEmpty) {
              return const Center(child: Text('No jobs available at the moment.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                return JobCard(
                  job: state.jobs[index],
                  onTap: () {
                    // Navigate to Job Details Page
                  },
                );
              },
            );
          } else if (state is JobError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<JobBloc>().add(GetJobsEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}