class FeeStructure {

  final int id;
  final String program;
  final String semester;
  final double feeAmount;
  final int deadlineWeek;

  FeeStructure({
    required this.id,
    required this.program,
    required this.semester,
    required this.feeAmount,
    required this.deadlineWeek,
  });

  factory FeeStructure.fromJson(
      Map<String, dynamic> json) {

    return FeeStructure(
      id: json["id"],
      program: json["program"],
      semester: json["semester"],
      feeAmount:
          double.parse(json["fee_amount"].toString()),
      deadlineWeek: json["deadline_week"],
    );
  }
}