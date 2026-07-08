import 'package:geolocator/geolocator.dart';

/// Hasil pengecekan/pengambilan lokasi, dibungkus supaya UI bisa menampilkan
/// pesan yang tepat (izin ditolak vs GPS mati vs sukses) tanpa harus
/// menangani exception Geolocator secara langsung di layer UI.
class LocationResult {
  final Position? position;
  final String? errorMessage;
  const LocationResult({this.position, this.errorMessage});
  bool get isSuccess => position != null;
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Minta izin (kalau belum ada) lalu ambil posisi GPS user saat ini.
  /// Dipakai untuk fitur "Hotel terdekat dari saya".
  Future<LocationResult> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult(
        errorMessage: 'Layanan lokasi (GPS) sedang mati. Aktifkan dulu di pengaturan perangkat.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult(
          errorMessage: 'Izin lokasi ditolak. Sasacation butuh lokasi untuk menampilkan hotel terdekat.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(
        errorMessage: 'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi di perangkat.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LocationResult(position: position);
    } catch (e) {
      return LocationResult(errorMessage: 'Gagal mengambil lokasi: $e');
    }
  }

  /// Jarak lurus antara dua koordinat dalam kilometer (formula sama dengan
  /// yang dipakai backend di endpoint /hotels/nearby, supaya konsisten).
  double distanceInKm(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
