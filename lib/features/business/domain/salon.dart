import 'package:cloud_firestore/cloud_firestore.dart';

class Salon {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? description;
  final double? rating;
  final List<String>? galleryImages;
  final GeoPoint? location;
  final DateTime? createdAt;

  const Salon({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.description,
    this.rating,
    this.galleryImages,
    this.location,
    this.createdAt,
  });

  factory Salon.fromMap(String id, Map<String, dynamic> map) {
    return Salon(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String?,
      description: map['description'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      galleryImages: map['galleryImages'] != null
          ? List<String>.from(map['galleryImages'] as List)
          : null,
      location: map['location'] as GeoPoint?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'phone': phone,
        'description': description,
        'rating': rating,
        'galleryImages': galleryImages,
        'location': location,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
