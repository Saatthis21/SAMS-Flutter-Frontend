class Receipt {
  final String receiptId;
  final String receiptNumber;
  final String paymentId;
  final String studentId;
  final double amountPaid;
  final double balance;
  final String paymentMethod;
  final String note;

  Receipt({
    required this.receiptId,
    required this.receiptNumber,
    required this.paymentId,
    required this.studentId,
    required this.amountPaid,
    required this.balance,
    required this.paymentMethod,
    required this.note,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      receiptId: json['receipt_id'],
      receiptNumber: json['receipt_number'],
      paymentId: json['payment_id'],
      studentId: json['student_id'],
      amountPaid: double.parse(json['amount_paid'].toString()),
      balance: double.parse(json['balance'].toString()),
      paymentMethod: json['payment_method'],
      note: json['note'],
    );
  }
}