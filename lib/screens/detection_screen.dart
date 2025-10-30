
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
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
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _statusMessage = 'Checking location services...';
    });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Location services are disabled.';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Location permissions are denied.';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Location permissions are permanently denied.';
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _statusMessage = 'Fetching location...';
    });

    _currentPosition = await Geolocator.getCurrentPosition();
    
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Searching for nearby messages...';
      _searchNearbyMessages();
      _isLoading = false;
    });
  }

  void _searchNearbyMessages() {
    if (_currentPosition == null) return;

    final geo = GeoFlutterFire();
    final center = geo.point(latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude);
    final collectionReference = FirebaseFirestore.instance.collection('messages');

    _nearbyMessagesStream = geo.collection(collectionRef: collectionReference).within(
          center: center,
          radius: 5,
          field: 'position',
          strictMode: true,
        );
  }


  Future<void> _onMessageTapped(DocumentSnapshot message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    final messageData = message.data() as Map<String, dynamic>;
    final messageId = message.id;
    final senderId = messageData['senderId'];

    if (user.uid == senderId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't collect your own message, Agent.")),
      );
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception("User document does not exist!");
        }

        final discoveredMessages = List<String>.from(userSnapshot.data()!['discoveredMessages'] ?? []);
        if (discoveredMessages.contains(messageId)) {
          return;
        }

        transaction.update(userRef, {
          'discoveryPoints': FieldValue.increment(10),
          'discoveredMessages': FieldValue.arrayUnion([messageId]),
        });
      });

      if (!mounted) return;
      _audioPlayer.play(AssetSource('sounds/success.wav'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("+10 Discovery Points!")),
      );

      if (!mounted) return;
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
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
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
