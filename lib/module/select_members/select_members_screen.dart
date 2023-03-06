import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/project/project_repository.dart';
import 'package:pma/module/select_members/bloc/select_members_bloc.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/search_bar.dart';

class SelectMembersScreen extends StatefulWidget {
  const SelectMembersScreen({
    super.key,
    required this.projectId,
    required this.buttonText,
    required this.onSelectUsers,
  });

  final int projectId;
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
    return Scaffold(
      body: SafeArea(
        child: BlocProvider<SelectMembersBloc>(
          create: (BuildContext context) => SelectMembersBloc(
            projectRepository: ProjectRepository(
              dioClient: context.read<DioClient>(),
            ),
          ),
          child: BlocConsumer<SelectMembersBloc, SelectMembersState>(
            listener: (BuildContext context, SelectMembersState state) {
              state.maybeWhen(
                searchUsersFailure: (NetworkExceptions error) {
                  _buildApiFailureAlert(
                    context: context,
                    theme: theme,
                    error:
                        'Could not search user successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen:
                (SelectMembersState previous, SelectMembersState current) {
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
        ),
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
              ),
            );
      },
      onChanged: (String searchText) {
        context.read<SelectMembersBloc>().add(
              SelectMembersEvent.searchUsers(
                searchText: searchText.trim(),
                projectId: widget.projectId,
              ),
            );
      },
    );
  }

  Widget _buildUsers({required List<SearchUser> users}) {
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
      color: theme.colorScheme.secondary,
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
