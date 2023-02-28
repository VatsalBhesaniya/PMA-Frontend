import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/profile/bloc/profile_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<ProfileBloc>(
      create: (BuildContext context) => ProfileBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
        appStorageManager: context.read<AppStorageManager>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SingleChildScrollView(
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (BuildContext context, ProfileState state) {
              state.maybeWhen(
                fetchUserFailure: (NetworkExceptions error) {
                  _buildApiFailureAlert(
                    context: context,
                    theme: theme,
                    error:
                        'Could not fetch profile successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            builder: (BuildContext context, ProfileState state) {
              return state.maybeWhen(
                initial: () {
                  context.read<ProfileBloc>().add(
                        ProfileEvent.fetchUser(
                          userId: context.read<User>().id,
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
                fetchUserSucceess: (User user) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Center(
                          child: CircleAvatar(
                            radius: 50,
                            child: Icon(
                              Icons.person_rounded,
                              size: 70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileItem(
                          theme: theme,
                          title: 'First Name',
                          value: user.firstName,
                        ),
                        _buildProfileItem(
                          theme: theme,
                          title: 'Last Name',
                          value: user.lastName,
                        ),
                        _buildProfileItem(
                          theme: theme,
                          title: 'Username',
                          value: user.username,
                        ),
                        _buildProfileItem(
                          theme: theme,
                          title: 'Email Address',
                          value: user.email,
                        ),
                        const SizedBox(height: 32),
                        _buildDeleteButton(theme: theme),
                      ],
                    ),
                  );
                },
                fetchUserFailure: (NetworkExceptions error) {
                  return const Center(
                    child: Text('Something went wrong.'),
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

  Center _buildDeleteButton({
    required ThemeData theme,
  }) {
    return Center(
      child: MaterialButton(
        onPressed: () {},
        elevation: 8,
        color: theme.colorScheme.error,
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
          'Delete Account',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.background,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required ThemeData theme,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Divider(),
        ],
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
