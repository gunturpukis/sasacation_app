import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/route/approuter.dart';

/// View: BookingSheet
/// Collects stay details (dates, guests) then navigates to CheckoutScreen.
/// Payment is handled entirely in CheckoutScreen + PaymentResult page.
class BookingSheet extends StatefulWidget {
  final HotelModel hotel;
  const BookingSheet({super.key, required this.hotel});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  int guestCount = 1;
  int nights = 1;
  DateTime checkIn = DateTime.now().add(const Duration(days: 1));
  late DateTime checkOut;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkOut = checkIn.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.hotel.price.toInt() * nights;
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Book Your Stay',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(widget.hotel.name,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),

            // Date range selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: checkIn,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          locale: const Locale('id', 'ID'),
                        );
                        if (picked != null) {
                          setState(() {
                            checkIn = picked;
                            checkOut = checkIn.add(Duration(days: nights));
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CHECK-IN',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(_formatDate(checkIn),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: AppTheme.primaryColor, size: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('CHECK-OUT',
                            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_formatDate(checkOut),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Counters
            _Counter(
              label: 'Malam',
              icon: Icons.nights_stay_outlined,
              value: nights,
              onDecrement: nights > 1
                  ? () => setState(() { nights--; checkOut = checkIn.add(Duration(days: nights)); })
                  : null,
              onIncrement: () => setState(() { nights++; checkOut = checkIn.add(Duration(days: nights)); }),
            ),
            const SizedBox(height: 12),
            _Counter(
              label: 'Tamu',
              icon: Icons.people_outline,
              value: guestCount,
              onDecrement: guestCount > 1 ? () => setState(() => guestCount--) : null,
              onIncrement: () => setState(() => guestCount++),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan khusus (opsional)',
                hintText: 'Mis: kamar di lantai atas, dekat kolam...',
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Price summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${widget.hotel.price.toStringAsFixed(0)} × $nights malam',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const Text('+ pajak & biaya layanan',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  Text('\$$totalPrice',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Proceed to checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _proceedToCheckout,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Lanjut ke Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Tidak dikenakan biaya sekarang',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout() {
    Navigator.pop(context); // close sheet
    context.push(AppRouter.checkout, extra: {
      'hotel': widget.hotel,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'nights': nights,
      'guestCount': guestCount,
      'notes': _notesCtrl.text.trim(),
    });
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _Counter({
    required this.label,
    required this.icon,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const Spacer(),
        Row(
          children: [
            _CircleButton(
              icon: Icons.remove,
              onPressed: onDecrement,
              active: onDecrement != null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('$value',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _CircleButton(icon: Icons.add, onPressed: onIncrement, active: true),
          ],
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool active;

  const _CircleButton({required this.icon, required this.onPressed, required this.active});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppTheme.primaryColor : Colors.grey.shade200,
        ),
        child: Icon(icon, size: 16, color: active ? Colors.white : Colors.grey.shade400),
      ),
    );
  }
}
