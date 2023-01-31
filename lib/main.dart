import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/app/pma_app.dart';
import 'package:pma/app/user_repository.dart';
import 'package:pma/authentication/bloc/authentication_bloc.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/login/bloc/login_bloc.dart';
import 'package:pma/router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  final UserRepository userRepository = UserRepository();
  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) =>
              AuthenticationBloc(userRepository: userRepository)
                ..add(AppStarted()),
        ),
        BlocProvider<LoginBloc>(
          create: (BuildContext context) => LoginBloc(
            userRepository: userRepository,
          ),
        ),
      ],
      child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (BuildContext context, AuthenticationState state) {
          if (state is Authenticated) {
            router.goNamed(RouteConstants.home);
          }
          if (state is Unauthenticated || state is Unknown) {
            router.goNamed(RouteConstants.login);
          }
        },
        builder: (BuildContext context, AuthenticationState state) {
          return const PmaApp();
        },
      ),
    ),
  );
}
