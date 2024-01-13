import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../env/env_page.dart';
import '../framework_page.dart';
import '../home/home_page.dart';
import '../projects/project_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _homeKey = GlobalKey<NavigatorState>();

final statefulRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FluentTheme(
              data: FluentThemeData(), child: FrameworkPage(navigationShell));
        },
        branches: [
          StatefulShellBranch(navigatorKey: _homeKey, routes: <RouteBase>[
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(path: '/env', builder: (context, state) => const EnvPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/projects',
                builder: (context, state) => FluentTheme(
                    data: FluentThemeData(), child: const ProjectPage())),
          ])
        ]),
  ],
);
