import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/search_user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/invite_members/bloc/invite_members_bloc.dart';
import 'package:pma/module/invite_members/invite_members_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/search_bar.dart';

class InviteMembersScreen extends StatefulWidget {
  const InviteMembersScreen({super.key});

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
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
        child: BlocProvider<InviteMembersBloc>(
          create: (BuildContext context) => InviteMembersBloc(
            userRepository: UserRepository(
              dioClient: context.read<DioClient>(),
              appStorageManager: context.read<AppStorageManager>(),
            ),
            inviteMembersRepository: InviteMembersRepository(
              dioClient: context.read<DioClient>(),
              httpClient: context.read<HttpClientConfig>(),
            ),
          ),
          child: BlocConsumer<InviteMembersBloc, InviteMembersState>(
            listener: (BuildContext context, InviteMembersState state) {
              state.maybeWhen(
                searchUsersFailure: (NetworkExceptions error) {
                  _buildApiFailureAlert(
                    context: context,
                    theme: theme,
                    error:
                        'Could not search user successfully. Please try again.',
                  );
                },
                inviteMembersSuccess: () {
                  context.pop();
                },
                inviteMembersFailure: (NetworkExceptions error) {
                  _buildApiFailureAlert(
                    context: context,
                    theme: theme,
                    error:
                        'Could not invite members successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen:
                (InviteMembersState previous, InviteMembersState current) {
              return current.maybeWhen(
                searchUsersFailure: (NetworkExceptions error) => false,
                inviteMembersSuccess: () => false,
                inviteMembersFailure: (NetworkExceptions error) => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, InviteMembersState state) {
              return state.maybeWhen(
                initial: () {
                  context.read<InviteMembersBloc>().add(
                        InviteMembersEvent.searchUsers(
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
                      // FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          _buildSearchBar(context: context),
                          const SizedBox(height: 16),
                          _buildUsers(users: users),
                          _buildInviteButton(
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
        context.read<InviteMembersBloc>().add(
              InviteMembersEvent.searchUsers(
                searchText: _searchController.text.trim(),
              ),
            );
      },
      onChanged: (String searchText) {
        context.read<InviteMembersBloc>().add(
              InviteMembersEvent.searchUsers(
                searchText: searchText.trim(),
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
                    .read<InviteMembersBloc>()
                    .add(InviteMembersEvent.selectUser(
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

  Widget _buildInviteButton({
    required BuildContext context,
    required ThemeData theme,
    required List<SearchUser> users,
  }) {
    return MaterialButton(
      onPressed: () {
        context.read<InviteMembersBloc>().add(
              InviteMembersEvent.inviteMembers(
                users: users
                    .where((SearchUser user) => user.isSelected == true)
                    .toList(),
              ),
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
        'Invite',
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
