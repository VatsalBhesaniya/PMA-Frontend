import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/extentions/extensions.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/project_detail/bloc/project_detail_bloc.dart';
import 'package:pma/module/project_detail/project_detail_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/floating_action_button_animator.dart';
import 'package:pma/widgets/floating_action_button_extended.dart';
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
  final TextEditingController _projectTitleController = TextEditingController();

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
            fetchProjectDetailFailure: (NetworkExceptions error) {
              _buildApiFailureAlert(
                context: context,
                theme: theme,
                error:
                    'Could not delete project successfully. Please try again.',
              );
            },
            removeMemberSuccess: () {
              context.read<ProjectDetailBloc>().add(
                    ProjectDetailEvent.fetchProjectDetail(
                      projectId: int.parse(widget.projectId),
                    ),
                  );
            },
            removeMemberFailure: (NetworkExceptions error) {
              _buildApiFailureAlert(
                context: context,
                theme: theme,
                error:
                    'Could not remove member successfully. Please try again.',
              );
            },
            deleteProjectSuccess: () {
              context.pop();
              context.pop();
              _showSnackBar(context: context, theme: theme);
            },
            deleteProjectFailure: (NetworkExceptions error) {
              _buildDeleteProjectFailureAlert(
                context: context,
                theme: theme,
              );
            },
            orElse: () => null,
          );
        },
        buildWhen: (ProjectDetailState previous, ProjectDetailState current) {
          return current.maybeWhen(
            fetchProjectDetailSuccess: (ProjectDetail projectDetail) => true,
            removeMemberSuccess: () => false,
            removeMemberFailure: (NetworkExceptions error) => false,
            deleteProjectSuccess: () => false,
            deleteProjectFailure: (NetworkExceptions error) => false,
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
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButtonAnimator: NoScalingAnimation(),
                floatingActionButton: FloatingActionButtonExtended(
                  onPressed: () {
                    _showDeleteProjectConfirmDialog(
                      context: context,
                      theme: theme,
                      projectId: projectDetail.id,
                    );
                  },
                  backgroundColor: theme.colorScheme.error,
                  labelText: 'Delete Project',
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildProjectTitle(
                            context: context,
                            theme: theme,
                            projectDetail: projectDetail,
                          ),
                          const SizedBox(height: 16),
                          Text(_dateTime(projectDetail.createdAt)),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              context.goNamed(
                                RouteConstants.milestones,
                                params: <String, String>{
                                  'projectId': widget.projectId,
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const <Widget>[
                                Text('Milestones'),
                                Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMembers(
                            context: context,
                            theme: theme,
                            projectDetail: projectDetail,
                          ),
                          const SizedBox(height: 48),
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
          IconButton(
            onPressed: () {
              context.read<ProjectDetailBloc>().add(
                    ProjectDetailEvent.updateProjectDetail(
                      projectDetail: projectDetail.copyWith(
                        isEdit: false,
                      ),
                    ),
                  );
            },
            icon: const Icon(Icons.done_rounded),
          ),
          IconButton(
            onPressed: () {
              context.read<ProjectDetailBloc>().add(
                    ProjectDetailEvent.editProjectDetail(
                      projectDetail: projectDetail.copyWith(
                        isEdit: false,
                      ),
                    ),
                  );
            },
            icon: const Icon(Icons.close_rounded),
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

  Widget _buildProjectTitle({
    required BuildContext context,
    required ThemeData theme,
    required ProjectDetail projectDetail,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InputField(
            onChanged: (String value) {},
            controller: _projectTitleController..text = projectDetail.title,
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
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          context: context,
          theme: theme,
          projectDetail: projectDetail,
        ),
      ],
    );
  }

  Widget _buildMembers({
    required BuildContext context,
    required ThemeData theme,
    required ProjectDetail projectDetail,
  }) {
    final User currentUser = context.read<User>();
    final Member owner = projectDetail.members
        .where((Member member) => member.role == MemberRole.owner.index + 1)
        .first;
    final bool isOwner = currentUser.id == owner.userId;
    return Column(
      children: <Widget>[
        _buildMembersTitle(
          theme: theme,
          context: context,
          isOwner: isOwner,
        ),
        _buildMembersList(
          context: context,
          theme: theme,
          projectDetail: projectDetail,
          isOwner: isOwner,
        ),
      ],
    );
  }

  Row _buildMembersTitle({
    required ThemeData theme,
    required BuildContext context,
    required bool isOwner,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Members',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (isOwner)
          TextButton.icon(
            onPressed: () {
              context.goNamed(
                RouteConstants.inviteMembers,
                params: <String, String>{
                  'projectId': widget.projectId,
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Invite'),
          ),
      ],
    );
  }

  Widget _buildMembersList({
    required BuildContext context,
    required ThemeData theme,
    required ProjectDetail projectDetail,
    required bool isOwner,
  }) {
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
          subtitle: Text(MemberRole.values[member.role - 1].title),
          trailing: isOwner && member.role != 1
              ? IconButton(
                  onPressed: () {
                    context.read<ProjectDetailBloc>().add(
                          ProjectDetailEvent.removeMember(
                            projectId: member.projectId,
                            userId: member.userId,
                          ),
                        );
                  },
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: theme.colorScheme.error,
                  ),
                )
              : null,
        );
      },
    );
  }

  void _showDeleteProjectConfirmDialog({
    required BuildContext context,
    required ThemeData theme,
    required int projectId,
  }) {
    showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Confirm',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this project?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<ProjectDetailBloc>().add(
                      ProjectDetailEvent.deleteProject(projectId: projectId),
                    );
                Navigator.pop(ctx);
              },
              child: Text(
                'OK',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar({
    required BuildContext context,
    required ThemeData theme,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: theme.colorScheme.surface,
        content: Text(
          'Project successfully deleted',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _buildDeleteProjectFailureAlert({
    required BuildContext context,
    required ThemeData theme,
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
          content: const Text(
            'Could not delete a project successfully. Please try again.',
          ),
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