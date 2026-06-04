class Invoice {
  final String id;
  final String businessId;
  final double amount;
  final String status;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.businessId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });
}
