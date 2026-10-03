import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/checkout_model.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/utils/info_card.dart';
import 'package:sasacation/utils/info_money_row.dart';
import 'package:sasacation/utils/info_row.dart';

/// View: BookingConfirmScreen
/// Ditampilkan setelah pembayaran berhasil — full confirmation page.
class BookingConfirmScreen extends StatelessWidget {
  final PaymentResult result;

  const BookingConfirmScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                    Text(
                      l10n.fun_paymentSuccessTitle,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.fun_paymentSuccessSub,
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
                          Text(l10n.fun_bookingCodeLabel,
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
                                    SnackBar(content: Text(l10n.fun_bookingCodeCopied)),
                                  );
                                },
                              ),
                            ],
                          ),
                          Text(l10n.fun_saveCodeHint,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Booking details ──────────────────────────────────
                    InfoCard(
                      title: l10n.fun_hotelDetailTitle,
                      rows: [
                        InfoRow(l10n.fun_infoHotelLabel, result.hotelName),
                        InfoRow(l10n.fun_checkInLabel, fmt.format(result.checkIn)),
                        InfoRow(l10n.fun_checkOutLabel, fmt.format(result.checkOut)),
                        InfoRow(l10n.fun_durationLabel, l10n.fun_nightsCount(result.nights)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Payment details ──────────────────────────────────
                    InfoCard(
                      title: l10n.fun_paymentDetailTitle,
                      rows: [
                        InfoRow(l10n.fun_methodRowLabel, _methodLabel(result.method)),
                        InfoMoneyRow(icon: Icons.attach_money, label: l10n.fun_totalRowLabel, usd: result.amount),
                        InfoRow(l10n.fun_transactionIdLabel, result.transactionId),
                        InfoRow(l10n.fun_paidTimeLabel,
                            DateFormat('dd MMM yyyy, HH:mm').format(result.paidAt)),
                        InfoRow(l10n.fun_statusRowLabel,
                            result.status == 'success' ? l10n.fun_statusSuccess : result.status),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ─── CTA Buttons ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(AppRouter.home),
                        icon: const Icon(Icons.home_outlined),
                        label: Text(l10n.fun_backToHome,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                        label: Text(l10n.fun_viewAllBookings,
                            style: const TextStyle(fontSize: 15)),
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



