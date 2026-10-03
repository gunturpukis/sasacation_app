import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/core/location_service.dart';
import 'package:sasacation/data/repo/weather_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/widget/explore_grid.dart';
import 'package:sasacation/ui/widget/filter_chips.dart';
import 'package:sasacation/ui/widget/search_bar.dart';
import 'package:sasacation/viewmodel/explore/explore_bloc.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // FIX: hanya load jika state masih initial (tidak reset filter saat tab switch)
    final state = context.read<ExploreBloc>().state;
    if (state is ExploreInitial) {
      context.read<ExploreBloc>().add(ExploreItemsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            title: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                final category = state is ExploreLoaded
                    ? (state.selectedCategory == 'All' ? l10n.fun_exploreTitle : state.selectedCategory)
                    : l10n.fun_exploreTitle;
                return Text(category,
                    style: const TextStyle(fontWeight: FontWeight.bold));
              },
            ),
            actions: [
              BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  // Tampilkan tombol reset filter jika ada filter aktif
                  final hasFilter = state is ExploreLoaded &&
                      (state.selectedCategory != 'All' || state.searchQuery.isNotEmpty);
                  if (!hasFilter) return const SizedBox.shrink();
                  return TextButton.icon(
                    onPressed: () =>
                        context.read<ExploreBloc>().add(ExploreItemsRequested()),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.fun_resetFilters, style: const TextStyle(fontSize: 13)),
                  );
                },
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(108),
              child: Column(
                children: [
                  CustomSearchBar(),
                  SizedBox(height: 12),
                  FilterChips(),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Cuaca lokasi saat ini (opsi 1): suhu selalu tampil bila
          // lokasi + API berhasil; kartu alert hanya bila ada alert.
          // Tanpa izin lokasi / gagal muat: section hilang total.
          const SliverToBoxAdapter(child: _ExploreWeatherSection()),

          // Result count
          SliverToBoxAdapter(
            child: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                if (state is ExploreLoaded) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.fun_placesFound(state.items.length),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                        if (state.searchQuery.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('"${state.searchQuery}"',
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
            sliver: SliverToBoxAdapter(child: ExploreGrid()),
          ),
        ],
      ),
    );
  }
}

/// Section cuaca Explore: suhu + kondisi lokasi user + kartu alert bila ada.
/// Gagal lokasi/API → SizedBox.shrink (tidak mengemis izin — alur izin
/// sudah ditangani layar hotel terdekat).
class _ExploreWeatherSection extends StatefulWidget {
  const _ExploreWeatherSection();

  @override
  State<_ExploreWeatherSection> createState() =>
      _ExploreWeatherSectionState();
}

class _ExploreWeatherSectionState
    extends State<_ExploreWeatherSection> {
  WeatherInfo? _info;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loc = await LocationService.instance.getCurrentLocation();
    if (!mounted || !loc.isSuccess) return;
    final info = await WeatherRepository().getWeather(
      lat: loc.position!.latitude,
      lng: loc.position!.longitude,
    );
    if (!mounted) return;
    setState(() {
      _info = info;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _info == null) return const SizedBox.shrink();
    final info = _info!;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.softCardShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_cloudy_outlined,
                    size: 28, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.fun_weatherCurrentTitle,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppTheme.outline)),
                      const SizedBox(height: 2),
                      Text(
                        '${info.location ?? ''} • ${info.tempC != null ? '${info.tempC!.toStringAsFixed(0)}°C' : ''}${info.description != null && info.description!.isNotEmpty ? ' • ${info.description}' : ''}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (info.alert != null) ...[
            const SizedBox(height: 10),
            _alertCard(context, l10n, info.alert!),
          ],
        ],
      ),
    );
  }

  Widget _alertCard(
      BuildContext context, AppLocalizations l10n, WeatherAlert alert) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (alert.isHigh ? AppTheme.error : AppTheme.secondaryContainer)
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: (alert.isHigh
                  ? AppTheme.error
                  : AppTheme.secondaryContainer)
              .withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fun_weatherAlertTitle,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTheme.secondary)),
          const SizedBox(height: 4),
          Text(alert.title,
              style: Theme.of(context).textTheme.titleLarge),
          if (alert.window.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(alert.window,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(AppRouter.myBookings),
              style: AppTheme.heroButtonStyle,
              child: Text(l10n.fun_rescheduleAction),
            ),
          ),
        ],
      ),
    );
  }
}
