
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';

class CreateMessageScreen extends StatefulWidget {
  const CreateMessageScreen({super.key});

  @override
  State<CreateMessageScreen> createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  String _message = '';
  bool _isSaving = false;
  final Location _location = Location();

  Future<void> _saveMessage() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });

      try {
        LocationData? currentLocation = await _location.getLocation();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null &&
            currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          await FirebaseFirestore.instance.collection('messages').add({
            'message': _message,
            'userId': user.uid,
            'location': GeoPoint(
                currentLocation.latitude!, currentLocation.longitude!),
            'timestamp': FieldValue.serverTimestamp(),
          });
          if (mounted) {
            context.pop();
          }
        }
      } catch (e) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save message: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your message',
                  hintText: 'Enter your secret message here...',
                ),
                 maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
                onSaved: (value) {
                  _message = value!;
                },
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      onPressed: _saveMessage,
                      label: const Text('SAVE MESSAGE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
