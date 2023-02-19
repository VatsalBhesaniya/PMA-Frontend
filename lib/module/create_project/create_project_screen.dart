import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/module/create_project/bloc/create_project_bloc.dart';
import 'package:pma/widgets/input_field.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final TextEditingController _projectTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
      ),
      body: BlocProvider<CreateProjectBloc>(
        create: (BuildContext context) => CreateProjectBloc(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProjectTitle(theme),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Members',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputField _buildProjectTitle(ThemeData theme) {
    return InputField(
      onChanged: (String value) {},
      controller: _projectTitleController,
      hintText: 'Title',
      borderType: InputFieldBorderType.underlineInputBorder,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.primary,
      ),
      horizontalContentPadding: 0,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter title';
        }
        return null;
      },
    );
  }
}
