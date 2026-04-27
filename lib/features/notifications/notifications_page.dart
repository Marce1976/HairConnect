import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {

   final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ), 
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('notifications')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes notificaciones'));
          }
          final notifications = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final isRead = notification['read'] ?? false;
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRead ? AppColors.primary : AppColors.primary,
                    child: const Icon(Icons.notifications, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    notification['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    notification['message'] ?? '',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  onTap: () async {
                    await db.collection('notifications')
                        .doc(notifications[index].id)
                        .update({'read': true});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}