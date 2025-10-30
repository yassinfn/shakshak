
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/create_message_screen.dart';
import 'package:myapp/screens/message_details_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen(); // Your home screen
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'create',
            builder: (BuildContext context, GoRouterState state) {
              return const CreateMessageScreen();
            },
          ),
          GoRoute(
            path: 'message/:id',
            builder: (BuildContext context, GoRouterState state) {
              final String id = state.pathParameters['id']!;
              return MessageDetailsScreen(messageId: id);
            },
          ),
        ]),
  ],
);
