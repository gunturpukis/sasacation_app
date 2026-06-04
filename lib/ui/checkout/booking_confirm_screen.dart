import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/checkout_model.dart';
import 'package:sasacation/route/approuter.dart';

/// View: BookingConfirmScreen
/// Ditampilkan setelah pembayaran berhasil — full confirmation page.
class BookingConfirmScreen extends StatelessWidget {
  final PaymentResult result;

  const BookingConfirmScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, dd MMM yyyy');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Success header ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.75)],
                  ),
                ),
                child: Column(
                  children: [
                    // Animated check icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembayaran Berhasil! 🎉',
                      style: TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booking kamu sudah dikonfirmasi.\nSelamat berlibur di Lombok!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ─── Booking code ─────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Text('Kode Booking',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                result.bookingCode,
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color: AppTheme.primaryColor),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18, color: AppTheme.primaryColor),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: result.bookingCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Kode booking disalin!')),
                                  );
                                },
                              ),
                            ],
                          ),
                          Text('Simpan kode ini untuk referensi kamu',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Booking details ──────────────────────────────────
                    _InfoCard(
                      title: 'Detail Hotel',
                      rows: [
                        _InfoRow('Hotel', result.hotelName),
                        _InfoRow('Check-in', fmt.format(result.checkIn)),
                        _InfoRow('Check-out', fmt.format(result.checkOut)),
                        _InfoRow('Durasi', '${result.nights} malam'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Payment details ──────────────────────────────────
                    _InfoCard(
                      title: 'Detail Pembayaran',
                      rows: [
                        _InfoRow('Metode', _methodLabel(result.method)),
                        _InfoRow('Total', '\$${result.amount.toStringAsFixed(0)}'),
                        _InfoRow('Transaction ID', result.transactionId),
                        _InfoRow('Waktu Bayar',
                            DateFormat('dd MMM yyyy, HH:mm').format(result.paidAt)),
                        _InfoRow('Status',
                            result.status == 'success' ? '✅ Berhasil' : result.status),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ─── CTA Buttons ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(AppRouter.home),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Kembali ke Beranda',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(AppRouter.myBookings),
                        icon: const Icon(Icons.bookmark_outlined),
                        label: const Text('Lihat Semua Booking',
                            style: TextStyle(fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _methodLabel(String id) {
    const labels = {
      'credit_card': 'Kartu Kredit/Debit',
      'bank_transfer': 'Transfer Bank',
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'dana': 'DANA',
      'qris': 'QRIS',
    };
    return labels[id] ?? id;
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
