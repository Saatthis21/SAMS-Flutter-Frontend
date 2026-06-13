class LabSection {
  final int labID;
  final String labNum;
  final String date;
  final String time;
  final String? date2; 
  final String? time2; 
  final int currentCapacity;
  final int maxCapacity;

  // This is the constructor that was accidentally deleted!
  LabSection({
    required this.labID,
    required this.labNum,
    required this.date,
    required this.time,
    this.date2,
    this.time2,
    required this.currentCapacity,
    required this.maxCapacity,
  });

  factory LabSection.fromJson(Map<String, dynamic> json) {
    return LabSection(
      labID: json['labID'],
      labNum: json['lab_num'],
      date: json['date'],
      time: json['time'],
      date2: json['date_2'], 
      time2: json['time_2'], 
      currentCapacity: json['current_capacity'],
      maxCapacity: json['max_capacity'],
    );
  }
}