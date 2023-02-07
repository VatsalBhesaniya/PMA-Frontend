import 'package:flutter/material.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/router/go_router.dart';
import 'package:pma/theme/app_theme.dart';
import 'package:pma/theme/theme_changer.dart';
import 'package:provider/provider.dart';

class PmaApp extends StatelessWidget {
  const PmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      create: (BuildContext context) => ThemeChanger(
        appStorageManager: context.read<AppStorageManager>(),
      ),
      child: Consumer<ThemeChanger>(
        builder: (
          BuildContext context,
          ThemeChanger themeChanger,
          Widget? child,
        ) {
          return MaterialApp.router(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            themeMode: themeChanger.getThemeMode(),
            theme: context.read<AppTheme>().lightTheme,
            darkTheme: context.read<AppTheme>().darkTheme,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            routeInformationProvider: router.routeInformationProvider,
            // routerConfig: AppRouter(context.read<LoginBloc>()).router,
            // routeInformationParser: AppRouter(loginBloc: context.read<LoginBloc>())
            //     .router
            //     .routeInformationParser,
            // routerDelegate:
            //     AppRouter(loginBloc: context.read<LoginBloc>()).router.routerDelegate,
          );
        },
      ),
    );
  }
}
