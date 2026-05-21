import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/application_bloc.dart';
import '../manager/application_event.dart';
import '../manager/application_state.dart';
import '../widgets/application_card.dart';

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ApplicationBloc>().add(LoadApplications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Applicants')),
      body: BlocConsumer<ApplicationBloc, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ApplicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is ApplicationsLoaded || current is ApplicationLoading,
        builder: (context, state) {
          if (state is ApplicationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return const Center(child: Text('No applicants found.'));
            }
            return ListView.builder(
              itemCount: state.applications.length,
              itemBuilder: (context, index) {
                final app = state.applications[index];
                return ApplicationCard(
                  application: app,
                  isEmployer: true,
                  onStatusChanged: (newStatus) {
                    context.read<ApplicationBloc>().add(
                      UpdateStatusEvent(
                        applicationId: app.id,
                        newStatus: newStatus,
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
