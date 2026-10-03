import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/data/model/trip_model.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/trip/trip_bloc.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final _controller = TextEditingController();
  bool _isGenerating = false;
  String? _errorMessage;
  TripPlan? _generatedPlan;

  final List<String> _suggestions = [
    'Liburan 3 hari di Senggigi untuk pasangan baru menikah',
    'Trip keluarga 5 hari ke Lombok dengan budget tengah',
    'Petualangan solo 4 hari ke Gunung Rinjani',
    'Liburan santai 3 hari di Gili Trawangan dengan snorkeling',
    'Wisata budaya Sasak 2 hari di sekitar Mataram',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ait_plannerTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.ait_plannerSavedTooltip,
            onPressed: () => context.push(AppRouter.tripManagement),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _generateTripPlan,
                      decoration: InputDecoration(
                        hintText: l10n.ait_plannerHint,
                        prefixIcon: const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isGenerating ? null : () => _generateTripPlan(_controller.text),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),

            // Suggestions
            if (!_isGenerating && _generatedPlan == null && _controller.text.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.ait_plannerExamplesTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions
                          .map(
                            (suggestion) => ChoiceChip(
                              label: Text(suggestion),
                              selected: false,
                              onSelected: (_) {
                                _controller.text = suggestion;
                                _generateTripPlan(suggestion);
                              },
                              labelStyle: const TextStyle(fontSize: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              backgroundColor: AppTheme.surfaceContainerLow,
                              selectedColor: AppTheme.primaryContainer,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

            // Results or Error
            Expanded(
              child: _isGenerating
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.ait_plannerGenerating,
                            style: const TextStyle(color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 56,
                                  color: AppTheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _errorMessage = null;
                                      _generatedPlan = null;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(l10n.common_retry),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _generatedPlan != null
                          ? _buildResult(_generatedPlan!)
                          : Center(
                              child: Text(
                                l10n.ait_plannerEmpty,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateTripPlan(String query) {
    if (query.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedPlan = null;
    });
    _controller.clear();
    FocusScope.of(context).unfocus();

    // Simulate AI generation - in real app, this would call AI backend
    // For now, we'll create a mock plan based on the query
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });

      // Create a mock trip plan based on query
      final plan = _createMockTripPlan(query);
      setState(() {
        _generatedPlan = plan;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _errorMessage = l10n.ait_plannerCreateFailed(error);
      });
    });
  }

  TripPlan _createMockTripPlan(String query) {
    // This is a mock implementation - in real app, this comes from AI backend
    // We'll create a simple plan based on keywords in the query

    final lowerQuery = query.toLowerCase();
    String title;
    String summary;
    String bestTimeToVisit;

    // Set values based on query keywords
    if (lowerQuery.contains('senggigi') || lowerQuery.contains('pantai')) {
      title = 'Liburan Pantai Senggigi';
      summary = 'Nikmati keindahan pantai Senggigi dengan berbagai aktivitas marine';
      bestTimeToVisit = 'Mei - Oktober'; // default
    } else if (lowerQuery.contains('rinjani') || lowerQuery.contains('gunung') || lowerQuery.contains('trekking')) {
      title = 'Trekking Gunung Rinjani';
      summary = 'Petualangan mendaki Gunung Rinjani yang salah satu gunung tertinggi di Indonesia';
      bestTimeToVisit = 'April - November';
    } else if (lowerQuery.contains('gili') || lowerQuery.contains('snorkel')) {
      title = 'Explorer Gili Islands';
      summary = 'Jelajah keindahan bawah laut di tiga pulau Gili yang indah';
      bestTimeToVisit = 'Mei - Oktober'; // default
    } else if (lowerQuery.contains('budget') || lowerQuery.contains('murah') || lowerQuery.contains('hemat')) {
      title = 'Trip Lombok Budget Friendly';
      summary = 'Menjelajah Lombok dengan biaya terjangkau tanpa mengurangi pengalaman';
      bestTimeToVisit = 'Mei - Oktober'; // default
    } else if (lowerQuery.contains('keluarga') || lowerQuery.contains('family')) {
      title = 'Liburan Keluarga di Lombok';
      summary = 'Rencana liburan yang cocok untuk seluruh anggota keluarga';
      bestTimeToVisit = 'Mei - Oktober'; // default
    } else if (lowerQuery.contains('budaya') || lowerQuery.contains('sasak') || lowerQuery.contains('cultural')) {
      title = 'Jejak Budaya Sasak';
      summary = 'Mengenal keindahan budaya lokal Sasak melalui berbagai situs historis';
      bestTimeToVisit = 'Jun - September';
    } else {
      // Default values if no keywords match
      title = 'Trip ke Lombok';
      summary = 'Rencana liburan yang disesuaikan dengan permintaan Anda';
      bestTimeToVisit = 'Mei - Oktober';
    }

    if (lowerQuery.contains('senggigi') || lowerQuery.contains('pantai')) {
      title = 'Liburan Pantai Senggigi';
      summary = 'Nikmati keindahan pantai Senggigi dengan berbagai aktivitas marine';
          } else if (lowerQuery.contains('rinjani') || lowerQuery.contains('gunung') || lowerQuery.contains('trekking')) {
      title = 'Trekking Gunung Rinjani';
      summary = 'Petualangan mendaki Gunung Rinjani yang salah satu gunung tertinggi di Indonesia';
            bestTimeToVisit = 'April - November';
    } else if (lowerQuery.contains('gili') || lowerQuery.contains('snorkel')) {
      title = 'Explorer Gili Islands';
      summary = 'Jelajah keindahan bawah laut di tiga pulau Gili yang indah';
          } else if (lowerQuery.contains('budget') || lowerQuery.contains('murah') || lowerQuery.contains('hemat')) {
      title = 'Trip Lombok Budget Friendly';
      summary = 'Menjelajah Lombok dengan biaya terjangkau tanpa mengurangi pengalaman';
          } else if (lowerQuery.contains('keluarga') || lowerQuery.contains('family')) {
      title = 'Liburan Keluarga di Lombok';
      summary = 'Rencana liburan yang cocok untuk seluruh anggota keluarga';
          } else if (lowerQuery.contains('budaya') || lowerQuery.contains('sasak') || lowerQuery.contains('cultural')) {
      title = 'Jejak Budaya Sasak';
      summary = 'Mengenal keindahan budaya lokal Sasak melalui berbagai situs historis';
            bestTimeToVisit = 'Jun - September';
    }

    // Create mock days
    final days = <TripDay>[
      TripDay(
        day: 1,
        title: 'Hari 1: Kedatangan dan Penginapan',
        activities: [
          TripActivity(
            time: '09:00',
            name: 'Kedatangan di Bandara Internasional Lombok',
            type: 'transport',
            location: 'Bandara Internasional Lombok',
            duration: '1 jam',
            estimatedCost: 0,
            notes: 'Welcome drink dan transfer ke hotel',
          ),
          TripActivity(
            time: '11:00',
            name: 'Check-in Hotel',
            type: 'hotel',
            location: 'Hotel di Senggigi',
            duration: '0.5 jam',
            estimatedCost: 400000,
            notes: 'Hotel 4 bintang dengan pemandangan laut',
          ),
          TripActivity(
            time: '14:00',
            name: 'Santai di Pantai',
            type: 'restaurant',
            location: 'Pantai Senggigi',
            duration: '3 jam',
            estimatedCost: 150000,
            notes: 'Menikmati indahnya pantai sambil makan siang',
          ),
          TripActivity(
            time: '19:00',
            name: 'Dinner di Restoran Lokal',
            type: 'restaurant',
            location: 'Senggigi Centre',
            duration: '2 jam',
            estimatedCost: 200000,
            notes: 'Mencoba kuliner khas Sasak seperti ayam taliwang',
          ),
        ],
        dailyCost: 750000,
      ),
      TripDay(
        day: 2,
        title: 'Hari 2: Jelajah Alam dan Budaya',
        activities: [
          TripActivity(
            time: '08:00',
            name: 'Sarapan di Hotel',
            type: 'restaurant',
            location: 'Hotel',
            duration: '1 jam',
            estimatedCost: 0,
            notes: 'Sarapan buffet termasuk dalam kamar',
          ),
          TripActivity(
            time: '09:30',
            name: 'Tour Desa Sasak Tradisional',
            type: 'transport',
            location: 'Desa Sasak Sade',
            duration: '4 jam',
            estimatedCost: 200000,
            notes: 'Mengenal rumah adat dan tradisi lokal',
          ),
          TripActivity(
            time: '14:30',
            name: 'Makan Siang di Warung Lokal',
            type: 'restaurant',
            location: 'Praya',
            duration: '1.5 jam',
            estimatedCost: 100000,
            notes: 'Makanan tradisional dengan harga terjangkau',
          ),
          TripActivity(
            time: '16:30',
            name: 'Berbelanja di Pasar Tradisional',
            type: 'restaurant',
            location: 'Pasar Kebon Roek',
            duration: '2 jam',
            estimatedCost: 150000,
            notes: 'Membeli oleh-oleh khas Lombok',
          ),
          TripActivity(
            time: '19:30',
            name: 'Dinner dan Pertunjukan Tari Tradisional',
            type: 'restaurant',
            location: 'Hotel',
            duration: '2.5 jam',
            estimatedCost: 300000,
            notes: 'Menikmati pertarian tari Sasak sambil makan malam',
          ),
        ],
        dailyCost: 750000,
      ),
      TripDay(
        day: 3,
        title: 'Hari 3: Island Hopping dan Kehancuran',
        activities: [
          TripActivity(
            time: '08:00',
            name: 'Sarapan dan Check-out',
            type: 'restaurant',
            location: 'Hotel',
            duration: '1.5 jam',
            estimatedCost: 0,
            notes: 'Sarapan pagi sebelum check-out',
          ),
          TripActivity(
            time: '09:30',
            name: 'Trip ke Gili Trawangan',
            type: 'transport',
            location: 'Pelabuhan Bangsal',
            duration: '2 jam',
            estimatedCost: 250000,
            notes: 'Perahu ke Gili Trawangan dengan snorkeling gear',
          ),
          TripActivity(
            time: '12:00',
            name: 'Snorkeling dan Pantai',
            type: 'restaurant',
            location: 'Gili Trawangan',
            duration: '3 jam',
            estimatedCost: 150000,
            notes: 'Menjijeli terumbu karang dan berjemur di pasir putih',
          ),
          TripActivity(
            time: '16:00',
            name: 'Explore Pulau Sepeda',
            type: 'transport',
            location: 'Gili Trawangan',
            duration: '2 jam',
            estimatedCost: 50000,
            notes: 'Bersepeda mengelilingi pulau yang tidak ada kendaraan bermotor',
          ),
          TripActivity(
            time: '19:00',
            name: 'Sunset Dinner di Pantai',
            type: 'restaurant',
            location: 'Gili Trawangan',
            duration: '2.5 jam',
            estimatedCost: 250000,
            notes: 'Menikmati sunset sambil makan seafood langsung dari pantai',
          ),
          TripActivity(
            time: '21:30',
            name: 'Kembali ke Senggigi',
            type: 'transport',
            location: 'Gili Trawangan ke Senggigi',
            duration: '2 jam',
            estimatedCost: 200000,
            notes: 'Perahu malam kembali ke Senggigi untuk malam terakhir',
          ),
        ],
        dailyCost: 900000,
      ),
    ];

    // Adjust number of days based on query hints
    int daysCount = 3; // default
    if (lowerQuery.contains('2 hari') || lowerQuery.contains('dua hari')) {
      daysCount = 2;
    } else if (lowerQuery.contains('4 hari') || lowerQuery.contains('empat hari')) {
      daysCount = 4;
    } else if (lowerQuery.contains('5 hari') || lowerQuery.contains('lima hari')) {
      daysCount = 5;
    } else if (lowerQuery.contains('minggu') || lowerQuery.contains('pekan')) {
      daysCount = 7;
    }

    // Trim or extend days list as needed
    if (daysCount < days.length) {
      days.length = daysCount;
    } else if (daysCount > days.length) {
      // Simple extension - duplicate last day with modifications
      while (days.length < daysCount) {
        final lastDay = days.last;
        final newDay = TripDay(
          day: lastDay.day + 1,
          title: 'Hari ${lastDay.day + 1}: Aktivitas Bebas',
          activities: [
            TripActivity(
              time: '09:00',
              name: 'Sarapan dan Aktivitas Bebas',
              type: 'restaurant',
              location: 'Hotel',
              duration: '3 jam',
              estimatedCost: 100000,
              notes: 'Waktu luang untuk menjelajah sesuai keinginan',
            ),
            TripActivity(
              time: '14:00',
              name: 'Explore Lokasi Baru',
              type: 'restaurant',
              location: 'Area Sekitar',
              duration: '4 jam',
              estimatedCost: 200000,
              notes: 'Mengunjungi tempat-tempat yang belum dikunjungi',
            ),
            TripActivity(
              time: '19:00',
              name: 'Dinner dan Pernikahan',
              type: 'restaurant',
              location: 'Hotel atau Restoran Lokal',
              duration: '2 jam',
              estimatedCost: 200000,
              notes: 'Makan malam bersama untuk menutup hari',
            ),
          ],
          dailyCost: 500000,
        );
        days.add(newDay);
      }
    }

    // Recalculate total cost
    double totalCost = 0;
    for (final day in days) {
      totalCost += day.dailyCost;
    }

    return TripPlan(
      title: title,
      summary: summary,
      totalEstimatedCost: totalCost,
      days: days,
      tips: [
        'Bawa taman dan sunscreen karena sinar matahari di Lombok cukup tajam',
        'Pastikan membawa uang tunai karena bukan semua tempat menerima kartu',
        'Hormati budaya lokal dan baju saat mengunjungi tempat-tempat keagamaan',
        'Gunakan sandal yang nyaman karena banyak jalan-jalan yang dilakukan',
        'Coba kuliner lokal seperti ayam taliwang, plecing kangkung, dan bebek betutu',
      ],
      bestTimeToVisit: bestTimeToVisit,
    );
  }

  Widget _buildResult(TripPlan plan) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.summary,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, size: 16),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.ait_planTotalLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        MoneyText(plan.totalEstimatedCost,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (plan.bestTimeToVisit.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(plan.bestTimeToVisit, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Days itinerary
          ...plan.days.map((day) => daySection(day: day)),

          if (plan.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.ait_planTipsTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ...plan.tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _saveTrip(plan),
              icon: const Icon(Icons.save),
              label: Text(l10n.ait_plannerSaveTrip),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget daySection({required TripDay day}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  day.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              MoneyText(
                day.dailyCost,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...day.activities.map((a) => activityTile(activity: a)),
        ],
      ),
    );
  }

  Widget activityTile({required TripActivity activity}) {
    IconData getIcon(String type) {
      switch (type) {
        case 'hotel':
          return Icons.hotel;
        case 'restaurant':
          return Icons.restaurant;
        case 'transport':
          return Icons.directions_car;
        case 'activity':
          return Icons.event_available;
        case 'attraction':
          return Icons.place;
        default:
          return Icons.place;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 38, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(getIcon(activity.type), size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      activity.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activity.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                if (activity.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      activity.notes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrip(TripPlan plan) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Convert TripPlan to TripModel for persistence
      final tripModel = TripModel.fromTripPlan(
        plan: plan,
        destination: 'Lombok, Indonesia', // Could be extracted from plan
        duration: plan.days.length,
        budget: plan.totalEstimatedCost,
        interests: [], // Could be extracted from plan
        groupType: null, // Could be determined from plan
      );

      // Save to repository
      context.read<TripBloc>().add(
            TripSaveRequested(trip: tripModel),
          );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ait_plannerSavedSuccess),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Navigate to trip management to see the saved trip
        context.push(AppRouter.tripManagement);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ait_plannerSaveFailed(e.toString())),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}