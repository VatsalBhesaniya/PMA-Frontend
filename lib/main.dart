import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/module/app/pma_app.dart';
import 'package:pma/module/app/user_repository.dart';
import 'package:pma/module/authentication/bloc/authentication_bloc.dart';
import 'package:pma/module/login/bloc/login_bloc.dart';
import 'package:pma/router/go_router.dart';
import 'package:pma/theme/app_theme.dart';
import 'package:pma/theme/pma_theme.dart';
import 'package:pma/utils/dio_client.dart';
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
    final DioClient dioClient = DioClient(
      baseURL: Platform.isAndroid ? androidBaseUrl : iosBaseUrl,
    );
    final UserRepository userRepository = UserRepository(
      dioClient: dioClient,
      appStorageManager: appStorageManager,
    );
    runApp(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<AppTheme>.value(
            value: AppTheme(
              lightTheme: buildLightTheme(),
              darkTheme: buildDarkTheme(),
            ),
          ),
          Provider<DioClient>.value(
            value: dioClient,
          ),
          Provider<HttpClientConfig>.value(
            value: HttpClientConfig(
              baseUrl: Platform.isAndroid ? androidBaseUrl : iosBaseUrl,
            ),
          ),
          Provider<AppStorageManager>.value(value: appStorageManager),
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) =>
                AuthenticationBloc(userRepository: userRepository)
                  ..add(const AuthenticationEvent.appStarted()),
          ),
          BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(
              userRepository: userRepository,
            ),
          ),
        ],
        child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listener: (BuildContext context, AuthenticationState state) {
            state.maybeWhen(
              unknown: () {
                router.goNamed(RouteConstants.login);
              },
              unauthenticated: () {
                router.goNamed(RouteConstants.login);
              },
              authenticated: () {
                context.read<AppStorageManager>().getUserToken().then(
                  (String? token) {
                    context.read<DioClient>().addAccessTokenToHeader(
                          value: token!,
                        );
                  },
                );
                router.goNamed(RouteConstants.home);
              },
              orElse: () => null,
            );
          },
          buildWhen:
              (AuthenticationState previous, AuthenticationState current) {
            return current.maybeWhen(
              loadInProgress: () => true,
              authenticated: () => true,
              unauthenticated: () => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, AuthenticationState state) {
            return state.maybeWhen(
              initial: () {
                return const Material(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              loadInProgress: () {
                return const Material(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              orElse: () {
                return const PmaApp();
              },
            );
          },
        ),
      ),
    );
  }, (Object exception, StackTrace stackTrace) async {
    debugPrint(exception.toString());
  });
}
