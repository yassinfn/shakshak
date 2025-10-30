
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/dashboard_screen.dart';

class HomeScreenDispatcher extends StatelessWidget {
  const HomeScreenDispatcher({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // This should technically not happen if AuthWrapper is working correctly
      // But as a fallback, we can navigate back to the profile config
      // For now, just show an error.
      return const Scaffold(
        body: Center(
          child: Text('Error: No user logged in.'),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // If the user document doesn't exist, something went wrong during creation.
          // We could redirect to a recovery screen, but for now, show an error.
          // This might happen if the user closes the app right after creating the account
          // before the firestore document is created.
          return const Scaffold(
            body: Center(
              child: Text('Error: User profile not found. Please restart the app.'),
            ),
          );
        }

        // User document exists, proceed to the dashboard
        return const DashboardScreen();
      },
    );
  }
}
