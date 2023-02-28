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
  late DateTime? selectedDate;

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Milestone successfully updated.'),
                    ),
                  );
                  context.pop();
                },
                updateMilestoneFailure: (NetworkExceptions error) {
                  _buildApiFailureAlert(
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
                  _buildApiFailureAlert(
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
                          _buildCompletionDate(
                            context: context,
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildUpdateButton(
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

  Widget _buildCompletionDate({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: () async {
        selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2050),
        );
        _complitonDateController.text = _dateTime(selectedDate.toString());
      },
      child: InputField(
        onChanged: (String value) {},
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

  Widget _buildUpdateButton({
    required BuildContext context,
    required ThemeData theme,
    required Milestone milestone,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (selectedDate == null) {
              _buildApiFailureAlert(
                context: context,
                theme: theme,
                error: 'Please select date of completion.',
              );
            }
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
                      completionDate: selectedDate != null
                          ? selectedDate.toString()
                          : milestone.completionDate,
                    ),
                  ),
                );
          }
        },
        child: const Text('Save'),
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
        child: const Text('Delete'),
      ),
    );
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
