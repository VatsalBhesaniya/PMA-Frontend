import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/update_user.dart';
import 'package:pma/models/user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/profile/bloc/profile_bloc.dart';
import 'package:pma/module/profile/profile_repository.dart';
import 'package:pma/utils/dio_client.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<ProfileBloc>(
      create: (BuildContext context) => ProfileBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
        profileRepository: ProfileRepository(
          dio: context.read<Dio>(),
          dioConfig: context.read<DioConfig>(),
        ),
        appStorageManager: context.read<AppStorageManager>(),
      ),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (BuildContext context, ProfileState state) {
          state.maybeWhen(
            fetchUserFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not fetch profile successfully. Please try again.',
              );
            },
            updateUserSuccess: () {
              context.read<ProfileBloc>().add(
                    ProfileEvent.fetchUser(
                      userId: context.read<User>().id,
                    ),
                  );
            },
            updateUserFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not update profile successfully. Please try again.',
              );
            },
            deleteUserSuccess: () {
              context.goNamed(RouteConstants.login);
            },
            deleteUserFailure: (NetworkExceptions error) {
              pmaAlertDialog(
                context: context,
                theme: theme,
                error:
                    'Could not delete account successfully. Please try again.',
              );
            },
            orElse: () => null,
          );
        },
        buildWhen: (ProfileState previous, ProfileState current) {
          return current.maybeWhen(
            updateUserSuccess: () => false,
            updateUserFailure: (NetworkExceptions error) => false,
            deleteUserSuccess: () => false,
            deleteUserFailure: (NetworkExceptions error) => false,
            orElse: () => true,
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
            fetchUserSucceess: (User user) {
              return Scaffold(
                appBar: _buildAppBar(
                  context: context,
                  user: user,
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildProfileItems(
                          context: context,
                          theme: theme,
                          user: user,
                        ),
                        const SizedBox(height: 32),
                        _buildButton(
                          context: context,
                          theme: theme,
                          user: user,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            fetchUserFailure: (NetworkExceptions error) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Something went wrong.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              );
            },
            orElse: () {
              return const Scaffold(
                body: SizedBox(),
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar({
    required BuildContext context,
    required User user,
  }) {
    return AppBar(
      title: const Text('Profile'),
      actions: <Widget>[
        if (!user.isEdit)
          IconButton(
            onPressed: () {
              context.read<ProfileBloc>().add(
                    ProfileEvent.editProfile(
                      user: user.copyWith(
                        isEdit: true,
                      ),
                    ),
                  );
            },
            icon: const Icon(Icons.edit_rounded),
          ),
      ],
    );
  }

  Widget _buildProfileItems({
    required BuildContext context,
    required ThemeData theme,
    required User user,
  }) {
    if (user.isEdit) {
      return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            _buildInputField(
              controller: _firstNameController..text = user.firstName,
              hintText: 'First Name',
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter First Name';
                }
                return null;
              },
            ),
            _buildInputField(
              controller: _lastNameController..text = user.lastName,
              hintText: 'Last Name',
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter Last Name';
                }
                return null;
              },
            ),
            _buildInputField(
              controller: _usernameController..text = user.username,
              hintText: 'Username',
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter Username';
                }
                return null;
              },
            ),
            _buildInputField(
              controller: _emailController..text = user.email,
              hintText: 'Email Address',
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter Email Address';
                }
                return null;
              },
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: <Widget>[
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
        ],
      );
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool isObscure = false,
    required String? Function(String? value) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputField(
        controller: controller,
        hintText: hintText,
        isObscure: isObscure,
        inputFieldHeight: InputFieldHeight.large,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        validator: validator,
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required ThemeData theme,
    required User user,
  }) {
    if (user.isEdit) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildSaveButton(
            context: context,
            theme: theme,
            user: user,
          ),
          const SizedBox(width: 32),
          _buildCancelButton(
            context: context,
            theme: theme,
            user: user,
          ),
        ],
      );
    } else {
      return _buildDeleteButton(
        context: context,
        theme: theme,
        userId: user.id,
      );
    }
  }

  Widget _buildSaveButton({
    required BuildContext context,
    required ThemeData theme,
    required User user,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<ProfileBloc>().add(
                  ProfileEvent.updateProfile(
                    userId: user.id,
                    user: UpdateUser(
                      firstName: _firstNameController.text.trim(),
                      lastName: _lastNameController.text.trim(),
                      username: _usernameController.text.trim(),
                      email: _emailController.text.trim(),
                    ),
                  ),
                );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Save',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.background,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton({
    required BuildContext context,
    required ThemeData theme,
    required User user,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          context.read<ProfileBloc>().add(
                ProfileEvent.editProfile(
                  user: user.copyWith(
                    isEdit: false,
                  ),
                ),
              );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cancel',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.background,
            ),
          ),
        ),
      ),
    );
  }

  Center _buildDeleteButton({
    required BuildContext context,
    required ThemeData theme,
    required int userId,
  }) {
    return Center(
      child: MaterialButton(
        onPressed: () {
          context.read<ProfileBloc>().add(
                ProfileEvent.deleteProfile(
                  userId: userId,
                ),
              );
        },
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
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
