import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/module/authentication/bloc/authentication_bloc.dart';
import 'package:pma/module/login/bloc/login_bloc.dart';
import 'package:pma/utils/network_exceptions.dart';

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
              loginSuccess: () {
                context.read<AuthenticationBloc>().add(
                      const AuthenticationEvent.appStarted(),
                    );
              },
              loginFailure: (NetworkExceptions error) {
                _buildApiFailureAlert(
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
              loginSuccess: () => false,
              loginFailure: (NetworkExceptions error) => false,
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Email address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                              contentPadding: EdgeInsets.all(20),
                              constraints: BoxConstraints(
                                maxWidth: 400,
                              ),
                            ),
                            validator: (String? value) {
                              if (value != null && value.trim().isEmpty) {
                                return 'Please enter email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                              contentPadding: EdgeInsets.all(20),
                              constraints: BoxConstraints(
                                maxWidth: 400,
                              ),
                            ),
                            validator: (String? value) {
                              if (value != null && value.trim().isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final FormState? formState =
                                  _formKey.currentState;
                              if (formState != null && formState.validate()) {
                                context.read<LoginBloc>().add(
                                      LoginEvent.loginSubmitted(
                                        email: _emailController.text.trim(),
                                        password:
                                            _passwordController.text.trim(),
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
                            child: const Text('Login'),
                          ),
                        ],
                      ),
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
