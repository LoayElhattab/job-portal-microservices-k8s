import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/application_bloc.dart';
import '../manager/application_event.dart';
import '../manager/application_state.dart';
import '../widgets/application_card.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ApplicationBloc>().add(LoadApplications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return const Center(
                child: Text('You have not applied to any jobs yet.'),
              );
            }
            return ListView.builder(
              itemCount: state.applications.length,
              itemBuilder: (context, index) {
                return ApplicationCard(
                  application: state.applications[index],
                  isEmployer: false,
                );
              },
            );
          } else if (state is ApplicationError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
