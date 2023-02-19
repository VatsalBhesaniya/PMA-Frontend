import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person_rounded,
                size: 70,
              ),
            ),
            const SizedBox(height: 16),
            MaterialButton(
              onPressed: () {},
              elevation: 8,
              color: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 8,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Text(
                'Delete Account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
