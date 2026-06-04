import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/viewmodel/booking/booking_bloc.dart';

/// View: MyBookingsScreen
/// Listens to BookingBloc (ViewModel) for user's booking list.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch event ke BookingBloc (ViewModel)
    context.read<BookingBloc>().add(BookingListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), centerTitle: true),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCancelled) {
            // Reload list setelah cancel
            context.read<BookingBloc>().add(BookingListRequested());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking berhasil dibatalkan'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingLoading || state is BookingInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingListLoaded) {
            final bookings = state.bookings;
            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hotel_outlined,
                        size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('Belum ada booking',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Yuk mulai jelajahi Lombok!',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<BookingBloc>().add(BookingListRequested()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final fmt = DateFormat('dd MMM yyyy');
                  final statusColor = booking.isConfirmed
                      ? Colors.green
                      : booking.isCancelled
                          ? Colors.red
                          : Colors.blue;
                  final statusLabel = booking.isConfirmed
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
                            errorBuilder: (_, __, ___) => Container(
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
                                  if (booking.isConfirmed)
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
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
