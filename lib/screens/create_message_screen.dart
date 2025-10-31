import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:myapp/viewmodels/user_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateMessageScreen extends StatefulWidget {
  const CreateMessageScreen({super.key});

  @override
  State<CreateMessageScreen> createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {
  final _messageController = TextEditingController();
  Position? _currentPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle permission denied
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 20),
            if (_currentPosition != null)
              Text(
                  'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Text('Send'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _currentPosition == null) {
      return;
    }
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final user = userViewModel.user;

    if (user != null) {
      await FirebaseFirestore.instance.collection('messages').add({
        'agentId': user.id,
        'text': _messageController.text,
        'location':
            GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update user's last message timestamp
      user.lastMessageTimestamp = DateTime.now();
      await userViewModel.updateUser(user);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    }
  }
}
