import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/ai_model.dart';

/// Screen: AgentTripPlanResultScreen
/// Ditampilkan saat user ketuk kartu "Lihat Itinerary" di chat — hasil dari
/// Agent-Based Workflow (Hotel/Restaurant/Activity/Budget/Composer Agent
/// yang dijalankan otomatis dari intent chat, lihat aiController.js).
///
/// Sengaja dibuat sebagai screen TERPISAH dari TripPlannerScreen (bukan reuse
/// widget yang sama) karena widget hasil di sana (_DayCard dkk) bersifat
/// private ke file itu. Duplikasi render sederhana di sini lebih aman
/// daripada mengubah trip_planner_screen.dart yang sudah stabil.
class AgentTripPlanResultScreen extends StatelessWidget {
  final TripPlan plan;
  const AgentTripPlanResultScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.summary, style: const TextStyle(fontSize: 14, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text('Estimasi total: \$${plan.totalEstimatedCost.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                          child: Text(plan.bestTimeToVisit, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...plan.days.map((day) => _DaySection(day: day)),
          if (plan.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final TripDay day;
  const _DaySection({required this.day});

  @override
  Widget build(BuildContext context) {
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
                child: Text('${day.day}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(day.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Text('\$${day.dailyCost.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 10),
          ...day.activities.map((a) => _ActivityTile(activity: a)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final TripActivity activity;
  const _ActivityTile({required this.activity});

  IconData get _icon {
    switch (activity.type) {
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
    return Padding(
      padding: const EdgeInsets.only(left: 38, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(activity.time,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(activity.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
                if (activity.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(activity.notes,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
