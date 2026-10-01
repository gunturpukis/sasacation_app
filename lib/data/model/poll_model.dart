import 'package:sasacation/utils/json_helper.dart';

/// F7: voting grup. Kontrak backend (FLUTTER_HANDOFF.md):
/// poll { id, title, description?, status/is_open, total_votes,
/// my_option_id, options[{ id, label, votes, pct }] }.
class PollOption {
  final String id;
  final String label;
  final int votes;
  final double pct;

  const PollOption({
    required this.id,
    required this.label,
    required this.votes,
    required this.pct,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
        id: (json['id'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
        votes: parseInt(json['votes']),
        pct: parseDouble(json['pct']),
      );
}

class PollModel {
  final String id;
  final String title;
  final String? description;
  final bool isOpen;
  final int totalVotes;
  final String? myOptionId;
  final List<PollOption> options;
  final String? creatorId;

  const PollModel({
    required this.id,
    required this.title,
    this.description,
    required this.isOpen,
    required this.totalVotes,
    this.myOptionId,
    required this.options,
    this.creatorId,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString().toLowerCase();
    final open = json['is_open'];
    return PollModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      isOpen: open is bool ? open : status != 'closed',
      totalVotes: parseInt(json['total_votes']),
      myOptionId: json['my_option_id']?.toString(),
      options: (json['options'] as List? ?? [])
          .whereType<Map>()
          .map((e) =>
              PollOption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      creatorId: json['user_id']?.toString(),
    );
  }
}
