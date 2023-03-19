import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:go_router_flow/go_router_flow.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/models/create_milestone.dart';
import 'package:pma/module/create_milestone/bloc/create_milestone_bloc.dart';
import 'package:pma/module/milestones/milestones_repository.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';
import 'package:pma/widgets/text_editor.dart';

class CreateMilestoneScreen extends StatefulWidget {
  const CreateMilestoneScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  State<CreateMilestoneScreen> createState() => _CreateMilestoneScreenState();
}

class _CreateMilestoneScreenState extends State<CreateMilestoneScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _milestoneTitleController =
      TextEditingController();
  final TextEditingController _complitonDateController =
      TextEditingController();
  final QuillController _contentController = QuillController.basic();
  late DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Milestone'),
      ),
      body: SafeArea(
        child: BlocProvider<CreateMilestoneBloc>(
          create: (BuildContext context) => CreateMilestoneBloc(
            milestonesRepository: MilestonesRepository(
              dioConfig: context.read<DioConfig>(),
              dio: context.read<Dio>(),
            ),
          ),
          child: BlocConsumer<CreateMilestoneBloc, CreateMilestoneState>(
            listener: (BuildContext context, CreateMilestoneState state) {
              state.maybeWhen(
                createMilestoneSuccess: () {
                  showSnackBar(
                    context: context,
                    theme: theme,
                    message: 'Milestone successfully created.',
                  );
                  context.pop();
                },
                createMilestoneFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not create milestone successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen:
                (CreateMilestoneState previous, CreateMilestoneState current) {
              return current.maybeWhen(
                createMilestoneSuccess: () => false,
                createMilestoneFailure: (NetworkExceptions error) => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, CreateMilestoneState state) {
              return state.maybeWhen(
                loadInProgress: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                initial: () {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            InputField(
                              controller: _milestoneTitleController,
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
                            _buildCreateButton(
                              context: context,
                              theme: theme,
                            ),
                          ],
                        ),
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

  ElevatedButton _buildCreateButton({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (selectedDate == null) {
            pmaAlertDialog(
              context: context,
              theme: theme,
              error: 'Please select date of completion.',
            );
          }
          context.read<CreateMilestoneBloc>().add(
                CreateMilestoneEvent.createMilestone(
                  milestone: CreateMilestone(
                    projectId: int.parse(widget.projectId),
                    title: _milestoneTitleController.text.trim(),
                    description: _contentController.document.toDelta().toJson(),
                    descriptionPlainText:
                        _contentController.document.toPlainText(),
                    isCompleted: false,
                    completionDate: selectedDate.toString(),
                  ),
                ),
              );
        }
      },
      child: const Text('Create'),
    );
  }
}
