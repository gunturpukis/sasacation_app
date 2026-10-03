import 'package:sasacation/data/api/api_client.dart';

/// F13: cuaca destinasi (publik, cache server 10 menit).
/// `alert == null` → panggil {@code hasAlert} false dan UI WAJIB
/// menyembunyikan kartu (aturan: tidak ada data palsu).
class WeatherAlert {
  final String severity; // high|medium
  final String kind; // thunderstorm|heavy_rain
  final String title;
  final String window;

  const WeatherAlert({
    required this.severity,
    required this.kind,
    required this.title,
    required this.window,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) =>
      WeatherAlert(
        severity: (json['severity'] ?? 'medium').toString(),
        kind: (json['kind'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        window: (json['window'] ?? '').toString(),
      );

  bool get isHigh => severity == 'high';
}

class WeatherInfo {
  final double? tempC;
  final String? description;
  final String? location;
  final WeatherAlert? alert;

  const WeatherInfo({
    this.tempC,
    this.description,
    this.location,
    this.alert,
  });

  bool get hasAlert => alert != null;

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final rawAlert = json['alert'];
    double? temp;
    final t = current is Map ? current['temp_c'] : null;
    if (t is num) {
      temp = t.toDouble();
    } else {
      temp = double.tryParse('$t');
    }
    return WeatherInfo(
      tempC: temp,
      description: current is Map
          ? current['description']?.toString()
          : null,
      location:
          current is Map ? current['location']?.toString() : null,
      alert: rawAlert is Map
          ? WeatherAlert.fromJson(
              Map<String, dynamic>.from(rawAlert))
          : null,
    );
  }
}

class WeatherRepository {
  Future<WeatherInfo?> getWeather({
    required double lat,
    required double lng,
  }) async {
    try {
      final res = await ApiClient.get('/weather', params: {
        'lat': lat,
        'lng': lng,
      });
      final raw = res.data['data'];
      if (raw is! Map) return null;
      return WeatherInfo.fromJson(
          Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }
}
