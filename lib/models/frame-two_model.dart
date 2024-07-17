class Frame {
  final int? temp;
  final int? humidity;

  Frame({
    this.temp,
    this.humidity,
  });

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      temp: (json['temp'] as num?)?.toInt(),
      humidity: (json['humidity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'humidity': humidity,
    };
  }
}
