import 'dart:convert';

class Payment {
  int? id;
  String? transactionId;
  String? payerId;
  String currency;
  double total;
  String paymentStatus;
  String paymentMethod;

  Payment({
    this.id,
    this.transactionId,
    this.payerId,
    required this.currency,
    required this.total,
    required this.paymentStatus,
    required this.paymentMethod,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      transactionId: json['transactionId'],
      payerId: json['payerId'],
      currency: json['currency'],
      total: json['total'].toDouble(),
      paymentStatus: json['paymentStatus'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'payerId': payerId,
      'currency': currency,
      'total': total,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
    };
  }
}
