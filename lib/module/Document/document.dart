import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.goNamed(RouteConstants.home),
            child: const Text('Go back to the Home screen'),
          ),
        ],
      ),
    );
  }
}
