// ─── Checkout Session ────────────────────────────────────────────────────────
class CheckoutPricing {
  final double pricePerNight;
  final double subtotal;
  final double tax;
  final double taxRate;
  final double serviceFee;
  final double total;
  final String currency;

  const CheckoutPricing({
    required this.pricePerNight,
    required this.subtotal,
    required this.tax,
    required this.taxRate,
    required this.serviceFee,
    required this.total,
    required this.currency,
  });

  factory CheckoutPricing.fromJson(Map<String, dynamic> json) => CheckoutPricing(
        pricePerNight: (json['pricePerNight'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
        tax: (json['tax'] as num).toDouble(),
        taxRate: (json['taxRate'] as num).toDouble(),
        serviceFee: (json['serviceFee'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        currency: json['currency'] ?? 'USD',
      );
}

class CheckoutSession {
  final String sessionId;
  final Map<String, dynamic> hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int guestCount;
  final String notes;
  final CheckoutPricing pricing;
  final List<PaymentMethod> paymentMethods;
  final String status;
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
        paidAt: DateTime.parse(json['payment']['paidAt']),
        bookingCode: json['booking']['bookingCode'],
        hotelName: json['booking']['hotelName'],
        checkIn: DateTime.parse(json['booking']['checkIn']),
        checkOut: DateTime.parse(json['booking']['checkOut']),
        nights: json['booking']['nights'],
      );
}
