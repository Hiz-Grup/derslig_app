class PendingPurchaseModel {
  final String transactionId;
  final String productIdentifier;
  final DateTime purchaseDate;
  final DateTime? expirationDate;
  final bool isTrialPeriod;
  final bool willRenew;
  final bool isSubscription;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastRetryAt;

  @Deprecated('Use productIdentifier instead')
  final String? productId;

  PendingPurchaseModel({
    required this.transactionId,
    required this.productIdentifier,
    required this.purchaseDate,
    this.expirationDate,
    this.isTrialPeriod = false,
    this.willRenew = true,
    this.isSubscription = true,
    this.retryCount = 0,
    DateTime? createdAt,
    this.lastRetryAt,
    this.productId,
  }) : createdAt = createdAt ?? DateTime.now();


  factory PendingPurchaseModel.subscription({
    required String transactionId,
    required String productIdentifier,
    required DateTime purchaseDate,
    DateTime? expirationDate,
    required bool isTrialPeriod,
    required bool willRenew,
  }) {
    return PendingPurchaseModel(
      transactionId: transactionId,
      productIdentifier: productIdentifier,
      purchaseDate: purchaseDate,
      expirationDate: expirationDate,
      isTrialPeriod: isTrialPeriod,
      willRenew: willRenew,
      isSubscription: true,
    );
  }

  @Deprecated('Use PendingPurchaseModel.subscription instead')
  factory PendingPurchaseModel.legacy({
    required String transactionId,
    required String productId,
    required String productIdentifier,
    required DateTime purchaseDate,
  }) {
    return PendingPurchaseModel(
      transactionId: transactionId,
      productIdentifier: productIdentifier,
      purchaseDate: purchaseDate,
      isSubscription: false,
      productId: productId,
    );
  }

  PendingPurchaseModel copyWithIncrementedRetry() {
    return PendingPurchaseModel(
      transactionId: transactionId,
      productIdentifier: productIdentifier,
      purchaseDate: purchaseDate,
      expirationDate: expirationDate,
      isTrialPeriod: isTrialPeriod,
      willRenew: willRenew,
      isSubscription: isSubscription,
      retryCount: retryCount + 1,
      createdAt: createdAt,
      lastRetryAt: DateTime.now(),
      productId: productId,
    );
  }

  factory PendingPurchaseModel.fromJson(Map<String, dynamic> json) {
    return PendingPurchaseModel(
      transactionId: json['transactionId'] as String,
      productIdentifier: json['productIdentifier'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      expirationDate: json['expirationDate'] != null ? DateTime.parse(json['expirationDate'] as String) : null,
      isTrialPeriod: json['isTrialPeriod'] as bool? ?? false,
      willRenew: json['willRenew'] as bool? ?? true,
      isSubscription: json['isSubscription'] as bool? ?? true,
      retryCount: json['retryCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      lastRetryAt: json['lastRetryAt'] != null ? DateTime.parse(json['lastRetryAt'] as String) : null,
      productId: json['productId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'productIdentifier': productIdentifier,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'isTrialPeriod': isTrialPeriod,
      'willRenew': willRenew,
      'isSubscription': isSubscription,
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
      'lastRetryAt': lastRetryAt?.toIso8601String(),
      'productId': productId,
    };
  }

  @override
  String toString() {
    return 'PendingPurchaseModel(transactionId: $transactionId, productIdentifier: $productIdentifier, isSubscription: $isSubscription, retryCount: $retryCount)';
  }
}
