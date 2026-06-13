import 'package:cloud_firestore/cloud_firestore.dart';

class Look {
  final String id;
  final String salonId;
  final String salonName;
  final String? stylistId;
  final String? stylistName;
  final String imageUrl;
  final String? description;
  final List<String>? services;
  final String? price;
  final String? salePrice;
  final DateTime? createdAt;

  const Look({
    required this.id,
    required this.salonId,
    required this.salonName,
    this.stylistId,
    this.stylistName,
    required this.imageUrl,
    this.description,
    this.services,
    this.price,
    this.salePrice,
    this.createdAt,
  });

  /// ¿Está en oferta?
  bool get onSale => salePrice != null && salePrice!.isNotEmpty;

  factory Look.fromMap(String id, Map<String, dynamic> map) {
    return Look(
      id: id,
      salonId: map['salonId'] as String? ?? '',
      salonName: map['salonName'] as String? ?? '',
      stylistId: map['stylistId'] as String?,
      stylistName: map['stylistName'] as String?,
      imageUrl: map['imageUrl'] as String? ?? '',
      description: map['description'] as String?,
      services: map['services'] != null
          ? List<String>.from(map['services'] as List)
          : null,
      price: map['price'] as String?,
      salePrice: map['salePrice'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'salonId': salonId,
        'salonName': salonName,
        'stylistId': stylistId,
        'stylistName': stylistName,
        'imageUrl': imageUrl,
        'description': description,
        'services': services,
        'price': price,
        'salePrice': salePrice,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
