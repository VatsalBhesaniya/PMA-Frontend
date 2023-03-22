import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/module/authentication/bloc/authentication_bloc.dart';
import 'package:pma/module/login/bloc/login_bloc.dart';
import 'package:pma/router/go_router.dart';
import 'package:pma/utils/network_exceptions.dart';
import 'package:pma/utils/validations.dart';
import 'package:pma/widgets/input_field.dart';
import 'package:pma/widgets/pma_alert_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (BuildContext context, LoginState state) {
            state.maybeWhen(
              loginSuccess: (String token) async {
                final AppStorageManager appStorageManager =
                    context.read<AppStorageManager>();
                appStorageManager.setUserToken('Bearer $token');
                appStorageManager.setUserTokenString(token);
                final String? userToken =
                    await appStorageManager.getUserToken();
                final String? userTokenString =
                    await appStorageManager.getUserTokenString();
                if (mounted) {
                  context.read<AuthenticationBloc>().add(
                        AuthenticationEvent.appStarted(
                          token: userToken,
                          tokenString: userTokenString,
                        ),
                      );
                }
              },
              loginFailure: (NetworkExceptions error) {
                pmaAlertDialog(
                  context: context,
                  theme: theme,
                  error: 'Could not login successfully. Please try again.',
                );
              },
              orElse: () => null,
            );
          },
          buildWhen: (LoginState previous, LoginState current) {
            return current.maybeWhen(
              loginSuccess: (String token) => false,
              orElse: () => true,
            );
          },
          builder: (BuildContext context, LoginState state) {
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
                      child: _buildLoginForm(theme, context),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildEmailAddressField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          _buildForgotPassword(theme),
          const SizedBox(height: 32),
          _buildLoginButton(context, theme),
          const SizedBox(height: 48),
          Text(
            "Don't have an account?",
            style: theme.textTheme.bodyMedium,
          ),
          _buildRegistreButton(theme),
        ],
      ),
    );
  }

  InputField _buildEmailAddressField() {
    return InputField(
      controller: _emailController,
      hintText: 'Email address',
      validator: (String? value) {
        if (value != null && value.trim().isNotEmpty) {
          return Validations().emailValidator(email: value);
        }
        return null;
      },
      borderRadius: const BorderRadius.all(
        Radius.circular(50),
      ),
      inputFieldHeight: InputFieldHeight.large,
    );
  }

  InputField _buildPasswordField() {
    return InputField(
      controller: _passwordController,
      hintText: 'Password',
      validator: (String? value) {
        if (value != null && value.trim().isNotEmpty) {
          return Validations().passwordValidator(password: value);
        }
        return null;
      },
      borderRadius: const BorderRadius.all(
        Radius.circular(50),
      ),
      inputFieldHeight: InputFieldHeight.large,
    );
  }

  Widget _buildForgotPassword(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          router.goNamed(RouteConstants.updatePassword);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Forgot password?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildLoginButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: () {
        final FormState? formState = _formKey.currentState;
        if (formState != null && formState.validate()) {
          context.read<LoginBloc>().add(
                LoginEvent.loginSubmitted(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
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
        'Login',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.background,
        ),
      ),
    );
  }

  TextButton _buildRegistreButton(ThemeData theme) {
    return TextButton(
      onPressed: () {
        router.goNamed(RouteConstants.signup);
      },
      child: Text(
        'Register',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
