// routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/todo/todo_list_screen.dart';
import '../screens/todo/add_todo_screen.dart';
import '../screens/todo/edit_todo_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/auth/forget_password_screen.dart';
import '../screens/auth/lets_start_screen.dart';
import '../screens/main_nav_screen.dart';
import '../models/todo.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String todoList = '/todos';
  static const String addTodo = '/add-todo';
  static const String editTodo = '/edit-todo';
  static const String profile = '/profile';
  static const String letsStart = '/lets-start';
  static const String mainNav = '/main';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: letsStart,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: addTodo,
          builder: (context, state) => const AddTodoScreen(),
        ),
        GoRoute(
          path: editTodo,
          builder: (context, state) {
            final todo = state.extra as Todo;
            return EditTodoScreen(todo: todo);
          },
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/forget-password',
          builder: (context, state) => const ForgetPasswordScreen(),
        ),
        GoRoute(
          path: letsStart,
          builder: (context, state) => const LetsStartScreen(),
        ),
        GoRoute(
          path: mainNav,
          builder: (context, state) => const MainNavScreen(),
        ),
      ],
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;

        // List of public routes that don't require authentication
        final publicRoutes = [
          splash,
          login,
          register,
          '/forget-password',
          letsStart
        ];
        final isPublicRoute = publicRoutes.contains(state.uri.toString());

        // If not authenticated and trying to access private route
        if (!isAuthenticated && !isPublicRoute) {
          return login;
        }

        // If authenticated and trying to access login/register
        if (isAuthenticated &&
            (state.uri.toString() == login ||
                state.uri.toString() == register)) {
          return todoList;
        }

        return null;
      },
    );
  }
}
