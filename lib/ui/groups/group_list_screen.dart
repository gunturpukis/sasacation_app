import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/group_model.dart';
import 'package:sasacation/data/repo/group_repository.dart';
import 'package:sasacation/route/approuter.dart';

/// F8: daftar grup budget user + buat grup baru.
/// Entry point: menu "My Groups" di profil + tombol notifikasi group_detail.
class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final _repo = GroupRepository();
  List<GroupModel> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final groups = await _repo.getMyGroups();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  Future<void> _createGroup() async {
    final nameCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    var saving = false;
    final result = await showDialog<bool>(
      context: context,
      builder: (dlg) => StatefulBuilder(
        builder: (dlg, setDlg) => AlertDialog(
          title: const Text('Grup Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama grup',
                    hintText: 'mis. Bali Trip',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: destCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Destinasi (opsional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Budget total (opsional)',
                    hintText: 'mis. 1000',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dlg, false),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setDlg(() => saving = true);
                      final res = await _repo.createGroup(
                        name: nameCtrl.text.trim(),
                        destination: destCtrl.text.trim().isEmpty
                            ? null
                            : destCtrl.text.trim(),
                        budgetTotal:
                            double.tryParse(budgetCtrl.text.trim()),
                      );
                      if (!dlg.mounted) return;
                      Navigator.pop(dlg, res['success'] == true);
                      if (res['success'] != true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ??
                                'Gagal membuat grup'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    },
              child: saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Buat'),
            ),
          ],
        ),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('My Groups'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGroup,
        backgroundColor: AppTheme.primaryContainer,
        icon: const Icon(Icons.group_add_outlined, color: Colors.white),
        label: const Text('Grup Baru',
            style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_outlined,
                          size: 64, color: AppTheme.outlineVariant),
                      const SizedBox(height: 12),
                      Text('Belum ada grup',
                          style:
                              Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Buat grup untuk patungan budget trip bareng.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                    itemCount: _groups.length,
                    itemBuilder: (context, i) {
                      final g = _groups[i];
                      final pct = g.budgetTotal > 0
                          ? (g.totalSpent / g.budgetTotal)
                              .clamp(0.0, 1.0)
                          : 0.0;
                      return GestureDetector(
                        onTap: () => context
                            .push(AppRouter.groupDetailPath(g.id))
                            .then((_) => _load()),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusLg),
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(g.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                  ),
                                  if (g.isOver)
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .secondaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppTheme.radiusFull),
                                      ),
                                      child: Text(
                                        '+${g.pctOver.toStringAsFixed(0)}% over',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w700),
                                      ),
                                    ),
                                ],
                              ),
                              if (g.destination != null &&
                                  g.destination!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 2),
                                  child: Text(g.destination!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
                                  backgroundColor:
                                      AppTheme.surfaceContainerHigh,
                                  valueColor:
                                      AlwaysStoppedAnimation(
                                          g.isOver
                                              ? AppTheme
                                                  .secondaryContainer
                                              : AppTheme
                                                  .primaryContainer),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${g.totalSpent.toStringAsFixed(0)} dari \$${g.budgetTotal.toStringAsFixed(0)} • ${g.memberCount} anggota',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
