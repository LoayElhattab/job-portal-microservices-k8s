import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../manager/application_bloc.dart';
import '../manager/application_event.dart';
import '../manager/application_state.dart';

class ApplyPage extends StatefulWidget {
  final String jobId;
  final String employerId;

  const ApplyPage({super.key, required this.jobId, required this.employerId});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final _coverLetterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Application')),
      body: BlocListener<ApplicationBloc, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.pop(); // Go back to the job details page
          } else if (state is ApplicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cover Letter (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _coverLetterController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Tell the employer why you are a great fit...',
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    context.read<ApplicationBloc>().add(
                      ApplyForJobEvent(
                        jobId: widget.jobId,
                        employerId: widget.employerId,
                        coverLetter: _coverLetterController.text,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Submit Application',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
