import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/data/model/trip_model.dart';
import 'package:sasacation/data/repo/ai_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/utils/money.dart';
import 'package:sasacation/viewmodel/trip/trip_bloc.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final _budgetCtrl = TextEditingController(text: '500');
  bool _isGenerating = false;
  String? _errorMessage;
  TripPlan? _generatedPlan;

  // S2.1: parameter terstruktur untuk POST /ai/trip-plan
  // (menggantikan input teks bebas + mock keyword-matching).
  int _duration = 3;
  final Set<String> _interests = {'beach'};

  static const _interestValues = [
    'beach',
    'culinary',
    'adventure',
    'culture',
    'islands',
  ];

  /// Preset cepat: label dirakit dari nama minat + angka (terlokalisasi
  /// tanpa key baru) — ketuk untuk isi parameter + langsung generate.
  List<Map<String, dynamic>> _presets(AppLocalizations l10n) => [
        {
          'interests': {'beach'},
          'duration': 3,
          'budget': '500',
        },
        {
          'interests': {'culinary'},
          'duration': 2,
          'budget': '300',
        },
        {
          'interests': {'adventure'},
          'duration': 4,
          'budget': '800',
        },
        {
          'interests': {'culture'},
          'duration': 2,
          'budget': '300',
        },
      ];

  String _interestLabel(AppLocalizations l10n, String value) => switch (value) {
        'beach' => l10n.fun_interestBeach,
        'culinary' => l10n.fun_interestCulinary,
        'adventure' => l10n.fun_interestAdventure,
        'culture' => l10n.fun_interestCulture,
        'islands' => l10n.fun_interestIslands,
        _ => value,
      };

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
            // Parameter terstruktur (S2.1) — backend butuh duration,
            // budget, interests; bukan teks bebas.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.fun_plannerDuration,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.primary,
                          onPressed: _isGenerating || _duration <= 1
                              ? null
                              : () => setState(() => _duration--),
                        ),
                        Text('$_duration',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.primary,
                          onPressed: _isGenerating || _duration >= 14
                              ? null
                              : () => setState(() => _duration++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _budgetCtrl,
                      keyboardType: TextInputType.number,
                      enabled: !_isGenerating,
                      decoration: InputDecoration(
                        labelText: l10n.fun_plannerBudget,
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: AppTheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.fun_plannerInterests,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _interestValues.map((v) {
                        final selected = _interests.contains(v);
                        return FilterChip(
                          label: Text(_interestLabel(l10n, v)),
                          selected: selected,
                          onSelected: _isGenerating
                              ? null
                              : (_) => setState(() {
                                    if (selected) {
                                      _interests.remove(v);
                                    } else {
                                      _interests.add(v);
                                    }
                                  }),
                          selectedColor: AppTheme.primaryContainer
                              .withOpacity(0.25),
                          checkmarkColor: AppTheme.primary,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateTripPlan,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(l10n.fun_plannerGenerate),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Preset cepat
            if (!_isGenerating && _generatedPlan == null)
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
                      children: _presets(l10n)
                          .map(
                            (preset) => ChoiceChip(
                              label: Text(
                                '${(preset['interests'] as Set<String>).map((v) => _interestLabel(l10n, v)).join(', ')} • ${preset['duration']} ${l10n.fun_nightsLabel.toLowerCase()}',
                              ),
                              selected: false,
                              onSelected: (_) {
                                setState(() {
                                  _interests
                                    ..clear()
                                    ..addAll(preset['interests']
                                        as Set<String>);
                                  _duration =
                                      preset['duration'] as int;
                                  _budgetCtrl.text =
                                      preset['budget'] as String;
                                });
                                _generateTripPlan();
                              },
                              labelStyle:
                                  const TextStyle(fontSize: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              backgroundColor:
                                  AppTheme.surfaceContainerLow,
                              selectedColor:
                                  AppTheme.primaryContainer,
                              labelPadding:
                                  const EdgeInsets.symmetric(
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
                                    _generateTripPlan();
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

  /// S2.1: generate BENAR via POST /ai/trip-plan (agent backend).
  /// Timeout backend lega (180s, Ollama lokal lambat) — layar menampilkan
  /// loading jujur + error backend apa adanya, tanpa mock/delay palsu.
  Future<void> _generateTripPlan() async {
    final l10n = AppLocalizations.of(context);
    final budget = double.tryParse(_budgetCtrl.text.trim());
    if (_interests.isEmpty) {
      setState(() => _errorMessage = l10n.fun_plannerNeedInterest);
      return;
    }
    if (budget == null || budget <= 0) {
      setState(() => _errorMessage = l10n.fun_plannerInvalidBudget);
      return;
    }
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedPlan = null;
    });
    FocusScope.of(context).unfocus();

    final result = await AiRepository().generateTripPlan(
      duration: _duration,
      budget: budget,
      interests: _interests.toList(),
    );
    if (!mounted) return;
    setState(() {
      _isGenerating = false;
      if (result['success'] == true) {
        _generatedPlan = result['plan'] as TripPlan;
      } else {
        _errorMessage =
            result['message'] as String? ?? l10n.ait_plannerCreateFailed('');
      }
    });
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
      // Convert TripPlan to TripModel for persistence — parameter
      // diambil dari input terstruktur yang menghasilkan plan ini.
      final budget =
          double.tryParse(_budgetCtrl.text.trim()) ?? 0;
      final tripModel = TripModel.fromTripPlan(
        plan: plan,
        destination: 'Lombok, Indonesia',
        duration: _duration,
        budget: budget,
        interests: _interests.toList(),
        groupType: null,
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
    _budgetCtrl.dispose();
    super.dispose();
  }
}