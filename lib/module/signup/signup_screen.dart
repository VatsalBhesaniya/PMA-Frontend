import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/create_user.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/login/bloc/login_bloc.dart';
import 'package:pma/module/signup/signup/signup_bloc.dart';
import 'package:pma/router/go_router.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider<SignupBloc>(
      create: (BuildContext context) => SignupBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Signup'),
        ),
        body: SafeArea(
          child: BlocConsumer<SignupBloc, SignupState>(
            listener: (BuildContext context, SignupState state) {
              state.maybeWhen(
                signupSuccess: (CreateUser user) {
                  context.read<LoginBloc>().add(
                        LoginEvent.loginSubmitted(
                          email: user.email,
                          password: user.password,
                        ),
                      );
                },
                signupFailure: (NetworkExceptions error) {
                  pmaAlertDialog(
                    context: context,
                    theme: theme,
                    error: 'Could not login successfully. Please try again.',
                  );
                },
                orElse: () => null,
              );
            },
            buildWhen: (SignupState previous, SignupState current) {
              return current.maybeWhen(
                signupSuccess: (CreateUser user) => false,
                signupFailure: (NetworkExceptions error) => false,
                orElse: () => true,
              );
            },
            builder: (BuildContext context, SignupState state) {
              return state.maybeWhen(
                loadInProgress: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                orElse: () {
                  return SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildForm(context),
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

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 16),
          _buildInputField(
            controller: _firstNameController,
            hintText: 'First Name',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter First Name';
              }
              return null;
            },
          ),
          _buildInputField(
            controller: _lastNameController,
            hintText: 'Last Name',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter Last Name';
              }
              return null;
            },
          ),
          _buildInputField(
            controller: _usernameController,
            hintText: 'Username',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter Username';
              }
              return null;
            },
          ),
          _buildInputField(
            controller: _emailController,
            hintText: 'Email Address',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter Email Address';
              }
              return null;
            },
          ),
          _buildInputField(
            controller: _passwordController,
            hintText: 'Password',
            isObscure: true,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter Password';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final FormState? formState = _formKey.currentState;
              if (formState != null && formState.validate()) {
                context.read<SignupBloc>().add(
                      SignupEvent.signupSubmitted(
                        user: CreateUser(
                          firstName: _firstNameController.text.trim(),
                          lastName: _lastNameController.text.trim(),
                          username: _usernameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
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
            child: const Text('Signup'),
          ),
          const SizedBox(height: 48),
          const Text('Already have an account?'),
          TextButton(
            onPressed: () {
              router.goNamed(RouteConstants.login);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
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
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        validator: validator,
      ),
    );
  }
}
