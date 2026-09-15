// ─── Trip Detail Screen ─────────────────────────────────────────────────────
// Screen to view a specific saved trip in detail
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/data/model/trip_model.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/viewmodel/trip/trip_bloc.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({required this.tripId, super.key});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load the trip when screen is initialized
    context.read<TripBloc>().add(TripLoadRequested(tripId: widget.tripId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Trip Detail'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                context.read<TripBloc>().add(TripDeleteRequested(tripId: widget.tripId)),
            tooltip: 'Hapus trip',
          ),
        ],
      ),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (state is TripError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48,
                        color: AppTheme.error),
                    const SizedBox(height: 16),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<TripBloc>().add(TripLoadRequested(tripId: widget.tripId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final trip = (state is TripLoaded) ? state.trip : null;

          if (trip == null) {
            return Center(
              child: Text('Trip tidak ditemukan',
                  style: Theme.of(context).textTheme.bodyLarge),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timeline, size: 14,
                              color: AppTheme.tertiary),
                          const SizedBox(width: 4),
                          Text('TRIP DETAIL',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.tertiary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(trip.title,
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text(trip.summary,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          PillBadge(
                            label: 'Est. \$${trip.totalEstimatedCost.toInt()}',
                            icon: Icons.payments_outlined,
                            backgroundColor: AppTheme.surfaceContainerLow,
                            foregroundColor: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          PillBadge(
                            label: '${trip.days.length} Hari',
                            icon: Icons.calendar_today_outlined,
                            backgroundColor: AppTheme.surfaceContainerLow,
                            foregroundColor: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          if (trip.destination != null)
                            PillBadge(
                              label: trip.destination!,
                              icon: Icons.location_on,
                              backgroundColor: AppTheme.surfaceContainerLow,
                              foregroundColor: AppTheme.primary,
                            ),
                          const SizedBox(width: 8),
                          PillBadge(
                            label: 'Disimpan: ${_formatDate(trip.createdAt)}',
                            icon: Icons.save_outlined,
                            backgroundColor: AppTheme.surfaceContainerLow,
                            foregroundColor: AppTheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Itinerary',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildItinerary(trip),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Itinerary Display ────────────────────────────────────────────────────
  Widget _buildItinerary(TripModel trip) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.days.length,
      itemBuilder: (context, index) {
        final day = trip.days[index];
        return _DaySection(day: day, dayNumber: index + 1);
      },
    );
  }

  Widget _buildActivity(TripActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(activity.time,
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
              if (activity.estimatedCost > 0)
                Text('\$${activity.estimatedCost.toInt()}',
                    style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(activity.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
          if (activity.location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(activity.location, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (activity.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(activity.notes,
                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _DaySection({required TripDay day, required int dayNumber}) {
    return ExpansionTile(
      title: Text('Day $dayNumber',
          style: Theme.of(context).textTheme.titleMedium),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        for (final activity in day.activities)
          _buildActivity(activity),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}