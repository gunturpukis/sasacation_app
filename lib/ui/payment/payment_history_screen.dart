
import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/payment_model.dart';
import 'package:sasacation/data/repo/payment_repository.dart';
 
/// PaymentHistoryScreen
///
/// INI BUKAN "Travel Wallet" seperti di mockup `travel_wallet_payments`.
/// Mockup itu menampilkan e-wallet bersaldo — "Total Balance $12,450",
/// "Sasa Points 4,820 pts", kartu virtual, fitur top-up/transfer/bills.
/// SEMUA ITU FIKTIF — Sasacation tidak punya sistem saldo tersimpan;
/// pembayaran real-time per-transaksi lewat Midtrans. Menampilkan saldo
/// palsu ke user itu menyesatkan secara finansial, jadi saya tidak
/// membangunnya.
///
/// Sebagai gantinya, screen ini menampilkan RIWAYAT PEMBAYARAN NYATA dari
/// tabel `payments` — total dibelanjakan (dihitung dari transaksi sukses
/// sungguhan) dan daftar transaksi dengan status apa adanya
/// (success/failed/refunded). Tidak ada top-up, transfer, atau bills — itu
/// fitur yang butuh sistem saldo yang memang tidak ada.
///
/// KONTRAK BACKEND untuk Wallet penuh (bila diputuskan): tabel `wallets`
/// (user_id, balance_cents) + `wallet_transactions` + `loyalty_points`;
/// endpoint GET /wallet (saldo+poin), POST /wallet/topup (via Midtrans),
/// GET /wallet/transactions. Flutter tinggal tambah WalletRepository +
/// kartu saldo di atas riwayat ini — tidak ada perubahan skema UI besar.
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});
 
  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}
 
class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _repo = PaymentRepository();
  final _walletRepo = WalletRepository();
  List<PaymentModel> _payments = [];
  double _totalSpent = 0;
  LoyaltyInfo? _loyalty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _repo.getPaymentHistory();
    final loyalty = await _walletRepo.getLoyalty();
    if (!mounted) return;
    setState(() {
      _payments = result['payments'] as List<PaymentModel>;
      _totalSpent = result['totalSpent'] as double;
      _loyalty = loyalty;
      _loading = false;
    });
  }

  /// F9: transfer saldo ke user lain via email. Gagal (mis. saldo kurang)
  /// tampil sebagai snackbar error backend apa adanya.
  Future<void> _transfer() async {
    final emailCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var saving = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dlg) => StatefulBuilder(
        builder: (dlg, setDlg) => AlertDialog(
          title: const Text('Transfer Saldo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email penerima',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah (USD)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dlg, false),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final amount =
                          double.tryParse(amountCtrl.text.trim());
                      if (!emailCtrl.text.contains('@') ||
                          amount == null ||
                          amount <= 0) {
                        return;
                      }
                      setDlg(() => saving = true);
                      final res = await _walletRepo.transfer(
                        email: emailCtrl.text.trim(),
                        amount: amount,
                        note: noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim(),
                      );
                      if (!dlg.mounted) return;
                      Navigator.pop(dlg, res['success'] == true);
                      if (mounted && res['success'] != true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ??
                                'Transfer gagal'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer berhasil')),
      );
    }
  }
 
  Widget _loyaltyCard(BuildContext context, LoyaltyInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Sasacation Travel Pass',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(info.tier,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${info.points} pts',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'ID ${info.passId} • ${info.tripsCompleted} trip selesai',
            style:
                const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'qris':
        return Icons.qr_code_scanner;
      case 'gopay':
      case 'ovo':
      case 'dana':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
 
  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return AppTheme.successColor;
      case 'failed':
        return AppTheme.error;
      case 'refunded':
        return AppTheme.secondary;
      default:
        return AppTheme.outline;
    }
  }
 
  String _statusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Berhasil';
      case 'failed':
        return 'Gagal';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return status;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Payment History'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // F9: Travel Pass loyalitas — ID member + tier + poin,
                  // semuanya dari GET /loyalty. Tanpa nomor kartu palsu.
                  if (_loyalty != null) ...[
                    _loyaltyCard(context, _loyalty!),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _transfer,
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: const Text('Transfer Saldo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(
                              color: AppTheme.primaryContainer),
                          padding: const EdgeInsets.symmetric(
                              vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusButton),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Ringkasan total dibelanjakan — REAL, dihitung dari
                  // transaksi sukses, bukan "saldo" seperti mockup.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Dibelanjakan',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text('\$${_totalSpent.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${_payments.where((p) => p.status == 'success').length} transaksi berhasil',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Riwayat Transaksi', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
 
                  if (_payments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.outlineVariant),
                            const SizedBox(height: 12),
                            Text('Belum ada transaksi', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._payments.map((p) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: Icon(_methodIcon(p.method), size: 18, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.hotelName,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text('${p.bookingCode} • ${p.paidAt.day}/${p.paidAt.month}/${p.paidAt.year}',
                                        style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('\$${p.amount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _statusColor(p.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    ),
                                    child: Text(_statusLabel(p.status),
                                        style: TextStyle(fontSize: 10, color: _statusColor(p.status), fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}