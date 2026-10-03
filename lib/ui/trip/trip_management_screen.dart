// ─── Trip Management Screen ─────────────────────────────────────────────────
// Screen to view and manage saved AI-generated trips
import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/trip_model.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/trip/trip_bloc.dart';

class TripManagementScreen extends StatefulWidget {
  const TripManagementScreen({super.key});

  @override
  State<TripManagementScreen> createState() => _TripManagementScreenState();
}

class _TripManagementScreenState extends State<TripManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load trips when screen is initialized
    context.read<TripBloc>().add(TripsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(l10n.ait_tripsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<TripBloc>().add(TripsLoadRequested()),
            tooltip: l10n.ait_tripsReloadTooltip,
          ),
        ],
      ),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripsLoading) {
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
                          context.read<TripBloc>().add(TripsLoadRequested()),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.common_retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final trips = (state is TripsLoaded)
              ? state.trips
              : <TripModel>[];

          if (trips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timeline_outlined, size: 64,
                        color: AppTheme.outlineVariant),
                    const SizedBox(height: 16),
                    Text(l10n.ait_tripsEmptyTitle,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      l10n.ait_tripsEmptySubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push(AppRouter.tripPlanner),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(l10n.ait_tripsEmptyCta),
                    ),
                  ],
                ),
              ),
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
                      Text(l10n.ait_tripsHeaderTitle,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        l10n.ait_tripsSavedCount(trips.length),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = trips[index];
                      return _TripCard(
                        trip: trip,
                        onDelete: () =>
                            context.read<TripBloc>().add(TripDeleteRequested(tripId: trip.id)),
                        onTap: () => context.push(
                          AppRouter.tripDetailPath(trip.id),
                        ),
                      );
                    },
                    childCount: trips.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Trip Card ─────────────────────────────────────────────────────────────
class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TripCard({
    required this.trip,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline, size: 14,
                          color: AppTheme.tertiary),
                      const SizedBox(width: 4),
                      Text(l10n.ait_tripCardBadge,
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PillBadge(
                        label: l10n.ait_tripCardEstimate(
                            Money.formatSync(trip.totalEstimatedCost, usdDecimals: 0)),
                        icon: Icons.payments_outlined,
                        backgroundColor: AppTheme.surfaceContainerLow,
                        foregroundColor: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      PillBadge(
                        label: l10n.ait_tripCardDays(trip.days.length),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.error),
                      onPressed: onDelete,
                      tooltip: l10n.ait_tripDeleteTooltip,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}