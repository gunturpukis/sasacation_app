import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/group_model.dart';
import 'package:sasacation/data/repo/group_repository.dart';

/// F8: detail budget grup — kartu "Spending Gap Detected" bila over
/// (memakai pct_over backend), anggota + fair share, daftar pengeluaran,
/// tambah/hapus pengeluaran.
class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _repo = GroupRepository();
  GroupModel? _group;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final group = await _repo.getGroup(widget.groupId);
    if (!mounted) return;
    setState(() {
      _group = group;
      _loading = false;
    });
  }

  Future<void> _addExpense() async {
    final labelCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var saving = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dlg) => StatefulBuilder(
        builder: (dlg, setDlg) => AlertDialog(
          title: const Text('Pengeluaran Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'mis. Dinner',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (USD)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dlg, false),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final amount =
                          double.tryParse(amountCtrl.text.trim());
                      if (labelCtrl.text.trim().isEmpty ||
                          amount == null ||
                          amount <= 0) {
                        return;
                      }
                      setDlg(() => saving = true);
                      final res = await _repo.addExpense(
                        groupId: widget.groupId,
                        label: labelCtrl.text.trim(),
                        amount: amount,
                      );
                      if (!dlg.mounted) return;
                      Navigator.pop(dlg, res['success'] == true);
                      if (res['success'] != true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ??
                                'Gagal menambah pengeluaran'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _deleteExpense(GroupExpense e) async {
    final res = await _repo.deleteExpense(
        groupId: widget.groupId, expenseId: e.id);
    if (!mounted) return;
    if (res['success'] == true) {
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(res['message'] ?? 'Gagal menghapus pengeluaran'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar:
          AppBar(title: Text(_group?.name ?? 'Group'), centerTitle: true),
      floatingActionButton:
          _group == null || _loading
              ? null
              : FloatingActionButton.extended(
                onPressed: _addExpense,
                backgroundColor: AppTheme.primaryContainer,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Pengeluaran',
                    style: TextStyle(color: Colors.white)),
              ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _group == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_off_outlined,
                        size: 56,
                        color: AppTheme.outlineVariant),
                    const SizedBox(height: 12),
                    Text('Grup tidak ditemukan',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _summaryCard(context, _group!),
                    // Kartu gap — HANYA bila backend menyatakan over
                    // (gap_status + pct_over), mengikuti Figma.
                    if (_group!.isOver) ...[
                      const SizedBox(height: 14),
                      _gapCard(context, _group!),
                    ],
                    const SizedBox(height: 20),
                    Text('Anggota (${_group!.memberCount})',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge),
                    const SizedBox(height: 10),
                    ..._group!.members.map(
                      (m) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusLg),
                          boxShadow: AppTheme.softCardShadow,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primary
                                  .withOpacity(0.1),
                              child: Text(
                                m.name.isNotEmpty
                                    ? m.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight:
                                        FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(m.name,
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w600)),
                                  Text(
                                    'Bayar \$${m.paid.toStringAsFixed(0)} • Bagian \$${m.fairShare.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.outline),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              m.balance >= 0
                                  ? '+\$${m.balance.toStringAsFixed(0)}'
                                  : '-\$${m.balance.abs().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: m.balance >= 0
                                    ? AppTheme.successColor
                                    : AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                        'Pengeluaran (${_group!.expenses.length})',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge),
                    const SizedBox(height: 10),
                    if (_group!.expenses.isEmpty)
                      const Text(
                        'Belum ada pengeluaran tercatat.',
                        style: TextStyle(
                            color: AppTheme.outline,
                            fontSize: 13),
                      ),
                    ..._group!.expenses.map(
                      (e) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusLg),
                          boxShadow: AppTheme.softCardShadow,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(e.label,
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w600)),
                                  if (e.category != null)
                                    Text(e.category!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppTheme.outline)),
                                ],
                              ),
                            ),
                            Text(
                              '-\$${e.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18),
                              color: AppTheme.error,
                              onPressed: () =>
                                  _deleteExpense(e),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
    );
  }

  Widget _summaryCard(BuildContext context, GroupModel g) {
    final pct = g.budgetTotal > 0
        ? (g.totalSpent / g.budgetTotal).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GROUP BUDGET',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Text(g.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppTheme.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: AlwaysStoppedAnimation(g.isOver
                  ? AppTheme.secondaryContainer
                  : Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${g.totalSpent.toStringAsFixed(0)} terpakai dari \$${g.budgetTotal.toStringAsFixed(0)} • Sisa \$${g.remaining.toStringAsFixed(0)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _gapCard(BuildContext context, GroupModel g) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
            color: AppTheme.secondaryContainer.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GROUP BUDGET EQUITY',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTheme.secondary)),
          const SizedBox(height: 4),
          Text('Spending Gap Detected',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Pengeluaran grup ${g.pctOver.toStringAsFixed(0)}% di atas budget bersama. Pertimbangkan alternatif yang lebih hemat.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
