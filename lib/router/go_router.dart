import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/module/assign_task/assign_task_screen.dart';
import 'package:pma/module/create_document/create_document_screen.dart';
import 'package:pma/module/create_milestone/create_milestone_screen.dart';
import 'package:pma/module/create_note/create_note_screen.dart';
import 'package:pma/module/create_project/create_project_screen.dart';
import 'package:pma/module/create_task/create_task_screen.dart';
import 'package:pma/module/document/document_screen.dart';
import 'package:pma/module/edit_milestone/edit_milestone_screen.dart';
import 'package:pma/module/home/home_screen.dart';
import 'package:pma/module/invite_members/invite_members_screen.dart';
import 'package:pma/module/login/login_screen.dart';
import 'package:pma/module/milestones/milestones_screen.dart';
import 'package:pma/module/note/note_screen.dart';
import 'package:pma/module/profile/profile_screen.dart';
import 'package:pma/module/project/project_screen.dart';
import 'package:pma/module/project_detail/project_detail_screen.dart';
import 'package:pma/module/settings/settings_screen.dart';
import 'package:pma/module/signup/signup_screen.dart';
import 'package:pma/module/task/task_screen.dart';
import 'package:pma/module/update_password/update_password_screen.dart';

// GoRouter configuration
// The route configuration for the app.
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/${RouteConstants.login}',
  routerNeglect: true,
  routes: <RouteBase>[
    GoRoute(
      path: '/${RouteConstants.login}',
      name: RouteConstants.login,
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: RouteConstants.updatePassword,
          name: RouteConstants.updatePassword,
          builder: (BuildContext context, GoRouterState state) =>
              const UpdatePasswordScreen(),
        ),
        GoRoute(
          path: RouteConstants.signup,
          name: RouteConstants.signup,
          builder: (BuildContext context, GoRouterState state) =>
              const SignupScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/${RouteConstants.home}',
      name: RouteConstants.home,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouteConstants.settings,
          name: RouteConstants.settings,
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.profile,
              name: RouteConstants.profile,
              builder: (BuildContext context, GoRouterState state) {
                return const ProfileScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: '${RouteConstants.project}/:projectId',
          name: RouteConstants.project,
          builder: (BuildContext context, GoRouterState state) {
            return ProjectScreen(
              projectId: state.params['projectId']!,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.projectDetail,
              name: RouteConstants.projectDetail,
              builder: (BuildContext context, GoRouterState state) {
                return ProjectDetailScreen(
                  projectId: state.params['projectId']!,
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: RouteConstants.milestones,
                  name: RouteConstants.milestones,
                  builder: (BuildContext context, GoRouterState state) {
                    return MilestonesScreen(
                      projectId: state.params['projectId']!,
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: RouteConstants.createMilestone,
                      name: RouteConstants.createMilestone,
                      builder: (BuildContext context, GoRouterState state) {
                        return CreateMilestoneScreen(
                          projectId: state.params['projectId']!,
                        );
                      },
                    ),
                    GoRoute(
                      path: '${RouteConstants.editMilestone}/:milestoneId',
                      name: RouteConstants.editMilestone,
                      builder: (BuildContext context, GoRouterState state) {
                        return EditMilestoneScreen(
                          milestoneId: state.params['milestoneId']!,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: RouteConstants.inviteMembers,
                  name: RouteConstants.inviteMembers,
                  builder: (BuildContext context, GoRouterState state) {
                    return InviteMembersScreen(
                      projectId: state.params['projectId']!,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '${RouteConstants.task}/:taskId',
              name: RouteConstants.task,
              builder: (BuildContext context, GoRouterState state) {
                return TaskScreen(
                  projectId: state.params['projectId']!,
                  taskId: state.params['taskId']!,
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: RouteConstants.assignTask,
                  name: RouteConstants.assignTask,
                  builder: (BuildContext context, GoRouterState state) {
                    return AssignTaskScreen(
                      taskId: state.params['taskId']!,
                      projectId: state.params['projectId']!,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: RouteConstants.createTask,
              name: RouteConstants.createTask,
              builder: (BuildContext context, GoRouterState state) {
                return CreateTaskScreen(
                  projectId: state.params['projectId']!,
                );
              },
            ),
            GoRoute(
              path: '${RouteConstants.note}/:id',
              name: RouteConstants.note,
              builder: (BuildContext context, GoRouterState state) {
                return NoteScreen(
                  projectId: state.params['projectId']!,
                  noteId: state.params['id']!,
                );
              },
            ),
            GoRoute(
              path: RouteConstants.createNote,
              name: RouteConstants.createNote,
              builder: (BuildContext context, GoRouterState state) {
                return CreateNoteScreen(
                  projectId: state.params['projectId']!,
                );
              },
            ),
            GoRoute(
              path: '${RouteConstants.document}/:id',
              name: RouteConstants.document,
              builder: (BuildContext context, GoRouterState state) {
                return DocumentScreen(
                  projectId: state.params['projectId']!,
                  documentId: state.params['id']!,
                );
              },
            ),
            GoRoute(
              path: RouteConstants.createDocument,
              name: RouteConstants.createDocument,
              builder: (BuildContext context, GoRouterState state) {
                return CreateDocumentScreen(
                  projectId: state.params['projectId']!,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteConstants.createProject,
          name: RouteConstants.createProject,
          builder: (BuildContext context, GoRouterState state) {
            return const CreateProjectScreen();
          },
        ),
      ],
    ),
  ],
);

// class AppRouter {
//   AppRouter({required this.loginBloc});
//   final LoginBloc loginBloc;
//   // AppRouter(this.authenticationBloc);
//   // final AuthenticationBloc authenticationBloc;

//   late final GoRouter router = GoRouter(
//     debugLogDiagnostics: true,
//     initialLocation: '/${RouteConstants.login}',
//     routerNeglect: true,
//     routes: <RouteBase>[
//       GoRoute(
//         path: '/',
//         builder: (BuildContext context, GoRouterState state) => const Scaffold(
//           body: Center(
//             child: Text('data'),
//           ),
//         ),
//       ),
//       // GoRoute(
//       //   path: '/${RouteConstants.login}',
//       //   name: RouteConstants.login,
//       //   builder: (BuildContext context, GoRouterState state) =>
//       //       const LoginScreen(),
//       // ),
//       GoRoute(
//         path: '/${RouteConstants.home}',
//         name: RouteConstants.home,
//         builder: (BuildContext context, GoRouterState state) =>
//             const HomeScreen(),
//       ),
//     ],
//     // redirect to the login page if the user is not logged in
//     redirect: (BuildContext context, GoRouterState state) {
//       // if the user is not logged in, they need to login
//       final bool loggedIn = loginBloc.state.status == AuthStatus.authenticated;
//       final bool loggingIn = state.subloc == '/${RouteConstants.login}';
//       if (!loggedIn) {
//         return '/${RouteConstants.login}';
//       }
//       // if the user is logged in but still on the login page, send them to
//       // the home page
//       if (loggingIn) {
//         return RouteConstants.root;
//       }
//       // no need to redirect at all
//       return null;
//     },
//   );
// }
