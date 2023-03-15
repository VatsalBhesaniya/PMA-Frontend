import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router_flow/go_router_flow.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/models/roadmap.dart';
import 'package:pma/module/milestones/bloc/milestones_bloc.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/text_editor.dart';

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
          dioConfig: context.read<DioConfig>(),
          dio: context.read<Dio>(),
        ),
      ),
      child: BlocConsumer<MilestonesBloc, MilestonesState>(
        listener: (BuildContext context, MilestonesState state) {
          state.maybeWhen(
            fetchMilestoneFailure: (NetworkExceptions error) {
              pmaAlertDialog(
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
              return const Scaffold(
                body: SafeArea(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            },
            loadInProgress: () {
              return const Scaffold(
                body: SafeArea(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            },
            fetchMilestoneSuccess: (Roadmap roadmap) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Milestones'),
                ),
                floatingActionButton:
                    roadmap.currentUserRole == MemberRole.guest.index + 1
                        ? null
                        : _buildFloatingActionButton(
                            context: context,
                            theme: theme,
                          ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                body: SafeArea(
                  child: roadmap.milestones.isEmpty
                      ? Center(
                          child: Text(
                            'No milestones added yet.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : _buildStepper(
                          context: context,
                          theme: theme,
                          roadmap: roadmap,
                        ),
                ),
              );
            },
            fetchMilestoneFailure: (NetworkExceptions error) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Text(
                      'Something went wrong! Please try again.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            },
            orElse: () => const SizedBox(),
          );
        },
      ),
    );
  }

  Widget _buildStepper({
    required BuildContext context,
    required ThemeData theme,
    required Roadmap roadmap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Stepper(
        currentStep: _index,
        onStepTapped: (int index) {
          setState(() {
            _index = index;
          });
        },
        controlsBuilder: (_, ControlsDetails details) {
          if (roadmap.currentUserRole == MemberRole.guest.index + 1) {
            return const SizedBox();
          }
          return Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    final List<Milestone> roadmapMilestones =
                        List<Milestone>.from(roadmap.milestones);
                    roadmapMilestones.sort(
                      (Milestone a, Milestone b) =>
                          a.completionDate.compareTo(b.completionDate),
                    );
                    await context.pushNamed<void>(
                      RouteConstants.editMilestone,
                      params: <String, String>{
                        'projectId': widget.projectId,
                        'milestoneId':
                            roadmapMilestones[details.stepIndex].id.toString(),
                      },
                    );
                    if (mounted) {
                      _index = 0;
                      context.read<MilestonesBloc>().add(
                            MilestonesEvent.fetchMilestones(
                              projectId: int.parse(widget.projectId),
                            ),
                          );
                    }
                  },
                  child: Text(
                    'Edit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.background,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        steps: _buildSteps(
          theme: theme,
          milestones: roadmap.milestones,
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return FloatingActionButton(
      onPressed: () async {
        await context.pushNamed(
          RouteConstants.createMilestone,
          params: <String, String>{
            'projectId': widget.projectId,
          },
        );
        if (mounted) {
          _index = 0;
          context.read<MilestonesBloc>().add(
                MilestonesEvent.fetchMilestones(
                  projectId: int.parse(widget.projectId),
                ),
              );
        }
      },
      child: Icon(
        Icons.add,
        color: theme.colorScheme.primary,
      ),
    );
  }

  List<Step> _buildSteps({
    required ThemeData theme,
    required List<Milestone> milestones,
  }) {
    final List<Milestone> roadmapMilestones = List<Milestone>.from(milestones);
    roadmapMilestones.sort(
      (Milestone a, Milestone b) =>
          a.completionDate.compareTo(b.completionDate),
    );
    final List<Step> steps = <Step>[];
    for (final Milestone milestone in roadmapMilestones) {
      final quill.QuillController controller = quill.QuillController.basic();
      if (milestone.description != null) {
        controller.document =
            quill.Document.fromJson(milestone.description ?? <dynamic>[]);
      }
      steps.add(
        Step(
          isActive: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                milestone.title,
              ),
              if (milestone.isCompleted)
                Icon(
                  Icons.done_rounded,
                  color: theme.colorScheme.outline,
                )
            ],
          ),
          subtitle: Text(
            _dateTime(milestone.completionDate),
          ),
          content: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: TextEditor(
              controller: controller,
              readOnly: true,
              showCursor: false,
            ),
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
}
