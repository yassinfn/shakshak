import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/viewmodels/user_viewmodel.dart';
import 'package:myapp/screens/create_message_screen.dart';
import 'package:myapp/screens/detection_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final user = userViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.username ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => userViewModel.signOut(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Agent ${user?.username}!'),
            Text('Discovery Points: ${user?.discoveryPoints}'),
            Text('Last Message: ${user?.lastMessageTimestamp}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateMessageScreen(),
                  ),
                );
              },
              child: const Text('Create a Message'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetectionScreen(),
                  ),
                );
              },
              child: const Text('Detect Messages'),
            ),
          ],
        ),
      ),
    );
  }
}
