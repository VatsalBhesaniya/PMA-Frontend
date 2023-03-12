import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/models/create_milestone.dart';
import 'package:pma/models/milestone.dart';
import 'package:pma/module/edit_milestone/bloc/edit_milestone_bloc.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
import 'package:pma/widgets/text_editor.dart';

class EditMilestoneScreen extends StatefulWidget {
  const EditMilestoneScreen({
    required this.milestoneId,
    super.key,
  });

  final String milestoneId;

  @override
  State<EditMilestoneScreen> createState() => _EditMilestoneScreenState();
}

class _EditMilestoneScreenState extends State<EditMilestoneScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _milestoneTitleController =
      TextEditingController();
  final TextEditingController _complitonDateController =
      TextEditingController();
  final quill.QuillController _contentController =
      quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Milestone'),
      ),
      body: SafeArea(
        child: BlocProvider<EditMilestoneBloc>(
          create: (BuildContext context) => EditMilestoneBloc(
            milestonesRepository: MilestonesRepository(
              dioClient: context.read<DioClient>(),
              httpClient: context.read<HttpClientConfig>(),
            ),
          ),
          child: BlocConsumer<EditMilestoneBloc, EditMilestoneState>(
            listener: (BuildContext context, EditMilestoneState state) {
              state.maybeWhen(
                updateMilestoneSuccess: () {
                  showSnackBar(
                    context: context,
                    theme: theme,
                    message: 'Milestone successfully updated.',
                  );
                  context.pop();
                },
                updateMilestoneFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not update milestone successfully. Please try again.',
                  );
                },
                deleteMilestoneSuccess: () {
                  context.pop();
                },
                deleteMilestoneFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not delete milestone successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen:
                (EditMilestoneState previous, EditMilestoneState current) {
              return current.maybeWhen(
                updateMilestoneSuccess: () => false,
                deleteMilestoneSuccess: () => false,
                deleteMilestoneFailure: (NetworkExceptions error) => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, EditMilestoneState state) {
              return state.maybeWhen(
                initial: () {
                  context.read<EditMilestoneBloc>().add(
                        EditMilestoneEvent.fetchMilestone(
                          milestoneId: int.parse(widget.milestoneId),
                        ),
                      );
                  return const CircularProgressIndicator();
                },
                loadInProgress: () {
                  return const CircularProgressIndicator();
                },
                fetchMilestoneSuccess: (Milestone milestone) {
                  if (milestone.description != null) {
                    _contentController.document = quill.Document.fromJson(
                        milestone.description ?? <dynamic>[]);
                  }
                  _complitonDateController.text =
                      _dateTime(milestone.completionDate);
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          InputField(
                            controller: _milestoneTitleController
                              ..text = milestone.title,
                            hintText: 'Title',
                            borderType:
                                InputFieldBorderType.underlineInputBorder,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDescription(theme: theme),
                          const SizedBox(height: 16),
                          _buildMarkAsCompleted(context, theme, milestone),
                          const SizedBox(height: 16),
                          _buildCompletionDate(
                            context: context,
                            theme: theme,
                            milestone: milestone,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildSaveButton(
                                context: context,
                                theme: theme,
                                milestone: milestone,
                              ),
                              const SizedBox(width: 32),
                              _buildDeleteButton(
                                context: context,
                                theme: theme,
                                milestone: milestone,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDescription({
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: TextEditor(
        controller: _contentController,
      ),
    );
  }

  Widget _buildMarkAsCompleted(
    BuildContext context,
    ThemeData theme,
    Milestone milestone,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Mark as completed',
          style: theme.textTheme.bodyMedium,
        ),
        Checkbox(
          value: milestone.isCompleted,
          onChanged: (bool? value) {
            if (value != null) {
              context.read<EditMilestoneBloc>().add(
                    EditMilestoneEvent.editMilestone(
                      milestone: milestone.copyWith(
                        isCompleted: value,
                      ),
                    ),
                  );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCompletionDate({
    required BuildContext context,
    required ThemeData theme,
    required Milestone milestone,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2050),
        );
        if (selectedDate != null) {
          if (context.mounted) {
            context.read<EditMilestoneBloc>().add(
                  EditMilestoneEvent.editMilestone(
                    milestone: milestone.copyWith(
                      completionDate: selectedDate.toString(),
                    ),
                  ),
                );
          }
        }
      },
      child: InputField(
        controller: _complitonDateController,
        isEnabled: false,
        hintText: 'Select Date',
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please select date';
          }
          return null;
        },
      ),
    );
  }

  String _dateTime(String timestamp) {
    final DateTime datetime = DateTime.parse(timestamp).toLocal();
    return DateFormat('EEEE MMM d, y h:mm a ').format(datetime) +
        datetime.timeZoneName;
  }

  Widget _buildSaveButton({
    required BuildContext context,
    required ThemeData theme,
    required Milestone milestone,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<EditMilestoneBloc>().add(
                  EditMilestoneEvent.updateMilestone(
                    milestoneId: int.parse(widget.milestoneId),
                    milestone: CreateMilestone(
                      projectId: milestone.projectId,
                      title: _milestoneTitleController.text.trim(),
                      description:
                          _contentController.document.toDelta().toJson(),
                      descriptionPlainText:
                          _contentController.document.toPlainText(),
                      isCompleted: milestone.isCompleted,
                      completionDate: milestone.completionDate,
                    ),
                  ),
                );
          }
        },
        child: Text(
          'Save',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.background,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton({
    required BuildContext context,
    required ThemeData theme,
    required Milestone milestone,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          context.read<EditMilestoneBloc>().add(
                EditMilestoneEvent.deleteMilestone(
                  milestoneId: int.parse(widget.milestoneId),
                ),
              );
        },
        child: Text(
          'Delete',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.background,
          ),
        ),
      ),
    );
  }
}
