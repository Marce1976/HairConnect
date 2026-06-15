import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final int minStock;
  final String unit;
  final double price;
  final String salonId;
  final List<String> serviceIds;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.quantity,
    this.minStock = 5,
    this.unit = 'unidad',
    this.price = 0.0,
    required this.salonId,
    this.serviceIds = const [],
    this.createdAt,
  });

  bool get isLowStock => quantity <= minStock;

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      minStock: map['minStock'] as int? ?? 5,
      unit: map['unit'] as String? ?? 'unidad',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      salonId: map['salonId'] as String? ?? '',
      serviceIds: map['serviceIds'] != null
          ? List<String>.from(map['serviceIds'])
          : [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'minStock': minStock,
      'unit': unit,
      'price': price,
      'salonId': salonId,
      'serviceIds': serviceIds,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    int? minStock,
    String? unit,
    double? price,
    String? salonId,
    List<String>? serviceIds,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      salonId: salonId ?? this.salonId,
      serviceIds: serviceIds ?? this.serviceIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
