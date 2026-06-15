class Fee {
  final String feesId;
  final String studentId;
  final double totalFee;
  final double paidAmount;
  final double balance;
  final String status;

  Fee({
    required this.feesId,
    required this.studentId,
    required this.totalFee,
    required this.paidAmount,
    required this.balance,
    required this.status,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      feesId: json['fees_id'],
      studentId: json['student_id'],
      totalFee: double.parse(json['total_fee'].toString()),
      paidAmount: double.parse(json['paid_amount'].toString()),
      balance: double.parse(json['balance'].toString()),
      status: json['status'],
    );
  }
}