import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/viewmodels/user_viewmodel.dart';

class ProfileConfigScreen extends StatefulWidget {
  const ProfileConfigScreen({super.key});

  @override
  State<ProfileConfigScreen> createState() => _ProfileConfigScreenState();
}

class _ProfileConfigScreenState extends State<ProfileConfigScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _setUsername,
                    child: const Text('Save'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _setUsername() async {
    if (_usernameController.text.isEmpty) {
      return;
    }
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await userViewModel.setUsername(_usernameController.text);

    if (success) {
      // The HomeScreenDispatcher will handle navigation
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken.')),
        );
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
