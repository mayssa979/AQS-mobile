class Frame {
  final DateTime? date;
  final int? temp;
  final int? humidity;

  Frame({
    this.temp,
    this.humidity,
    this.date,
  });

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      temp: (json['temp'] as num?)?.toInt(),
      humidity: (json['humidity'] as num?)?.toInt(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'humidity': humidity,
      'date': date,
    };
  }
}
