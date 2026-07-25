
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/ui/widget/pill_badge.dart';
import 'package:sasacation/viewmodel/ai/ai_bloc.dart';
 
/// TripPlannerScreen — restyle mengikuti mockup `sasa_ai_trip_planner`.
///
/// PERUBAHAN STRUKTUR pada tampilan hasil (_buildResult):
/// - SEBELUM: semua hari ditumpuk vertikal dalam satu scroll panjang.
/// - SEKARANG: day-tab pills (Day 1, Day 2, ...) — cuma 1 hari yang
///   ditampilkan sekaligus, sesuai mockup. Ini perubahan interaksi nyata,
///   bukan cuma reskin warna, tapi datanya (plan.days) sudah selalu ada
///   sebagai List — tidak perlu perubahan apa pun di backend.
/// - Card aktivitas sekarang pakai timeline vertikal (garis + icon node per
///   tipe aktivitas), bukan Row rata kiri sederhana.
///
/// CATATAN JUJUR — 2 elemen mockup yang SENGAJA tidak diimplementasikan:
/// - "Human-Error Buffer" (AI menyarankan istirahat, tombol Accept
///   Rest/Ignore) — ini butuh LOGIKA AGENT BARU (semacam "Fatigue Agent")
///   yang menghitung kelelahan dari kepadatan itinerary. Backend belum
///   punya ini sama sekali (lihat agentOrchestratorService.js — cuma ada
///   Hotel/Restaurant/Activity/Budget Agent). Menambahkan tombolnya di UI
///   tanpa logic di baliknya cuma bikin UI yang menipu.
/// - "Suggested: Sunset Yoga" (rekomendasi tambahan dengan tombol "+" untuk
///   menambah ke itinerary) — sama, butuh backend yang bisa terima
///   modifikasi itinerary parsial. TripPlan saat ini di-generate sekali,
///   utuh — tidak ada endpoint untuk "tambah 1 aktivitas ke plan yang sudah
///   ada".
/// Kalau dua fitur ini penting buat Anda, itu pekerjaan backend dulu (agent
/// baru + endpoint baru), baru UI-nya menyusul — bukan sebaliknya.
class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});
 
  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}
 
