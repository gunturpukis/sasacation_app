// ─── Checkout Session ────────────────────────────────────────────────────────
class CheckoutPricing {
  final double pricePerNight;
  final double subtotal;
  final double tax;
  final double taxRate;
  final double serviceFee;
  /// F4: cleaning fee dari backend (0 bila tak ada — parser toleran).
  final double cleaningFee;
  final double total;
  final String currency;

  /// F14: `pricing.fx.usd_to_idr_rate` — kurs resmi server untuk layar ini.
  /// Null = ikut rate global (atau mode USD bila belum ada).
  final double? fxRate;

  const CheckoutPricing({
    required this.pricePerNight,
    required this.subtotal,
    required this.tax,
    required this.taxRate,
    required this.serviceFee,
    this.cleaningFee = 0,
    required this.total,
    required this.currency,
    this.fxRate,
  });

  factory CheckoutPricing.fromJson(Map<String, dynamic> json) {
    double numVal(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0;
    }

    final fx = json['fx'];
    double? fxRate;
    if (fx is Map) {
      final v = fx['usd_to_idr_rate'];
      final r = v is num ? v.toDouble() : double.tryParse('$v');
      if (r != null && r > 0) fxRate = r;
    }
    return CheckoutPricing(
      pricePerNight: numVal('pricePerNight'),
      subtotal: numVal('subtotal'),
      tax: numVal('tax'),
      taxRate: numVal('taxRate'),
      serviceFee: numVal('serviceFee'),
      cleaningFee: numVal('cleaningFee'),
      total: numVal('total'),
      currency: json['currency'] ?? 'USD',
      fxRate: fxRate,
    );
  }
}

class CheckoutSession {
  final String? sessionId;
  final Map<String, dynamic> hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int guestCount;
  final String? notes;
  final CheckoutPricing pricing;
  final List<PaymentMethod> paymentMethods;
  final String? status;
  final DateTime expiresAt;

  const CheckoutSession({
    required this.sessionId,
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guestCount,
    required this.notes,
    required this.pricing,
    required this.paymentMethods,
    required this.status,
    required this.expiresAt,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) => CheckoutSession(
        sessionId: json['sessionId'],
        hotel: Map<String, dynamic>.from(json['hotel']),
        checkIn: DateTime.parse(json['checkIn']),
        checkOut: DateTime.parse(json['checkOut']),
        nights: json['nights'],
        guestCount: json['guestCount'],
        notes: json['notes'] ?? '',
        pricing: CheckoutPricing.fromJson(json['pricing']),
        paymentMethods: (json['paymentMethods'] as List? ?? [])
            .map((m) => PaymentMethod.fromJson(m))
            .toList(),
        status: json['status'],
        expiresAt: DateTime.parse(json['expiresAt']),
      );
}

// ─── Payment Method ───────────────────────────────────────────────────────────
class PaymentMethod {
  final String id;
  final String label;
  final String icon;
  final bool available;

  const PaymentMethod({
    required this.id,
    required this.label,
    required this.icon,
    required this.available,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'],
        label: json['label'],
        icon: json['icon'] ?? 'payment',
        available: json['available'] ?? true,
      );
}

// ─── Kartu tersimpan (F4) ─────────────────────────────────────────────────────
// GET /payment-methods → [{ id, brand, last4, exp, is_primary, label }].
// Kartu hanya tercatat setelah user mencentang "simpan kartu" di Snap
// (param saveCard saat /pay) — daftar kosong = belum pernah menyimpan.
class SavedPaymentMethod {
  final String id;
  final String brand;
  final String last4;
  final String? exp;
  final bool isPrimary;
  final String? label;

  const SavedPaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    this.exp,
    this.isPrimary = false,
    this.label,
  });

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) =>
      SavedPaymentMethod(
        id: (json['id'] ?? '').toString(),
        brand: (json['brand'] ?? '').toString(),
        last4: (json['last4'] ?? '').toString(),
        exp: json['exp']?.toString(),
        isPrimary: json['is_primary'] == true || json['isPrimary'] == true,
        label: json['label']?.toString(),
      );

  /// Nama tampilan: julukan user bila ada, kalau tidak brand + 4 digit.
  String get displayName {
    final base = '${brand.toUpperCase()} •• $last4';
    return label != null && label!.isNotEmpty ? '$base ($label)' : base;
  }
}

// ─── Checkout Payment Initiated (respons baru /checkout/pay) ──────────────────
// Sebelumnya /checkout/pay langsung mengembalikan PaymentResult (payment
// sukses instan, tanpa gateway sungguhan). Sekarang payment gateway asli
// (Midtrans) butuh user menyelesaikan pembayaran dulu di halaman Snap —
// response ini cuma berisi info buat MEMBUKA halaman itu, bukan hasil akhir.
class CheckoutPaymentInitiated {
  final String transactionId;
  final String bookingCode;
  final String snapToken;
  final String redirectUrl;

  const CheckoutPaymentInitiated({
    required this.transactionId,
    required this.bookingCode,
    required this.snapToken,
    required this.redirectUrl,
  });

  factory CheckoutPaymentInitiated.fromJson(Map<String, dynamic> json) => CheckoutPaymentInitiated(
        transactionId: json['payment']['transactionId'],
        bookingCode: json['booking']['booking_code'] ?? json['booking']['bookingCode'] ?? '',
        snapToken: json['snapToken'] ?? '',
        redirectUrl: json['redirectUrl'] ?? '',
      );
}

// ─── Payment Result ───────────────────────────────────────────────────────────
class PaymentResult {
  final String transactionId;
  final String method;
  final double amount;
  final String status;
  final DateTime paidAt;

  // Booking info
  final String bookingCode;
  final String hotelName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;

  const PaymentResult({
    required this.transactionId,
    required this.method,
    required this.amount,
    required this.status,
    required this.paidAt,
    required this.bookingCode,
    required this.hotelName,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
        transactionId: json['payment']['transactionId'],
        method: json['payment']['method'],
        amount: (json['payment']['amount'] as num).toDouble(),
        status: json['payment']['status'],
        paidAt: json['payment']['paidAt'] != null
            ? DateTime.parse(json['payment']['paidAt'])
            : DateTime.now(),
        bookingCode: json['booking']['bookingCode'],
        hotelName: json['booking']['hotelName'],
        checkIn: DateTime.parse(json['booking']['checkIn']),
        checkOut: DateTime.parse(json['booking']['checkOut']),
        nights: json['booking']['nights'],
      );
}
