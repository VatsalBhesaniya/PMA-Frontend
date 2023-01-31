import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/authentication/bloc/authentication_bloc.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/login/bloc/login_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final List<String> items = <String>['1', '2', '3', '4'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => context.goNamed(RouteConstants.details),
                child: const Text('Go to the Details screen'),
              ),
              ElevatedButton(
                onPressed: () =>
                    context.read<AuthenticationBloc>().add(Logout()),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
        // child: ListView.builder(
        //   itemCount: items.length,
        //   prototypeItem: ListTile(
        //     title: Text(items.first),
        //   ),
        //   itemBuilder: (BuildContext context, int index) {
        //     return ListTile(
        //       title: Text(items[index]),
        //     );
        //   },
        // ),
      ),
    );
  }
}
