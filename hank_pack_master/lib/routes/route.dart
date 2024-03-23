import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/cash_files/cash_files_page.dart';
import '../ui/env/env_page.dart';
import '../ui/framework_page.dart';
import '../ui/home/home_page.dart';
import '../ui/project_manager/project_manager_page.dart';
import '../ui/work_shop/work_shop_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _homeKey = GlobalKey<NavigatorState>();

final statefulRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            FrameworkPage(navigationShell),
        branches: [
          StatefulShellBranch(navigatorKey: _homeKey, routes: <RouteBase>[
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(path: '/env', builder: (context, state) => const EnvPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/project_manager',
                builder: (context, state) => const ProjectManagerPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/work_shop',
                builder: (context, state) => const WorkShopPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/cash_files',
                builder: (context, state) => const CashFilesPage()),
          ])
        ]),
  ],
);
