import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/message_model.dart';
import 'dart:async';
import 'dart:math';

import 'package:provider/provider.dart';
import 'package:myapp/viewmodels/user_viewmodel.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  Position? _currentPosition;
  List<Message> _nearbyMessages = [];
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location services are disabled.')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      }
      return;
    }

    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _getNearbyMessages();
        });
      }
    });
  }

  void _getNearbyMessages() async {
    if (_currentPosition == null) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final messagesRef = FirebaseFirestore.instance.collection('messages');
    final center =
        GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);
    const radius = 500; // in meters

    final lowerLat = center.latitude - (radius / 111320);
    final upperLat = center.latitude + (radius / 111320);
    final lowerLon =
        center.longitude - (radius / (111320 * cos(center.latitude * pi / 180)));
    final upperLon =
        center.longitude + (radius / (111320 * cos(center.latitude * pi / 180)));

    final snapshot = await messagesRef
        .where('location', isGreaterThan: GeoPoint(lowerLat, lowerLon))
        .where('location', isLessThan: GeoPoint(upperLat, upperLon))
        .get();
    if (!mounted) return;
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = userViewModel.user;

    final messages = snapshot.docs
        .map((doc) => Message.fromFirestore(doc))
        .where((message) {
      final distance = Geolocator.distanceBetween(center.latitude,
          center.longitude, message.location.latitude, message.location.longitude);
      return distance <= radius && message.agentId != currentUser?.id;
    }).toList();

    if (mounted) {
      setState(() {
        _nearbyMessages = messages;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detect Messages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nearbyMessages.isEmpty
              ? const Center(child: Text('No messages found nearby.'))
              : ListView.builder(
                  itemCount: _nearbyMessages.length,
                  itemBuilder: (context, index) {
                    final message = _nearbyMessages[index];
                    return ListTile(
                      title: Text(message.text),
                      subtitle: Text('From agent ${message.agentId}'),
                      onTap: () => _handleMessageTapped(message),
                    );
                  },
                ),
    );
  }

  void _handleMessageTapped(Message message) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = userViewModel.user;

    if (currentUser != null) {
      // Prevent user from getting points for their own messages
      if (message.agentId != currentUser.id) {
        // Add discovery points
        currentUser.discoveryPoints += 10;
        userViewModel.updateUser(currentUser);

        // Delete the message after it has been discovered
        FirebaseFirestore.instance.collection('messages').doc(message.id).delete();
        if (!mounted) return;
        // Show a confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Message Discovered!'),
            content: const Text('You have earned 10 discovery points.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Refresh the message list
                  _getNearbyMessages();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
