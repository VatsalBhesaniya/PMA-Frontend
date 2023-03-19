import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/project/project_repository.dart';
import 'package:pma/module/select_members/bloc/select_members_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/search_bar.dart';

class SelectMembersScreen extends StatefulWidget {
  const SelectMembersScreen({
    super.key,
    required this.projectId,
    required this.taskId,
    required this.buttonText,
    required this.onSelectUsers,
  });

  final int projectId;
  final int taskId;
  final String buttonText;
  final Function(List<SearchUser>) onSelectUsers;

  @override
  State<SelectMembersScreen> createState() => _SelectMembersScreenState();
}

class _SelectMembersScreenState extends State<SelectMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<SelectMembersBloc>(
      create: (BuildContext context) => SelectMembersBloc(
        projectRepository: ProjectRepository(
          dio: context.read<Dio>(),
          dioConfig: context.read<DioConfig>(),
        ),
      ),
      child: BlocConsumer<SelectMembersBloc, SelectMembersState>(
        listener: (BuildContext context, SelectMembersState state) {
          state.maybeWhen(
            searchUsersFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error: 'Could not search user successfully. Please try again.',
              );
            },
            orElse: () => null,
          );
        },
        buildWhen: (SelectMembersState previous, SelectMembersState current) {
          return current.maybeWhen(
            searchUsersFailure: (NetworkExceptions error) => false,
            orElse: () => true,
          );
        },
        builder: (BuildContext context, SelectMembersState state) {
          return state.maybeWhen(
            initial: () {
              context.read<SelectMembersBloc>().add(
                    SelectMembersEvent.searchUsers(
                      searchText: _searchController.text.trim(),
                      projectId: widget.projectId,
                      taskId: widget.taskId,
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
            searchUsersSuccess: (List<SearchUser> users) {
              return GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      _buildSearchBar(context: context),
                      const SizedBox(height: 16),
                      _buildUsers(users: users),
                      if (users.isNotEmpty)
                        _buildSelectButton(
                          context: context,
                          theme: theme,
                          users: users,
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
    );
  }

  Widget _buildSearchBar({required BuildContext context}) {
    return SearchBar(
      controller: _searchController,
      focusNode: _searchFocusNode,
      hintText: 'username',
      onCancel: () {
        context.read<SelectMembersBloc>().add(
              SelectMembersEvent.searchUsers(
                searchText: _searchController.text.trim(),
                projectId: widget.projectId,
                taskId: widget.taskId,
              ),
            );
      },
      onChanged: (String searchText) {
        context.read<SelectMembersBloc>().add(
              SelectMembersEvent.searchUsers(
                searchText: searchText.trim(),
                projectId: widget.projectId,
                taskId: widget.taskId,
              ),
            );
      },
    );
  }

  Widget _buildUsers({required List<SearchUser> users}) {
    if (users.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No members to select.'),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          final SearchUser user = users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text(user.email),
            trailing: IconButton(
              onPressed: () {
                context
                    .read<SelectMembersBloc>()
                    .add(SelectMembersEvent.selectUser(
                      index: index,
                      users: users,
                    ));
              },
              icon: Icon(
                Icons.check_circle_outline_outlined,
                color: user.isSelected ? Colors.amber : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectButton({
    required BuildContext context,
    required ThemeData theme,
    required List<SearchUser> users,
  }) {
    return MaterialButton(
      onPressed: () {
        widget.onSelectUsers(
          users.where((SearchUser user) => user.isSelected == true).toList(),
        );
      },
      elevation: 8,
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 8,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Text(
        widget.buttonText,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.background,
        ),
      ),
    );
  }
}
