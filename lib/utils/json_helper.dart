// lib/data/model/json_helpers.dart
//
// Helper functions untuk parsing JSON yang aman dari backend PostgreSQL.
//
// MASALAH: PostgreSQL mengembalikan kolom NUMERIC/DECIMAL sebagai STRING
// di response JSON (bukan number), untuk menghindari kehilangan presisi
// desimal. Ini perilaku standar driver `pg` di Node.js — BUKAN bug backend.
//
// Contoh: kolom `price NUMERIC` di database, saat di-query lewat `pg`,
// hasilnya adalah `"179.00"` (String), bukan `179.00` (num).
//
// Kalau kode Flutter melakukan `(json['price'] as num).toDouble()`,
// ini akan throw error: "type 'String' is not a subtype of type 'num'"
//
// SOLUSI: gunakan helper ini di semua fromJson() yang membaca angka,
// supaya aman menerima baik String maupun num.

/// Parse dynamic value (String atau num) menjadi double.
/// Aman untuk null — mengembalikan [fallback] jika value null atau tidak valid.
double parseDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

/// Parse dynamic value menjadi int.
/// Aman untuk null dan untuk angka desimal dalam bentuk String (mis. "4.0").
int parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  return fallback;
}
