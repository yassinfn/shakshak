import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/viewmodels/user_viewmodel.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/profile_config_screen.dart';
import 'package:myapp/screens/login_screen.dart'; // Import the login screen

class HomeScreenDispatcher extends StatelessWidget {
  const HomeScreenDispatcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        if (userViewModel.firebaseUser == null) {
          // User not logged in, show the login screen
          return const LoginScreen();
        } else if (userViewModel.user == null) {
          // User is logged in but profile is not set up
          return const ProfileConfigScreen();
        } else {
          // User is logged in and profile is set up
          return const DashboardScreen();
        }
      },
    );
  }
}
