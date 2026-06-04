import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceItem {
  final String id;
  final String name;
  final String price;
  final String duration;
  final DateTime? createdAt;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.createdAt,
  });

  factory ServiceItem.fromMap(String id, Map<String, dynamic> map) {
    return ServiceItem(
      id: id,
      name: map['name'] as String? ?? '',
      price: map['price'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
