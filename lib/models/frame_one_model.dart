class FrameOne {
  final int? co2;
  final int? hcho;
  final int? tvoc;

  FrameOne({this.co2, this.hcho, this.tvoc});

  factory FrameOne.fromJson(Map<String, dynamic> json) {
    return FrameOne(
      co2: (json['co2'] as num?)?.toInt(),
      hcho: (json['hcho'] as num?)?.toInt(),
      tvoc: (json['tvoc'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'co2': co2,
      'hcho': hcho,
      'tvoc': tvoc,
    };
  }
}
