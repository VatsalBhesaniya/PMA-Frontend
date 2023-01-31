import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/authentication/bloc/authentication_bloc.dart';
import 'package:pma/login/bloc/login_bloc.dart';

import '../constants/route_constants.dart';
import '../router/go_router.dart';

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
    context.read<AuthenticationBloc>().add(AppStarted());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (BuildContext context, LoginState state) {
            switch (state.status) {
              case AuthStatus.unknown:
                router.goNamed(RouteConstants.login);
                break;
              case AuthStatus.authenticated:
                router.goNamed(RouteConstants.home);
                break;
              case AuthStatus.unauthenticated:
                router.goNamed(RouteConstants.login);
                break;
            }
          },
          builder: (BuildContext context, LoginState state) {
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
                          final FormState? formState = _formKey.currentState;
                          if (formState != null && formState.validate()) {
                            context.read<LoginBloc>().add(
                                  LoginSubmitted(
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
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
