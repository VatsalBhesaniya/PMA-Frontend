import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pma/config/dio_config.dart';
import 'package:pma/constants/api_constants.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/models/user.dart';
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
    final String baseURL = Platform.isAndroid ? androidBaseUrl : iosBaseUrl;
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseURL,
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      ),
    );
    final DioConfig dioConfig = DioConfig(
      baseUrl: baseURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );
    final UserRepository userRepository = UserRepository(
      dioConfig: dioConfig,
      dio: dio,
    );
    late User currentUser;
    final String? userToken = await appStorageManager.getUserToken();
    final String? userTokenString =
        await appStorageManager.getUserTokenString();
    runApp(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<AppTheme>.value(
            value: AppTheme(
              lightTheme: buildLightTheme(),
              darkTheme: buildDarkTheme(),
            ),
          ),
          Provider<Dio>.value(
            value: dio,
          ),
          Provider<DioConfig>.value(
            value: dioConfig,
          ),
          Provider<AppStorageManager>.value(value: appStorageManager),
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) => AuthenticationBloc(
              userRepository: userRepository,
            )..add(AuthenticationEvent.appStarted(
                token: userToken,
                tokenString: userTokenString,
              )),
          ),
          RepositoryProvider<UserRepository>(
            create: (BuildContext context) => userRepository,
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
              unauthenticated: () {
                appStorageManager.clearStorage();
                router.goNamed(RouteConstants.login);
              },
              authenticated: (String token, User user) {
                context.read<DioConfig>().addAccessTokenToHeader(
                      value: token,
                    );
                currentUser = user;
                router.goNamed(RouteConstants.home);
              },
              orElse: () => null,
            );
          },
          buildWhen:
              (AuthenticationState previous, AuthenticationState current) {
            return current.maybeWhen(
              loadInProgress: () => true,
              authenticated: (String token, User user) => true,
              unauthenticated: () => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, AuthenticationState state) {
            return state.when(
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
              authenticated: (String token, User user) {
                return Provider<User>.value(
                  value: currentUser,
                  child: const PmaApp(),
                );
              },
              unauthenticated: () {
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
