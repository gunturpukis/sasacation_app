import 'package:sasacation/utils/json_helper.dart';

/// F8: budget grup. Kontrak backend (FLUTTER_HANDOFF.md):
/// group { id, name, destination?, budget_total, currency, total_spent,
/// remaining, member_count, members[{ user_id, name, avatar, paid,
/// fair_share, balance }], expenses[{ id, label, amount, category?,
/// spent_at? }], gap_status: none|under|near|over, pct_over }.
class GroupMember {
  final String userId;
  final String name;
  final String? avatar;
  final double paid;
  final double fairShare;
  final double balance;

  const GroupMember({
    required this.userId,
    required this.name,
    this.avatar,
    required this.paid,
    required this.fairShare,
    required this.balance,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
        userId: (json['user_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        avatar: json['avatar']?.toString(),
        paid: parseDouble(json['paid']),
        fairShare: parseDouble(json['fair_share']),
        balance: parseDouble(json['balance']),
      );
}

class GroupExpense {
  final String id;
  final String label;
  final double amount;
  final String? category;
  final DateTime? spentAt;

  const GroupExpense({
    required this.id,
    required this.label,
    required this.amount,
    this.category,
    this.spentAt,
  });

  factory GroupExpense.fromJson(Map<String, dynamic> json) {
    DateTime? spent;
    final raw = json['spent_at'];
    if (raw is String) spent = DateTime.tryParse(raw);
    return GroupExpense(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      amount: parseDouble(json['amount']),
      category: json['category']?.toString(),
      spentAt: spent,
    );
  }
}

class GroupModel {
  final String id;
  final String name;
  final String? destination;
  final double budgetTotal;
  final String currency;
  final double totalSpent;
  final double remaining;
  final int memberCount;
  final List<GroupMember> members;
  final List<GroupExpense> expenses;
  final String gapStatus;
  final double pctOver;

  const GroupModel({
    required this.id,
    required this.name,
    this.destination,
    required this.budgetTotal,
    required this.currency,
    required this.totalSpent,
    required this.remaining,
    required this.memberCount,
    required this.members,
    required this.expenses,
    required this.gapStatus,
    required this.pctOver,
  });

  bool get isOver => gapStatus == 'over';

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        destination: json['destination']?.toString(),
        budgetTotal: parseDouble(json['budget_total']),
        currency: (json['currency'] ?? 'USD').toString(),
        totalSpent: parseDouble(json['total_spent']),
        remaining: parseDouble(json['remaining']),
        memberCount: parseInt(json['member_count']),
        members: (json['members'] as List? ?? [])
            .whereType<Map>()
            .map((e) =>
                GroupMember.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        expenses: (json['expenses'] as List? ?? [])
            .whereType<Map>()
            .map((e) =>
                GroupExpense.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        gapStatus: (json['gap_status'] ?? 'none').toString(),
        pctOver: parseDouble(json['pct_over']),
      );
}
