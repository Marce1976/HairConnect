import 'package:cloud_firestore/cloud_firestore.dart';

class Salon {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? phone;
  final String? description;
  final double? rating;
  final List<String>? galleryImages;
  final GeoPoint? location;
  final String? ownerId;
  final DateTime? createdAt;
  final String? photoUrl;
  final String? instagram;
  final String? facebook;
  final String? website;
  final String? schedule;

  const Salon({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.phone,
    this.description,
    this.rating,
    this.galleryImages,
    this.location,
    this.ownerId,
    this.createdAt,
    this.photoUrl,
    this.instagram,
    this.facebook,
    this.website,
    this.schedule,
  });

  factory Salon.fromMap(String id, Map<String, dynamic> map) {
    return Salon(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String?,
      phone: map['phone'] as String?,
      description: map['description'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      galleryImages: map['galleryImages'] != null
          ? List<String>.from(map['galleryImages'] as List)
          : null,
      location: map['location'] as GeoPoint?,
      ownerId: map['ownerId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      photoUrl: map['photoUrl'] as String?,
      instagram: map['instagram'] as String?,
      facebook: map['facebook'] as String?,
      website: map['website'] as String?,
      schedule: map['schedule'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'city': city,
        'phone': phone,
        'description': description,
        'rating': rating,
        'galleryImages': galleryImages,
        'location': location,
        'ownerId': ownerId,
        'photoUrl': photoUrl,
        'instagram': instagram,
        'facebook': facebook,
        'website': website,
        'schedule': schedule,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
