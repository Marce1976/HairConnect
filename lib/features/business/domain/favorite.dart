import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String id;
  final String userId;
  final String lookId;
  final String salonId;
  final DateTime? createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.lookId,
    required this.salonId,
    this.createdAt,
  });

  factory Favorite.fromMap(String id, Map<String, dynamic> map) {
    return Favorite(
      id: id,
      userId: map['userId'] as String? ?? '',
      lookId: map['lookId'] as String? ?? '',
      salonId: map['salonId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'lookId': lookId,
        'salonId': salonId,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
