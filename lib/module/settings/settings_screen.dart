import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/manager/app_storage_manager.dart';
import 'package:pma/theme/theme_changer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
            _buildMenuItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: <Widget>[
        _buildMenuItem(
          onTap: () {
            context.goNamed(RouteConstants.profile);
          },
          iconData: Icons.person,
          title: 'Profile',
        ),
        _buildThemeMenuItem(),
      ],
    );
  }

  Widget _buildMenuItem({
    Function()? onTap,
    required IconData iconData,
    required String title,
    bool isTrailingIcon = true,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(iconData),
      title: Text(title),
      trailing: isTrailingIcon
          ? const Icon(
              Icons.keyboard_arrow_right_rounded,
            )
          : null,
    );
  }

  Widget _buildThemeMenuItem() {
    return Column(
      children: <Widget>[
        const ListTile(
          leading: Icon(Icons.color_lens_rounded),
          title: Text('Theme'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 70,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CircleAvatar(
                child: IconButton(
                  onPressed: () {
                    context.read<ThemeChanger>().setTheme(AppThemeMode.light);
                  },
                  icon: const Icon(Icons.light_mode_rounded),
                ),
              ),
              CircleAvatar(
                child: IconButton(
                  onPressed: () {
                    context.read<ThemeChanger>().setTheme(AppThemeMode.dark);
                  },
                  icon: const Icon(Icons.nightlight_round),
                ),
              ),
              CircleAvatar(
                child: IconButton(
                  onPressed: () {
                    context.read<ThemeChanger>().setTheme(AppThemeMode.system);
                  },
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
