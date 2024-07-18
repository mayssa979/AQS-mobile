class FrameOne {
  // final DateTime? date;
  final int? co2;
  final int? hcho;
  final int? tvoc;

  FrameOne({
    this.co2,
    this.hcho,
    this.tvoc,
    //  this.date,
  });

  factory FrameOne.fromJson(Map<String, dynamic> json) {
    return FrameOne(
      co2: json['co2'] as int?,
      hcho: json['hcho'] as int?,
      tvoc: json['tvoc'] as int?,
      // date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'co2': co2,
      'hcho': hcho,
      'tvoc': tvoc,
      //   'date': date?.millisecondsSinceEpoch,
    };
  }
}
