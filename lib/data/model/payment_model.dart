/// Model: PaymentModel
/// Merepresentasikan satu baris riwayat pembayaran REAL dari tabel `payments`.
class PaymentModel {
  final String id;
  final String transactionId;
  final String method;
  final double amount;
  final String currency;
  final String status; // success | failed | refunded
  final DateTime paidAt;
  final String bookingCode;
  final String hotelName;
  final String hotelLocation;
  final String hotelImage;
 
  const PaymentModel({
    required this.id,
    required this.transactionId,
    required this.method,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paidAt,
    required this.bookingCode,
    required this.hotelName,
    required this.hotelLocation,
    required this.hotelImage,
  });
 
  // FIX: sebelumnya pakai `as String` langsung, crash kalau field null
  // (mis. data lama sebelum constraint NOT NULL ada, atau join yang tidak
  // lengkap). Sekarang semua field defensif dengan fallback, supaya satu
  // baris data yang tidak lengkap tidak menjatuhkan seluruh screen.
  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String? ?? '',
        transactionId: json['transaction_id'] as String? ?? '-',
        method: json['method'] as String? ?? 'unknown',
        amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) ?? 0 : 0,
        currency: json['currency'] as String? ?? 'USD',
        status: json['status'] as String? ?? 'unknown',
        paidAt: json['paid_at'] != null
            ? (DateTime.tryParse(json['paid_at'] as String) ?? DateTime.now())
            : DateTime.now(),
        bookingCode: json['booking_code'] as String? ?? '-',
        hotelName: json['hotel_name'] as String? ?? 'Hotel tidak diketahui',
        hotelLocation: json['hotel_location'] as String? ?? '',
        hotelImage: json['hotel_image'] as String? ?? '',
      );
}
 