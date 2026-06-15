class Payment {
  final String paymentId;
  final String studentId;
  final String feeId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String transactionRef;

  Payment({
    required this.paymentId,
    required this.studentId,
    required this.feeId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.transactionRef,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'],
      studentId: json['student_id'],
      feeId: json['fee_id'],
      amount: double.parse(json['amount'].toString()),
      paymentMethod: json['payment_method'],
      status: json['status'],
      transactionRef: json['transaction_ref'],
    );
  }
}