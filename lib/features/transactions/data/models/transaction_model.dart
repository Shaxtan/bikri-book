enum TxnType { sale, expense, credit }

class TransactionModel {
  TransactionModel({
    required this.txnId,
    required this.shopId,
    required this.amount,
    required this.expression,
    required this.typeIndex,
    required this.createdAt,
    this.itemName,
    this.customerName,
    this.notes,
    this.isDeleted = false,
    this.synced = false,
  });

  final String txnId;
  final String shopId;
  final double amount;
  final String expression;
  final int typeIndex;
  final DateTime createdAt;
  final String? itemName;
  final String? customerName;
  final String? notes;
  final bool isDeleted;
  final bool synced;

  TxnType get type => TxnType.values[typeIndex];

  double get signedAmount =>
      type == TxnType.expense ? -amount : amount;

  // Convert to Map for Hive storage
  Map<String, dynamic> toMap() => {
        'txnId': txnId,
        'shopId': shopId,
        'amount': amount,
        'expression': expression,
        'typeIndex': typeIndex,
        'createdAt': createdAt.toIso8601String(),
        'itemName': itemName,
        'customerName': customerName,
        'notes': notes,
        'isDeleted': isDeleted,
        'synced': synced,
      };

  // Restore from Hive map
  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) =>
      TransactionModel(
        txnId: map['txnId'] as String,
        shopId: map['shopId'] as String,
        amount: (map['amount'] as num).toDouble(),
        expression: map['expression'] as String,
        typeIndex: map['typeIndex'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
        itemName: map['itemName'] as String?,
        customerName: map['customerName'] as String?,
        notes: map['notes'] as String?,
        isDeleted: map['isDeleted'] as bool? ?? false,
        synced: map['synced'] as bool? ?? false,
      );

  TransactionModel copyWith({bool? isDeleted}) => TransactionModel(
        txnId: txnId,
        shopId: shopId,
        amount: amount,
        expression: expression,
        typeIndex: typeIndex,
        createdAt: createdAt,
        itemName: itemName,
        customerName: customerName,
        notes: notes,
        isDeleted: isDeleted ?? this.isDeleted,
        synced: synced,
      );
}