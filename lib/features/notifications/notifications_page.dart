import 'package:flutter/material.dart';
import 'package:hair_connect/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return 'Ahora mismo';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
  return '${date.day}/${date.month}/${date.year}';
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final notificationsRef =
        db.collection('notifications').where('userId', isEqualTo: user?.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: notificationsRef.snapshots(),
            builder: (context, snapshot) {
              final hasUnread =
                  snapshot.data?.docs.any(
                        (doc) => (doc.data() as Map)['read'] != true,
                      ) ??
                      false;
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Marcar todas como leídas',
                onPressed: hasUnread
                    ? () => _markAllAsRead(db, user?.uid)
                    : null,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: AppColors.textGrey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          final notifications = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final notification = doc.data() as Map<String, dynamic>;
              final isRead = notification['read'] ?? false;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                onDismissed: (_) {
                  db.collection('notifications').doc(doc.id).delete();
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isRead
                      ? Colors.white
                      : AppColors.primary.withValues(alpha: 0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        notification['title']?.toString().contains('cancelada') == true
                            ? Icons.cancel
                            : Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isRead ? AppColors.textGrey : AppColors.textDark,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['message'] ?? '',
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                        if (notification['createdAt'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatTimestamp(
                                  notification['createdAt'] as Timestamp),
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () async {
                      await db
                          .collection('notifications')
                          .doc(doc.id)
                          .update({'read': true});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAllAsRead(FirebaseFirestore db, String? userId) async {
    if (userId == null) return;
    final unread = await db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
