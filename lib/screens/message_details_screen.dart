
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageDetailsScreen extends StatelessWidget {
  final String messageId;
  const MessageDetailsScreen({super.key, required this.messageId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('messages').doc(messageId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Center(child: Text("Document does not exist"));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            final GeoPoint? location = data['location'];
            final Timestamp? timestamp = data['timestamp'];
            final String formattedDate = timestamp != null
                ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                : 'N/A';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // To make the card wrap content
                    children: [
                      Text(
                        '"${data['message']}"',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                           fontStyle: FontStyle.italic,
                           fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Posted by'),
                        subtitle: Text(
                          data['userId'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Posted on'),
                        subtitle: Text(formattedDate),
                      ),
                      if (location != null)
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: const Text('Location'),
                          subtitle: Text('Lat: ${location.latitude.toStringAsFixed(4)}, Lon: ${location.longitude.toStringAsFixed(4)}'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
