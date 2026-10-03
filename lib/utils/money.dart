import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sasacation/data/api/api_client.dart';

/// S1.1 — Tampilan harga Rupiah untuk turis domestik.
///
/// Kontrak backend (SPRINT1_BACKEND_REQUESTS.md): `GET /forex/rate` →
/// `{ usdToIdr }`. Selama endpoint belum ada/gagal, SEMUA harga tampil USD
/// seperti semula (tidak ada konversi palsu dari kurs hardcode).
///
/// Aturan jujur: angka Rp adalah ESTIMASI kurs — yang ditagih Midtrans
/// mengikuti hitungan server. Widget [MoneyText] otomatis menambah
/// penanda estimasi bila diminta via [estimateSuffix}.
class ForexService {
  static double? _rate;
  static DateTime? _fetchedAt;

  /// Rate aktif (null = mode USD). Widget dengarkan via [rateListenable].
  static final ValueNotifier<double?> rateListenable =
      ValueNotifier<double?>(null);

  static Future<void> refresh({bool force = false}) async {
    if (!force &&
        _rate != null &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) <
            const Duration(hours: 1)) {
      rateListenable.value ??= _rate;
      return;
    }
    try {
      final res = await ApiClient.get('/forex/rate');
      final raw = res.data['data'];
      final v = raw is Map ? raw['usdToIdr'] : null;
      final r = v is num ? v.toDouble() : double.tryParse('$v');
      if (r != null && r > 0) {
        _rate = r;
        _fetchedAt = DateTime.now();
        rateListenable.value = r;
      }
    } catch (_) {
      // Tetap mode USD — kegagalan kurs tidak boleh merusak layar harga.
    }
  }
}

class Money {
  Money._();

  static String _idr(double amountIdr) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
          .format(amountIdr);

  /// Format jumlah USD ke tampilan. Bila [rate] ada → Rp, bila tidak → $.
  static String format(double usdAmount,
      {double? rate, int usdDecimals = 0}) {
    if (rate == null) {
      return '\$${usdAmount.toStringAsFixed(usdDecimals)}';
    }
    return _idr(usdAmount * rate);
  }

  /// Format sekali-jalan memakai kurs terakhir yang berhasil dimuat
  /// (tidak live-update). Untuk label string yang tidak bisa memakai
  /// [MoneyText], mis. [PillBadge].
  static String formatSync(double usdAmount, {int usdDecimals = 0}) =>
      format(usdAmount,
          rate: ForexService.rateListenable.value,
          usdDecimals: usdDecimals);
}

/// Teks harga yang otomatis ikut kurs saat [ForexService] berhasil memuat.
/// Pakai di SEMUA tampilan harga user (jangan format manual lagi).
class MoneyText extends StatelessWidget {
  final double usd;
  final TextStyle? style;
  final String suffix;
  final TextStyle? suffixStyle;
  final int usdDecimals;

  /// Ditampilkan di belakang nominal HANYA saat mode Rp aktif,
  /// mis. ' (estimasi)' untuk total tagihan.
  final String estimateSuffix;

  const MoneyText(
    this.usd, {
    super.key,
    this.style,
    this.suffix = '',
    this.suffixStyle,
    this.usdDecimals = 0,
    this.estimateSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double?>(
      valueListenable: ForexService.rateListenable,
      builder: (context, rate, _) {
        final base =
            DefaultTextStyle.of(context).style.merge(style);
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: Money.format(usd,
                      rate: rate, usdDecimals: usdDecimals),
                  style: base),
              if (suffix.isNotEmpty)
                TextSpan(
                    text: suffix,
                    style: base.merge(suffixStyle)),
              if (rate != null && estimateSuffix.isNotEmpty)
                TextSpan(
                    text: estimateSuffix,
                    style: base.merge(const TextStyle(fontSize: 11))),
            ],
          ),
        );
      },
    );
  }
}