class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _duration = 3;
  double _budget = 300;
  String _groupType = 'couple';
  final Set<String> _selectedInterests = {'Hotels', 'Beaches'};
  int _selectedDayIndex = 0;
 
  static const interests = [
    ('🏖️', 'Beaches'), ('🏨', 'Hotels'), ('🍢', 'Culinary'),
    ('🏔️', 'Adventure'), ('🌺', 'Culture'), ('🏝️', 'Islands'),
  ];
  static const groupTypes = [
    ('👫', 'couple', 'Couple'),
    ('👨‍👩‍👧‍👦', 'family', 'Keluarga'),
    ('👯', 'friends', 'Teman'),
    ('🧍', 'solo', 'Solo'),
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('AI Trip Planner'), centerTitle: true),
      body: BlocBuilder<AiBloc, AiState>(
        builder: (context, state) {
          if (state is AiTripPlanLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 20),
                  Text('Sasa sedang menyusun itinerary $_duration hari...',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Ini bisa memakan waktu 1-2 menit di device Anda',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          if (state is AiTripPlanLoaded) {
            _selectedDayIndex = _selectedDayIndex.clamp(0, state.plan.days.length - 1);
            return _buildResult(state);
          }
          if (state is AiError) return _buildError(context, state.message);
          return _buildForm();
        },
      ),
    );
  }
 
  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<AiBloc>().add(AiStateReset()),
              child: const Text('Ubah Preferensi'),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rencanakan Perjalananmu ke Lombok! 🌴',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Isi detail perjalanan, AI akan membuat itinerary untukmu',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
 
          _sectionTitle('⏱️ Durasi Perjalanan'),
          Row(
            children: [
              for (final d in [2, 3, 5, 7])
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _pillChoice(
                    label: '$d Hari',
                    selected: _duration == d,
                    onTap: () => setState(() => _duration = d),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
 
          _sectionTitle('💰 Budget per Orang (USD)'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _budget,
                  min: 100,
                  max: 2000,
                  divisions: 19,
                  label: '\$${_budget.toInt()}',
                  activeColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _budget = v),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text('\$${_budget.toInt()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
 
          _sectionTitle('👥 Tipe Grup'),
          Row(
            children: groupTypes
                .map((g) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _pillChoice(
                        label: '${g.$1} ${g.$3}',
                        selected: _groupType == g.$2,
                        onTap: () => setState(() => _groupType = g.$2),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
 
          _sectionTitle('🎯 Minat Wisata (pilih beberapa)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((i) {
              final selected = _selectedInterests.contains(i.$2);
              return _pillChoice(
                label: '${i.$1} ${i.$2}',
                selected: selected,
                onTap: () => setState(() {
                  selected ? _selectedInterests.remove(i.$2) : _selectedInterests.add(i.$2);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
 
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedInterests.isEmpty ? null : _generatePlan,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Buat Itinerary dengan AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _pillChoice({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }
 
  Widget _buildResult(AiTripPlanLoaded state) {
    final plan = state.plan;
    final selectedDay = plan.days[_selectedDayIndex];
 
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppTheme.tertiary),
                    const SizedBox(width: 4),
                    Text('SASA AI GENERATOR',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.tertiary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(plan.title, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(plan.summary, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PillBadge(
                      label: 'Est. \$${plan.totalEstimatedCost.toInt()}',
                      icon: Icons.payments_outlined,
                      backgroundColor: AppTheme.surfaceContainerLow,
                      foregroundColor: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    PillBadge(
                      label: '${plan.days.length} Hari',
                      icon: Icons.calendar_today_outlined,
                      backgroundColor: AppTheme.surfaceContainerLow,
                      foregroundColor: AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
 
                // ─── Day tab pills ────────────────────────────────────────
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: plan.days.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final selected = index == _selectedDayIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text('Day ${plan.days[index].day}',
                              style: TextStyle(
                                  color: selected ? Colors.white : AppTheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
 
                // ─── Timeline hari terpilih ─────────────────────────────────
                _DayTimeline(day: selectedDay),
 
                if (plan.tips.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Tips Perjalanan', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  ...plan.tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  ', style: TextStyle(fontSize: 16, color: AppTheme.primary)),
                            Expanded(child: Text(tip, style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surface, boxShadow: AppTheme.floatingShadow),
          child: SafeArea(
            top: false,
            child: OutlinedButton.icon(
              onPressed: () => context.read<AiBloc>().add(AiChatCleared()),
              icon: const Icon(Icons.refresh),
              label: const Text('Buat Ulang'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
              ),
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
 
  void _generatePlan() {
    context.read<AiBloc>().add(AiTripPlanRequested(
          duration: _duration,
          budget: _budget,
          interests: _selectedInterests.toList(),
          groupType: _groupType,
        ));
  }
}
 
/// Timeline vertikal 1 hari — garis penghubung + icon node per aktivitas,
/// sesuai mockup. Ini pengganti langsung Row rata-kiri sederhana yang lama.
class _DayTimeline extends StatelessWidget {
  final TripDay day;
  const _DayTimeline({required this.day});
 
  IconData _iconFor(String type) {
    switch (type) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      default:
        return Icons.place;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < day.activities.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom garis + icon node
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppTheme.primaryContainer, shape: BoxShape.circle),
                      child: Icon(_iconFor(day.activities[i].type), color: Colors.white, size: 18),
                    ),
                    if (i != day.activities.length - 1)
                      Expanded(
                        child: Container(width: 2, color: AppTheme.outlineVariant.withOpacity(0.5)),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Card aktivitas
                Expanded(
                  child: Container(
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
                            Text(day.activities[i].time,
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                            if (day.activities[i].estimatedCost > 0)
                              Text('\$${day.activities[i].estimatedCost.toInt()}',
                                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(day.activities[i].name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
                        if (day.activities[i].location.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(day.activities[i].location, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                        if (day.activities[i].notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(day.activities[i].notes,
                              style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
 