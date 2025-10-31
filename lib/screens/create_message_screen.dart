
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
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
      _statusMessage = 'Preparing your message...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final messagesCollection = FirebaseFirestore.instance.collection('messages');

      // Fetch user data first to get username and check timestamp
      final userDoc = await userRef.get();
      final userData = userDoc.data()!;
      final username = userData['username'] as String;
      final lastMessageTimestamp = userData['lastMessageTimestamp'] as Timestamp?;

      // Check if user can post a message
      if (lastMessageTimestamp != null) {
        final now = DateTime.now();
        final lastMessageDate = lastMessageTimestamp.toDate();
        if (now.difference(lastMessageDate).inHours < 24) {
           if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only hide one message every 24 hours.')),
          );
          setState(() => _isLoading = false);
          return; // Stop execution
        }
      }
      
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Acquiring your secret location...';
      });

      // Get the current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Hiding the message...';
      });

      final geo = GeoFlutterFire();
      final geoPoint = geo.point(latitude: position.latitude, longitude: position.longitude);
      final newTimestamp = FieldValue.serverTimestamp(); // Use server timestamp for consistency

      // Create the message in Firestore
      await messagesCollection.add({
        'text': _messageController.text.trim(),
        'senderId': user.uid,
        'senderUsername': username,
        'timestamp': newTimestamp,
        'position': geoPoint.data,
      });

      // Update the user's last message timestamp
      await userRef.update({'lastMessageTimestamp': newTimestamp});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Success! Your message is now hidden.')),
      );
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Failed to hide message: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
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
                  hintText: 'Only agents nearby will be able to see this.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Message cannot be empty.';
                  }
                   if (value.length > 280) {
                    return 'Message cannot exceed 280 characters.';
                  }
                  return null;
                },
                maxLines: 5,
                maxLength: 280,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Hide Message in this Location'),
                  onPressed: _createMessage,
                   style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
