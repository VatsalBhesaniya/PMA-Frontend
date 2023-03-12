import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:intl/intl.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/extentions/extensions.dart';
import 'package:pma/models/member.dart';
import 'package:pma/models/project_detail.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/project_detail/bloc/project_detail_bloc.dart';
import 'package:pma/module/project_detail/project_detail_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/floating_action_button_extended.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/snackbar.dart';

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
        ),
      ),
      child: BlocConsumer<ProjectDetailBloc, ProjectDetailState>(
        listener: (BuildContext context, ProjectDetailState state) {
          state.maybeWhen(
            fetchProjectDetailFailure: (NetworkExceptions error) {
              pmaAlertDialog(
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
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not remove member successfully. Please try again.',
              );
            },
            deleteProjectSuccess: () {
              context.pop();
              context.pop();
              showSnackBar(
                context: context,
                theme: theme,
                message: 'Project successfully deleted',
              );
            },
            deleteProjectFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not delete project successfully. Please try again.',
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
              final User currentUser = context.read<User>();
              final Member owner = projectDetail.members
                  .where((Member member) =>
                      member.role == MemberRole.owner.index + 1)
                  .first;
              final bool isOwner = currentUser.id == owner.userId;
              final Member? member = projectDetail.members.firstWhereOrNull(
                  (Member member) => member.role == MemberRole.guest.index + 1);
              final bool isGuest =
                  member == null || currentUser.id == member.userId;
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Project Detail'),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
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
                  labelStyle: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.background,
                  ),
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
                            isOwner: isOwner,
                          ),
                          const SizedBox(height: 16),
                          Text(_dateTime(projectDetail.createdAt)),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              context.goNamed(
                                RouteConstants.milestones,
                                params: <String, String>{
                                  'projectId': widget.projectId,
                                },
                                extra: isGuest,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Milestones',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.outline,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),
                          _buildMembers(
                            context: context,
                            theme: theme,
                            projectDetail: projectDetail,
                            owner: owner,
                            isOwner: isOwner,
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
                        title: _projectTitleController.text.trim(),
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
    required bool isOwner,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InputField(
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
        if (isOwner) const SizedBox(width: 16),
        if (isOwner)
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
    required Member owner,
    required bool isOwner,
  }) {
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
          owner: owner,
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
            style: theme.textTheme.bodyLarge,
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
            label: const Text('Add'),
          ),
      ],
    );
  }

  Widget _buildMembersList({
    required BuildContext context,
    required ThemeData theme,
    required ProjectDetail projectDetail,
    required Member owner,
    required bool isOwner,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 1,
          indent: 16,
          endIndent: 20,
        );
      },
      itemCount: projectDetail.members.length,
      itemBuilder: (BuildContext context, int index) {
        final Member member = projectDetail.members[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.outline,
            child: Icon(
              Icons.person_outline_rounded,
              color: theme.colorScheme.background,
            ),
          ),
          title: Text(
            member.user.username,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: !isOwner || owner.userId == member.userId
              ? Text(MemberRole.values[member.role - 1].title)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: DropdownButton<MemberRole>(
                        isDense: true,
                        dropdownColor: theme.colorScheme.outline,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        value: MemberRole.values[member.role - 1],
                        onChanged: (MemberRole? value) {
                          final MemberRole? role = value;
                          if (role != null) {
                            final List<Member> updatedMembers = <Member>[];
                            for (Member projectMember
                                in projectDetail.members) {
                              if (projectMember.userId == member.userId) {
                                projectMember = projectMember.copyWith(
                                  role: role.index + 1,
                                );
                              }
                              updatedMembers.add(projectMember);
                            }
                            context.read<ProjectDetailBloc>().add(
                                  ProjectDetailEvent.updateProjectDetail(
                                    projectDetail: projectDetail.copyWith(
                                      members: updatedMembers,
                                    ),
                                  ),
                                );
                          }
                        },
                        items: <DropdownMenuItem<MemberRole>>[
                          DropdownMenuItem<MemberRole>(
                            value: MemberRole.admin,
                            child: Text(
                              MemberRole.admin.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.background,
                              ),
                            ),
                          ),
                          DropdownMenuItem<MemberRole>(
                            value: MemberRole.member,
                            child: Text(
                              MemberRole.member.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.background,
                              ),
                            ),
                          ),
                          DropdownMenuItem<MemberRole>(
                            value: MemberRole.guest,
                            child: Text(
                              MemberRole.guest.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.background,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          trailing: !isOwner || member.role == 1
              ? null
              : IconButton(
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
                ),
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
}
