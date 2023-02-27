import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/module/milestones/milestones/milestones_bloc.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<MilestonesBloc>(
      create: (BuildContext context) => MilestonesBloc(
        milestonesRepository: MilestonesRepository(
          dioClient: context.read<DioClient>(),
          httpClient: context.read<HttpClientConfig>(),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Milestones'),
        ),
        floatingActionButton: _buildFloatingActionButton(
          context: context,
          theme: theme,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: SafeArea(
          child: BlocConsumer<MilestonesBloc, MilestonesState>(
            listener: (BuildContext context, MilestonesState state) {
              state.maybeWhen(
                fetchMilestoneFailure: (NetworkExceptions error) {
                  _buildApiFailureAlert(
                    context: context,
                    theme: theme,
                    error:
                        'Could not fetch milestones successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            builder: (BuildContext context, MilestonesState state) {
              return state.maybeWhen(
                initial: () {
                  context.read<MilestonesBloc>().add(
                        MilestonesEvent.fetchMilestones(
                          projectId: int.parse(widget.projectId),
                        ),
                      );
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                loadInProgress: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                fetchMilestoneSuccess: (List<Milestone> milestones) {
                  return Stepper(
                    currentStep: _index,
                    onStepCancel: () {
                      if (_index > 0) {
                        setState(() {
                          _index -= 1;
                        });
                      }
                    },
                    onStepContinue: () {
                      if (_index <= 0) {
                        setState(() {
                          _index += 1;
                        });
                      }
                    },
                    onStepTapped: (int index) {
                      setState(() {
                        _index = index;
                      });
                    },
                    // controlsBuilder: (BuildContext context, ControlsDetails details) {
                    //   return Container();
                    // },
                    steps: _buildSteps(
                      milestones: milestones,
                    ),
                  );
                },
                fetchMilestoneFailure: (NetworkExceptions error) {
                  return const Center(
                      child: Text('Something went wrong! Please try again.'));
                },
                orElse: () => const SizedBox(),
              );
            },
          ),
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return FloatingActionButton(
      onPressed: () {
        
      },
      child: const Icon(Icons.add),
    );
  }

  List<Step> _buildSteps({
    required List<Milestone> milestones,
  }) {
    final List<Step> steps = <Step>[];
    for (final Milestone milestone in milestones) {
      steps.add(
        Step(
          isActive: true,
          state: milestone.isCompleted ? StepState.complete : StepState.indexed,
          title: Text(milestone.title),
          subtitle: Text(_dateTime(milestone.completionDate)),
          content: Container(
            alignment: Alignment.centerLeft,
            child: Text(milestone.description),
          ),
        ),
      );
    }
    return steps;
  }

  String _dateTime(String timestamp) {
    final DateTime datetime = DateTime.parse(timestamp).toLocal();
    return DateFormat('EEEE MMM d, y h:mm a ').format(datetime) +
        datetime.timeZoneName;
  }

  void _buildApiFailureAlert({
    required BuildContext context,
    required ThemeData theme,
    required String error,
  }) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Alert',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          content: Text(error),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: Text(
                  'OK',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
