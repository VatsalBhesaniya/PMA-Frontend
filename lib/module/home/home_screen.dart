import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/config/http_client_config.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/module/invited_projects/bloc/invited_projects_bloc.dart';
import 'package:pma/module/invited_projects/invited_projects_screen.dart';
import 'package:pma/module/my_projects/bloc/my_projects_bloc.dart';
import 'package:pma/module/my_projects/my_projects_screen.dart';
import 'package:pma/utils/dio_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: () {
                context.goNamed(RouteConstants.settings);
              },
              icon: CircleAvatar(
                backgroundColor: theme.colorScheme.background,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildTabBar(theme: theme),
            _buildTabBarView(theme: theme),
          ],
        ),
      ),
    );
  }

  TabBar _buildTabBar({
    required ThemeData theme,
  }) {
    return TabBar(
      controller: _tabController,
      onTap: (int index) {
        _tabController.index = index;
        setState(() {});
      },
      tabs: <Tab>[
        _buildTab(
          theme: theme,
          title: 'My Projects',
        ),
        _buildTab(
          theme: theme,
          title: 'Invited',
        ),
      ],
    );
  }

  Tab _buildTab({
    required ThemeData theme,
    required String title,
  }) {
    return Tab(
      child: Text(
        title,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Expanded _buildTabBarView({
    required ThemeData theme,
  }) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          BlocProvider<MyProjectsBloc>(
            create: (BuildContext context) => MyProjectsBloc(
              projectsRepository: ProjectsRepository(
                dioClient: context.read<DioClient>(),
                httpClient: context.read<HttpClientConfig>(),
              ),
            ),
            child: const MyPorojectsScreen(),
          ),
          BlocProvider<InvitedProjectsBloc>(
            create: (BuildContext context) => InvitedProjectsBloc(
              projectsRepository: ProjectsRepository(
                dioClient: context.read<DioClient>(),
                httpClient: context.read<HttpClientConfig>(),
              ),
            ),
            child: const InvitedPorojectsScreen(),
          ),
        ],
      ),
    );
  }
}
