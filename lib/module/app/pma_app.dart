import 'package:flutter/material.dart';
import 'package:pma/router/go_router.dart';

class PmaApp extends StatelessWidget {
  const PmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  }
}
