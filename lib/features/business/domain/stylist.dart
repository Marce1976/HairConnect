import 'package:cloud_firestore/cloud_firestore.dart';

class Stylist {
  final String id;
  final String name;
  final DateTime? createdAt;

  const Stylist({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory Stylist.fromMap(String id, Map<String, dynamic> map) {
    return Stylist(
      id: id,
      name: map['name'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
