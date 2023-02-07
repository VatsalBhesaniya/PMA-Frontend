import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/module/app/pma_app.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/authentication/bloc/authentication_bloc.dart';
import 'package:pma/module/login/bloc/login_bloc.dart';
import 'package:pma/router/go_router.dart';
import 'package:pma/theme/app_theme.dart';
import 'package:pma/theme/pma_theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setPathUrlStrategy();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final AppStorageManager appStorageManager = AppStorageManager(
      sharedPreferences: sharedPreferences,
      flutterSecureStorage: const FlutterSecureStorage(),
    );
    final UserRepository userRepository = UserRepository();
    runApp(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<AppTheme>.value(
            value: AppTheme(
              lightTheme: buildLightTheme(),
              darkTheme: buildDarkTheme(),
            ),
          ),
          Provider<AppStorageManager>.value(value: appStorageManager),
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
  }, (Object exception, StackTrace stackTrace) async {
    debugPrint(exception.toString());
  });
}
