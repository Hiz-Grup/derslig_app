class PendingPurchaseModel {
  final String transactionId;
  final String productId;
  final String productIdentifier;
  final DateTime purchaseDate;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastRetryAt;

  PendingPurchaseModel({
    required this.transactionId,
    required this.productId,
    required this.productIdentifier,
    required this.purchaseDate,
    this.retryCount = 0,
    DateTime? createdAt,
    this.lastRetryAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PendingPurchaseModel copyWithIncrementedRetry() {
    return PendingPurchaseModel(
      transactionId: transactionId,
      productId: productId,
      productIdentifier: productIdentifier,
      purchaseDate: purchaseDate,
      retryCount: retryCount + 1,
      createdAt: createdAt,
      lastRetryAt: DateTime.now(),
    );
  }

  factory PendingPurchaseModel.fromJson(Map<String, dynamic> json) {
    return PendingPurchaseModel(
      transactionId: json['transactionId'] as String,
      productId: json['productId'] as String,
      productIdentifier: json['productIdentifier'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      lastRetryAt: json['lastRetryAt'] != null ? DateTime.parse(json['lastRetryAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'productId': productId,
      'productIdentifier': productIdentifier,
      'purchaseDate': purchaseDate.toIso8601String(),
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
      'lastRetryAt': lastRetryAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PendingPurchaseModel(transactionId: $transactionId, productId: $productId, retryCount: $retryCount)';
  }
}
