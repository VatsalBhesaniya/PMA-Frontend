import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
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
