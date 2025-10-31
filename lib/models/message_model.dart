import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String agentId;
  final String text;
  final GeoPoint location;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.agentId,
    required this.text,
    required this.location,
    required this.timestamp,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      agentId: data['agentId'],
      text: data['text'],
      location: data['location'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
