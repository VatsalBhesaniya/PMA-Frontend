import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/select_users/bloc/select_users_bloc.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';
import 'package:pma/widgets/search_bar.dart';

class SelectUsersScreen extends StatefulWidget {
  const SelectUsersScreen({
    super.key,
    required this.projectId,
    required this.buttonText,
    required this.onSelectUsers,
  });

  final int projectId;
  final String buttonText;
  final Function(List<SearchUser>) onSelectUsers;

  @override
  State<SelectUsersScreen> createState() => _SelectUsersScreenState();
}

class _SelectUsersScreenState extends State<SelectUsersScreen> {
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
    return BlocProvider<SelectUsersBloc>(
      create: (BuildContext context) => SelectUsersBloc(
        userRepository: UserRepository(
          dioClient: context.read<DioClient>(),
          appStorageManager: context.read<AppStorageManager>(),
        ),
      ),
      child: BlocConsumer<SelectUsersBloc, SelectUsersState>(
        listener: (BuildContext context, SelectUsersState state) {
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
        buildWhen: (SelectUsersState previous, SelectUsersState current) {
          return current.maybeWhen(
            searchUsersFailure: (NetworkExceptions error) => false,
            orElse: () => true,
          );
        },
        builder: (BuildContext context, SelectUsersState state) {
          return state.maybeWhen(
            initial: () {
              context.read<SelectUsersBloc>().add(
                    SelectUsersEvent.searchUsers(
                      projectId: widget.projectId,
                      searchText: _searchController.text.trim(),
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
        context.read<SelectUsersBloc>().add(
              SelectUsersEvent.searchUsers(
                projectId: widget.projectId,
                searchText: _searchController.text.trim(),
              ),
            );
      },
      onChanged: (String searchText) {
        context.read<SelectUsersBloc>().add(
              SelectUsersEvent.searchUsers(
                projectId: widget.projectId,
                searchText: searchText.trim(),
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
                context.read<SelectUsersBloc>().add(SelectUsersEvent.selectUser(
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
