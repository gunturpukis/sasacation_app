import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/viewmodel/checkout/checkout_bloc.dart';

/// View: CheckoutScreen
/// FIX: menggunakan CheckoutBloc dari root MultiBlocProvider (bukan buat baru)
/// Dispatch CheckoutInitiated saat initState.
class CheckoutScreen extends StatefulWidget {
  final HotelModel hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int guestCount;
  final String? notes;

  const CheckoutScreen({
    super.key,
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guestCount,
    this.notes,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

/// Step checkout: dipisah agar meniru pola Agoda (Review booking -> Payment)
/// alih-alih menumpuk semua di satu layar. Murni state UI lokal — tidak
/// mengubah CheckoutBloc/backend sama sekali.
enum _CheckoutStep { review, payment }

class _CheckoutScreenState extends State<CheckoutScreen> {
  _CheckoutStep _step = _CheckoutStep.review;

  @override
  void initState() {
    super.initState();
    // Dispatch ke root CheckoutBloc — tidak buat BlocProvider baru
    context.read<CheckoutBloc>().add(CheckoutInitiated(
      hotelId: widget.hotel.id,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      guestCount: widget.guestCount,
      notes: widget.notes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutPaymentSuccess) {
          context.pushReplacement(AppRouter.bookingConfirm, extra: state.result);
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_step == _CheckoutStep.review ? 'Review Booking' : 'Pembayaran'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_step == _CheckoutStep.payment) {
                  // Kembali ke Review, bukan keluar dari checkout
                  setState(() => _step = _CheckoutStep.review);
                  return;
                }
                // Reset checkout state saat back dari Review
                context.read<CheckoutBloc>().add(CheckoutReset());
                context.pop();
              },
            ),
          ),
          body: Column(
            children: [
              if (state is CheckoutSessionLoaded) _StepIndicator(step: _step),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
          bottomNavigationBar: _buildPayButton(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext ctx, CheckoutState state) {
    if (state is CheckoutLoading || state is CheckoutInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Menyiapkan checkout...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    if (state is CheckoutPaymentProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memproses pembayaran...', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Mohon tunggu sebentar', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    if (state is CheckoutError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctx.read<CheckoutBloc>().add(CheckoutInitiated(
                    hotelId: widget.hotel.id,
                    checkIn: widget.checkIn,
                    checkOut: widget.checkOut,
                    guestCount: widget.guestCount,
                    notes: widget.notes,
                  )),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (state is CheckoutSessionLoaded) {
      if (_step == _CheckoutStep.review) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HotelSummaryCard(session: state.session),
              const SizedBox(height: 16),
              _StayDetailsCard(
                  checkIn: widget.checkIn,
                  checkOut: widget.checkOut,
                  nights: widget.nights,
                  guestCount: widget.guestCount,
                  notes: widget.notes ?? ''),
              const SizedBox(height: 16),
              _PriceBreakdownCard(pricing: state.session.pricing),
              const SizedBox(height: 100),
            ],
          ),
        );
      }
      // Step pembayaran: ringkasan singkat + pilihan metode bayar saja,
      // supaya fokus user tidak terpecah dengan detail yang sudah dicek di Review.
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HotelSummaryCard(session: state.session),
            const SizedBox(height: 16),
            _PaymentMethodsCard(
              methods: state.session.paymentMethods,
              selected: state.selectedMethod,
              onSelect: (m) =>
                  ctx.read<CheckoutBloc>().add(CheckoutPaymentMethodSelected(method: m)),
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPayButton(BuildContext ctx, CheckoutState state) {
    if (state is! CheckoutSessionLoaded) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('\$${state.session.pricing.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _step == _CheckoutStep.review
                    ? () => setState(() => _step = _CheckoutStep.payment)
                    : (state.canPay
                        ? () => ctx.read<CheckoutBloc>().add(CheckoutPaymentConfirmed())
                        : null),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _step == _CheckoutStep.review
                      ? 'Lanjutkan ke Pembayaran'
                      : (state.canPay ? 'Bayar Sekarang' : 'Pilih Metode Pembayaran'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indikator 2 langkah (Review -> Payment) di bagian atas checkout.
class _StepIndicator extends StatelessWidget {
  final _CheckoutStep step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          _StepDot(label: '1. Review', active: true),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: step == _CheckoutStep.payment
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
            ),
          ),
          _StepDot(label: '2. Pembayaran', active: step == _CheckoutStep.payment),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool active;
  const _StepDot({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? AppTheme.primaryColor : Colors.grey.shade500,
            )),
      ],
    );
  }
}

// Sub-widgets
class _HotelSummaryCard extends StatelessWidget {
  final session;
  const _HotelSummaryCard({required this.session});
  @override
  Widget build(BuildContext context) {
    final hotel = session.hotel;
    return _Card(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(hotel['image'] ?? '',
                width: 80, height: 70, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 80, height: 70, color: Colors.grey.shade200)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(hotel['location'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star, size: 13, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${hotel['rating']}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StayDetailsCard extends StatelessWidget {
  final DateTime checkIn, checkOut;
  final int nights, guestCount;
  final String notes;
  const _StayDetailsCard({
    required this.checkIn, required this.checkOut,
    required this.nights, required this.guestCount, required this.notes,
  });
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, dd MMM yyyy');
    return _Card(
      title: 'Detail Menginap',
      child: Column(
        children: [
          _Row('Check-in', fmt.format(checkIn)),
          _Row('Check-out', fmt.format(checkOut)),
          _Row('Durasi', '$nights malam'),
          _Row('Tamu', '$guestCount orang'),
          if (notes.isNotEmpty) _Row('Catatan', notes),
        ],
      ),
    );
  }
}

class _PriceBreakdownCard extends StatelessWidget {
  final pricing;
  const _PriceBreakdownCard({required this.pricing});
  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Rincian Harga',
      child: Column(
        children: [
          _Row('Harga per malam', '\$${pricing.pricePerNight.toStringAsFixed(0)}'),
          _Row('Subtotal', '\$${pricing.subtotal.toStringAsFixed(0)}'),
          _Row('Pajak (${pricing.taxRate.toStringAsFixed(0)}%)', '\$${pricing.tax.toStringAsFixed(0)}'),
          _Row('Biaya layanan', '\$${pricing.serviceFee.toStringAsFixed(0)}'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$${pricing.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  final List methods;
  final selected;
  final Function(dynamic) onSelect;
  const _PaymentMethodsCard({required this.methods, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final groups = {
      'Kartu': methods.where((m) => m.id == 'credit_card').toList(),
      'E-Wallet': methods.where((m) => ['gopay','ovo','dana'].contains(m.id)).toList(),
      'Lainnya': methods.where((m) => ['bank_transfer','qris'].contains(m.id)).toList(),
    };
    return _Card(
      title: 'Metode Pembayaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.entries.map((entry) {
          if (entry.value.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(entry.key,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              ),
              ...entry.value.map((m) => _MethodTile(
                    method: m,
                    isSelected: selected?.id == m.id,
                    onTap: () => onSelect(m),
                  )),
              const SizedBox(height: 6),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final method;
  final bool isSelected;
  final VoidCallback onTap;
  const _MethodTile({required this.method, required this.isSelected, required this.onTap});

  IconData _icon(String id) {
    switch (id) {
      case 'credit_card': return Icons.credit_card;
      case 'bank_transfer': return Icons.account_balance;
      case 'qris': return Icons.qr_code_scanner;
      default: return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.06) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon(method.id),
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(method.label,
                style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final Widget child;
  const _Card({this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}
