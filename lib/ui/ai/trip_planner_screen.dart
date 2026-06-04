import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/viewmodel/ai/ai_bloc.dart';

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
      appBar: AppBar(title: const Text('AI Trip Planner'), centerTitle: true),
      body: BlocBuilder<AiBloc, AiState>(
        builder: (context, state) {
          if (state is AiTripPlanLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('🤖 Merencanakan itinerary ${_duration} hari...',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Ini mungkin memerlukan 10-15 detik',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            );
          }
          if (state is AiTripPlanLoaded) return _buildResult(state);
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rencanakan Perjalananmu ke Lombok! 🌴',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Isi detail perjalanan, AI akan membuat itinerary untukmu',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),

          _sectionTitle('⏱️ Durasi Perjalanan'),
          Row(
            children: [
              for (final d in [2, 3, 5, 7])
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text('$d Hari'),
                    selected: _duration == d,
                    onSelected: (_) => setState(() => _duration = d),
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                        color: _duration == d ? Colors.white : Colors.black87),
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
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) => setState(() => _budget = v),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('\$${_budget.toInt()}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _sectionTitle('👥 Tipe Grup'),
          Row(
            children: groupTypes.map((g) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _groupType = g.$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _groupType == g.$2
                        ? AppTheme.primaryColor
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${g.$1} ${g.$3}',
                      style: TextStyle(
                          color: _groupType == g.$2 ? Colors.white : Colors.black87,
                          fontSize: 13)),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          _sectionTitle('🎯 Minat Wisata (pilih beberapa)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((i) {
              final selected = _selectedInterests.contains(i.$2);
              return FilterChip(
                label: Text('${i.$1} ${i.$2}'),
                selected: selected,
                onSelected: (_) => setState(() {
                  if (selected) {
                    _selectedInterests.remove(i.$2);
                  } else {
                    _selectedInterests.add(i.$2);
                  }
                }),
                selectedColor: AppTheme.primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87),
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(AiTripPlanLoaded state) {
    final plan = state.plan;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(plan.summary,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statChip('💰 Est. \$${plan.totalEstimatedCost.toInt()}'),
                    const SizedBox(width: 8),
                    _statChip('📅 ${plan.days.length} Hari'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Days
          ...plan.days.map((day) => _DayCard(day: day)),

          // Tips
          if (plan.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('💡 Tips Perjalanan',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...plan.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: TextStyle(fontSize: 16, color: AppTheme.primaryColor)),
                      Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AiBloc>().add(AiChatCleared()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Buat Ulang'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

class _DayCard extends StatelessWidget {
  final day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 14,
                  child: Text('${day.day}',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(day.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('\$${day.dailyCost.toInt()}',
                    style: const TextStyle(
                        color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: day.activities.map<Widget>((act) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(act.time,
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(act.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(act.location,
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 12)),
                              if (act.notes.isNotEmpty)
                                Text('💡 ${act.notes}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (act.estimatedCost > 0)
                          Text('\$${act.estimatedCost.toInt()}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
