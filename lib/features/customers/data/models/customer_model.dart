class CustomerModel {
  CustomerModel({
    required this.customerId,
    required this.shopId,
    required this.name,
    this.phone,
    required this.createdAt,
  });

  final String customerId;
  final String shopId;
  final String name;
  final String? phone;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'shopId': shopId,
        'name': name,
        'phone': phone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomerModel.fromMap(Map<dynamic, dynamic> map) => CustomerModel(
        customerId: map['customerId'] as String,
        shopId: map['shopId'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}