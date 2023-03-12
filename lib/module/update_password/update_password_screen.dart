import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/update_password.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/update_password/bloc/update_password_bloc.dart';
import 'package:pma/router/go_router.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/utils/validations.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<UpdatePasswordBloc>(
      create: (BuildContext context) => UpdatePasswordBloc(
        userRepository: context.read<UserRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
        ),
        body: SafeArea(
          child: BlocConsumer<UpdatePasswordBloc, UpdatePasswordState>(
            listener: (BuildContext context, UpdatePasswordState state) {
              state.maybeWhen(
                updatePasswordSuccess: () {
                  router.goNamed(RouteConstants.login);
                },
                updatePasswordFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error:
                        'Could not reset password successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen:
                (UpdatePasswordState previous, UpdatePasswordState current) {
              return current.maybeWhen(
                updatePasswordSuccess: () => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, UpdatePasswordState state) {
              return state.maybeWhen(
                loadInProgress: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                orElse: () {
                  return Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InputField(
                                controller: _emailController,
                                hintText: 'Email address',
                                validator: (String? value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    return Validations()
                                        .emailValidator(email: value);
                                  }
                                  return null;
                                },
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                inputFieldHeight: InputFieldHeight.large,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              InputField(
                                controller: _passwordController,
                                hintText: 'Password',
                                validator: (String? value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    return Validations()
                                        .passwordValidator(password: value);
                                  }
                                  return null;
                                },
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                inputFieldHeight: InputFieldHeight.large,
                              ),
                              const SizedBox(
                                height: 32,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final FormState? formState =
                                      _formKey.currentState;
                                  if (formState != null &&
                                      formState.validate()) {
                                    context.read<UpdatePasswordBloc>().add(
                                          UpdatePasswordEvent.updatePassword(
                                            updatePassword: UpdatePassword(
                                              email:
                                                  _emailController.text.trim(),
                                              password: _passwordController.text
                                                  .trim(),
                                            ),
                                          ),
                                        );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(100, 40),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Reset',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.background,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
