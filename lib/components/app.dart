// lib/components/app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'link_list.dart';
import 'create_link.dart';
import 'login.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hackeryesno',
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LinkListScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => CreateLinkScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: Text('Error'),
    ),
    body: Center(
      child: Text('Page not found'),
    ),
  ),
);
