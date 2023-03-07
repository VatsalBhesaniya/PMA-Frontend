import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/module/authentication/bloc/authentication_bloc.dart';
import 'package:pma/theme/theme_changer.dart';
import 'package:pma/widgets/floating_action_button_extended.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      floatingActionButton: FloatingActionButtonExtended(
        onPressed: () {
          context.read<AuthenticationBloc>().add(
                const AuthenticationEvent.logout(),
              );
        },
        labelText: 'Logout',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          _buildMenuItem(theme: theme),
          const SizedBox(height: 16),
          _buildThemeMenuItem(theme: theme),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required ThemeData theme}) {
    return ListTile(
      onTap: () {
        context.goNamed(RouteConstants.profile);
      },
      leading: const Icon(Icons.person),
      title: Text(
        'Profile',
        style: theme.textTheme.bodyLarge,
      ),
      trailing: const Icon(
        Icons.keyboard_arrow_right_rounded,
      ),
    );
  }

  Widget _buildThemeMenuItem({
    required ThemeData theme,
  }) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.color_lens_rounded),
          title: Text(
            'Theme',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 70,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                child: IconButton(
                  onPressed: () {
                    context.read<ThemeChanger>().setTheme(AppThemeMode.light);
                  },
                  color: theme.colorScheme.primary,
                  icon: const Icon(Icons.light_mode_rounded),
                ),
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                child: IconButton(
                  onPressed: () {
                    context.read<ThemeChanger>().setTheme(AppThemeMode.dark);
                  },
                  color: theme.colorScheme.primary,
                  icon: const Icon(Icons.nightlight_round),
                ),
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                child: IconButton(
                  onPressed: () {
                    context.read<ThemeChanger>().setTheme(AppThemeMode.system);
                  },
                  color: theme.colorScheme.primary,
                  icon: const Icon(Icons.settings_suggest_rounded),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
