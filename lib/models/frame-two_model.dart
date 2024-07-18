class Frame {
  // final DateTime? date;
  final int? temp;
  final int? humidity;

  Frame({
    this.temp,
    this.humidity,
    // this.date,
  });

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      temp: json['temp'],
      humidity: json['humidity'],
      /*  date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,*/
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'humidity': humidity,
      //'date': date?.millisecondsSinceEpoch,
    };
  }
}
