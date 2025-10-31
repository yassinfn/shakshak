import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  String username;
  int discoveryPoints;
  DateTime? lastMessageTimestamp;

  UserModel({
    required this.id,
    required this.username,
    required this.discoveryPoints,
    this.lastMessageTimestamp,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'],
      discoveryPoints: data['discoveryPoints'],
      lastMessageTimestamp: data['lastMessageTimestamp'] != null
          ? (data['lastMessageTimestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'discoveryPoints': discoveryPoints,
      'lastMessageTimestamp': lastMessageTimestamp,
    };
  }
}
