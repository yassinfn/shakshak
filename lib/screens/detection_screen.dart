
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  Position? _currentPosition;
  bool _isLoading = true;
  String _statusMessage = 'Initializing...';
  Stream<List<DocumentSnapshot>>? _nearbyMessagesStream;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // ... (same as before)
  }

  void _searchNearbyMessages() {
    // ... (same as before)
  }

  void _onMessageTapped(DocumentSnapshot message) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messageData = message.data() as Map<String, dynamic>;
    final messageId = message.id;
    final senderId = messageData['senderId'];

    // Prevent user from getting points from their own messages
    if (user.uid == senderId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't collect your own message, Agent.")),
      );
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("User document does not exist!");
      }

      final discoveredMessages = List<String>.from(userSnapshot.data()!['discoveredMessages'] ?? []);
      if (discoveredMessages.contains(messageId)) {
        // Already discovered
        return;
      }

      // Add points and mark as discovered
      transaction.update(userRef, {
        'discoveryPoints': FieldValue.increment(10),
        'discoveredMessages': FieldValue.arrayUnion([messageId]),
      });

    }).then((_) {
      _audioPlayer.play(AssetSource('sounds/success.wav')); // Assuming you have this asset
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("+10 Discovery Points!")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    });

    // You might want to show a dialog with the message text here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("From: Agent ${messageData['senderUsername']}"),
        content: Text(messageData['text']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Detection'),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              )
            : _buildDetectionUI(),
      ),
    );
  }

  Widget _buildDetectionUI() {
    if (_currentPosition == null) {
      return Text(_statusMessage);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Current Location: (${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: _nearbyMessagesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No messages found within 5km. The area is clear, Agent.'),
                );
              }

              final messages = snapshot.data!;
              final currentUser = FirebaseAuth.instance.currentUser;

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final messageData = message.data() as Map<String, dynamic>;

                  final bool isOwnMessage = currentUser?.uid == messageData['senderId'];

                  return ListTile(
                    leading: Icon(isOwnMessage ? Icons.adjust : Icons.message),
                    title: Text(messageData['text'] ?? 'No text'),
                    subtitle: Text('From: Agent ${messageData['senderUsername']}'),
                    onTap: () => _onMessageTapped(message),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
    @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

}
