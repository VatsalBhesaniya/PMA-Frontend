import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/extentions/extensions.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/module/project_detail/bloc/project_detail_bloc.dart';
import 'package:pma/module/project_detail/project_detail_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final TextEditingController _noteTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<ProjectDetailBloc>(
      create: (BuildContext context) => ProjectDetailBloc(
        projectDetailRepository: ProjectDetailRepository(
          dioClient: context.read<DioClient>(),
          httpClient: context.read<HttpClientConfig>(),
        ),
      ),
      child: BlocConsumer<ProjectDetailBloc, ProjectDetailState>(
        listener: (BuildContext context, ProjectDetailState state) {
          state.maybeWhen(
            fetchProjectDetailFailure: (NetworkExceptions error) {},
            orElse: () => null,
          );
        },
        buildWhen: (ProjectDetailState previous, ProjectDetailState current) {
          return current.maybeWhen(
            fetchProjectDetailSuccess: (ProjectDetail projectDetail) => true,
            orElse: () => true,
          );
        },
        builder: (BuildContext context, ProjectDetailState state) {
          return state.maybeWhen(
            initial: () {
              context.read<ProjectDetailBloc>().add(
                    ProjectDetailEvent.fetchProjectDetail(
                      projectId: int.parse(widget.projectId),
                    ),
                  );
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            loadInProgress: () {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            fetchProjectDetailSuccess: (ProjectDetail projectDetail) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Project Detail'),
                  actions: <Widget>[
                    _buildActionButton(
                      context: context,
                      theme: theme,
                      projectDetail: projectDetail,
                    ),
                  ],
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InputField(
                            onChanged: (String value) {},
                            controller: _noteTitleController
                              ..text = projectDetail.title,
                            isEnabled: projectDetail.isEdit,
                            hintText: 'Title',
                            borderType: projectDetail.isEdit
                                ? InputFieldBorderType.underlineInputBorder
                                : InputFieldBorderType.none,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            horizontalContentPadding: 0,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(_dateTime(projectDetail.createdAt)),
                          const SizedBox(height: 16),
                          Text(
                            'Members',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          _buildMembers(projectDetail),
                        ],
                      ),
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

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required ProjectDetail projectDetail,
  }) {
    if (projectDetail.isEdit) {
      return Row(
        children: <Widget>[
          TextButton(
            onPressed: () {
              context.read<ProjectDetailBloc>().add(
                    ProjectDetailEvent.updateProjectDetail(
                      projectDetail: projectDetail.copyWith(
                        isEdit: false,
                      ),
                    ),
                  );
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.lime,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ProjectDetailBloc>().add(
                    ProjectDetailEvent.editProjectDetail(
                      projectDetail: projectDetail.copyWith(
                        isEdit: false,
                      ),
                    ),
                  );
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.lime,
              ),
            ),
          ),
        ],
      );
    }
    return IconButton(
      onPressed: () {
        context.read<ProjectDetailBloc>().add(
              ProjectDetailEvent.editProjectDetail(
                projectDetail: projectDetail.copyWith(
                  isEdit: true,
                ),
              ),
            );
      },
      icon: const Icon(Icons.edit_outlined),
    );
  }

  String _dateTime(String timestamp) {
    final DateTime datetime = DateTime.parse(timestamp).toLocal();
    return DateFormat('EEEE MMM d, y h:mm a ').format(datetime) +
        datetime.timeZoneName;
  }

  Widget _buildMembers(ProjectDetail projectDetail) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projectDetail.members.length,
      itemBuilder: (BuildContext context, int index) {
        final Member member = projectDetail.members[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person_outline_rounded),
          ),
          title: Text(member.user.email),
          subtitle: Text(MemberRole.values[member.role].title),
          trailing: projectDetail.isEdit && member.role != 1
              ? IconButton(
                  onPressed: () {
                    // TODO(Vatsal): Remove member
                  },
                  icon: const Icon(Icons.delete_rounded),
                )
              : null,
        );
      },
    );
  }
}
