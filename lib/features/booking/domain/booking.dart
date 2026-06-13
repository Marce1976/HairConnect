import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String businessId;
  final String service;
  final String date;
  final String time;
  final String stylist;
  final String status;
  final String? lookId;
  final String? salonName;
  final List<String>? services;
  final String? price;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.service,
    required this.date,
    required this.time,
    required this.stylist,
    required this.status,
    this.lookId,
    this.salonName,
    this.services,
    this.price,
    this.createdAt,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'] as String? ?? '',
      businessId: map['businessId'] as String? ?? '',
      service: map['service'] as String? ?? '',
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      stylist: map['stylist'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      lookId: map['lookId'] as String?,
      salonName: map['salonName'] as String?,
      services: map['services'] != null
          ? List<String>.from(map['services'] as List)
          : null,
      price: map['price'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessId': businessId,
      'service': service,
      'date': date,
      'time': time,
      'stylist': stylist,
      'status': status,
      'lookId': lookId,
      'salonName': salonName,
      'services': services,
      'price': price,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
