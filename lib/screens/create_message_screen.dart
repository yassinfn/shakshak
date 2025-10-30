
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';

class CreateMessageScreen extends StatefulWidget {
  const CreateMessageScreen({super.key});

  @override
  State<CreateMessageScreen> createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _createMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking agent status...';
    });

    final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final userDoc = await userRef.get();
      final userData = userDoc.data()!;
      final username = userData['username'] as String;
      final lastMessageTimestamp = userData['lastMessageTimestamp'] as Timestamp?;

      if (lastMessageTimestamp != null) {
        final now = DateTime.now();
        final lastMessageDate = lastMessageTimestamp.toDate();
        if (now.difference(lastMessageDate).inHours < 24) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You can only post one message every 24 hours.')),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      }
      
      setState(() {
        _statusMessage = 'Getting current location...';
      });

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _statusMessage = 'Submitting message...';
      });

      final geo = GeoFlutterFire();
      final geoPoint = GeoFirePoint(position.latitude, position.longitude);
      final newTimestamp = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance.collection('messages').add({
        'text': _messageController.text.trim(),
        'senderId': user.uid,
        'senderUsername': username,
        'timestamp': newTimestamp,
        'position': geoPoint.data,
      });

      await userRef.update({'lastMessageTimestamp': newTimestamp});

      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Hidden Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Your secret message...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Message cannot be empty';
                  }
                  return null;
                },
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _createMessage,
                  child: const Text('Hide Message'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
