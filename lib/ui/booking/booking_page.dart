import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/data/repo/explore_repository.dart';
import 'package:sasacation/viewmodel/booking/booking_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// View: MyBookingsScreen
/// Listens to BookingBloc (ViewModel) for user's booking list.
///
/// F1 (backend batch Figma audit): booking lahir `pending` — tab Pending +
/// tombol "Complete Booking" membuka Snap `redirectUrl` aktif via
/// `GET /checkout/resume/:id`. 404 (tidak ada pembayaran aktif) tampil
/// sebagai snackbar error apa adanya.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  /// Id booking yang sedang dimintakan resume — spinner per-kartu agar
  /// loading tidak menelan seluruh layar (BookingLoading = full-screen).
  String? _resumingId;

  @override
  void initState() {
    super.initState();
    // Dispatch event ke BookingBloc (ViewModel)
    context.read<BookingBloc>().add(BookingListRequested());
  }

  Future<void> _launchResume(String redirectUrl) async {
    final url = Uri.parse(redirectUrl);
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak dapat membuka halaman pembayaran'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Pending'),
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
              Tab(text: 'Batal'),
            ],
          ),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) async {
            if (state is BookingCancelled) {
              // Reload list setelah cancel
              context.read<BookingBloc>().add(BookingListRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking berhasil dibatalkan'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is BookingResumeReady) {
              setState(() => _resumingId = null);
              await _launchResume(state.redirectUrl);
              // Muat ulang — webhook bisa mengubah pending → confirmed.
              if (mounted) {
                context.read<BookingBloc>().add(BookingListRequested());
              }
            } else if (state is BookingError) {
              setState(() => _resumingId = null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red),
              );
            } else if (state is BookingListLoaded) {
              setState(() => _resumingId = null);
            }
          },
          builder: (context, state) {
            if (state is BookingLoading && _resumingId == null ||
                state is BookingInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BookingListLoaded) {
              final bookings = state.bookings;
              if (bookings.isEmpty) {
                return _buildEmptyState();
              }
              return TabBarView(
                children: [
                  _bookingsList(context, bookings),
                  _bookingsList(context, bookings.where((b) => b.isPending).toList()),
                  _bookingsList(context, bookings.where((b) => b.isConfirmed).toList()),
                  _bookingsList(context, bookings.where((b) => b.isCompleted).toList()),
                  _bookingsList(context, bookings.where((b) => b.isCancelled).toList()),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Belum ada booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Yuk mulai jelajahi Lombok!', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _bookingsList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Text('Tidak ada booking di kategori ini',
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<BookingBloc>().add(BookingListRequested()),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) => _buildBookingCard(context, bookings[index]),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final fmt = DateFormat('dd MMM yyyy');
    final statusColor = booking.isPending
        ? AppTheme.secondaryContainer
        : booking.isConfirmed
            ? Colors.green
            : booking.isCancelled
                ? Colors.red
                : Colors.blue;
    final statusLabel = booking.isPending
        ? 'Pending'
        : booking.isConfirmed
            ? 'Confirmed'
            : booking.isCancelled
                ? 'Cancelled'
                : 'Completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15)),
            child: Image.network(
              booking.hotelImage,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 130,
                color: Colors.grey.shade200,
                child: const Icon(Icons.hotel,
                    size: 40, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(booking.hotelName,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Kode: ${booking.bookingCode}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        letterSpacing: 1)),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${fmt.format(booking.checkIn)} → ${fmt.format(booking.checkOut)}',
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13),
                  ),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.nights_stay_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                      '${booking.nights} malam · ${booking.guestCount} tamu',
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \$${booking.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor),
                    ),
                    if (booking.isPending)
                      ElevatedButton(
                        onPressed: _resumingId == booking.id
                            ? null
                            : () {
                                setState(
                                    () => _resumingId = booking.id);
                                context.read<BookingBloc>().add(
                                    BookingPaymentResumeRequested(
                                        bookingId: booking.id));
                              },
                        style: AppTheme.heroButtonStyle.copyWith(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                          ),
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        child: _resumingId == booking.id
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text('Complete Booking'),
                      )
                    else if (booking.isConfirmed)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _reschedule(context, booking),
                            icon: const Icon(
                                Icons.calendar_month_outlined,
                                size: 16),
                            label: const Text('Jadwal Ulang'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _confirmCancel(context, booking.id),
                            icon: const Icon(
                                Icons.cancel_outlined,
                                size: 16),
                            label: const Text('Batalkan'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// F11: dialog jadwal ulang (khusus confirmed, aturan backend).
  /// Selisih harga ditampilkan apa adanya dari respons server.
  Future<void> _reschedule(
      BuildContext context, BookingModel booking) async {
    DateTime checkIn = booking.checkIn;
    DateTime checkOut = booking.checkOut;
    var saving = false;
    final fmt = DateFormat('dd MMM yyyy');

    Future<DateTime?> pick(DateTime initial, DateTime first) =>
        showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first,
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );

    final confirmed = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dlg) => StatefulBuilder(
        builder: (dlg, setDlg) => AlertDialog(
          title: const Text('Jadwal Ulang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Check-in'),
                subtitle: Text(fmt.format(checkIn)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await pick(
                      checkIn, DateTime.now());
                  if (picked != null) {
                    setDlg(() {
                      checkIn = picked;
                      if (!checkOut.isAfter(checkIn)) {
                        checkOut =
                            checkIn.add(const Duration(days: 1));
                      }
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Check-out'),
                subtitle: Text(fmt.format(checkOut)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await pick(
                      checkOut, checkIn.add(const Duration(days: 1)));
                  if (picked != null) {
                    setDlg(() => checkOut = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dlg, false),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDlg(() => saving = true);
                      final result = await BookingRepository()
                          .rescheduleBooking(
                        id: booking.id,
                        checkIn: checkIn,
                        checkOut: checkOut,
                      );
                      if (!dlg.mounted) return;
                      Navigator.pop(dlg, result);
                    },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (confirmed != null) {
      if (confirmed['success'] == true) {
        final diff = (confirmed['priceDiff'] as num?)?.toDouble() ?? 0;
        final total =
            (confirmed['newTotal'] as num?)?.toDouble();
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Jadwal Diperbarui'),
            content: Text(
              diff > 0
                  ? 'Total baru \$${total?.toStringAsFixed(0) ?? '-'} '
                      '(+\$${diff.toStringAsFixed(0)}). Pembayaran tambahan belum otomatis — hubungi CS bila perlu.'
                  : diff < 0
                      ? 'Total baru \$${total?.toStringAsFixed(0) ?? '-'} '
                          '(selisih \$${(-diff).toStringAsFixed(0)} akan disesuaikan).'
                      : 'Tanggal berhasil diubah tanpa selisih harga.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (context.mounted) {
          context.read<BookingBloc>().add(BookingListRequested());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(confirmed['message'] ?? 'Gagal menjadwalkan ulang'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmCancel(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Booking'),
        content: const Text('Yakin ingin membatalkan booking ini?'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Dispatch event ke BookingBloc (ViewModel)
              context
                  .read<BookingBloc>()
                  .add(BookingCancelRequested(bookingId: bookingId));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
