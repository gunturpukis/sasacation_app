import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/task_model.dart';
import 'package:sasacation/data/repo/task_repository.dart';

/// F10: daftar travel task (check-in penerbangan, pengingat, pembayaran,
/// dokumen). Kartu flight_checkin merender payload { flight_no, seats[] }
/// seperti Figma ("Check-in Open GA-421 … Seats: 12A, 12B, 12C").
/// Entry point: menu "Travel Tasks" di profil.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = TaskRepository();
  List<TaskModel> _tasks = [];
  bool _loading = true;
  bool _showDone = false;

  static const _kinds = {
    'flight_checkin': 'Check-in Penerbangan',
    'reminder': 'Pengingat',
    'payment': 'Pembayaran',
    'document': 'Dokumen',
    'other': 'Lainnya',
  };

  static const _kindIcons = {
    'flight_checkin': Icons.flight_takeoff_outlined,
    'reminder': Icons.alarm_outlined,
    'payment': Icons.payments_outlined,
    'document': Icons.description_outlined,
    'other': Icons.task_alt_outlined,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final tasks = await _repo.getMyTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _toggle(TaskModel t) async {
    final ok = await _repo.setDone(id: t.id, done: !t.done);
    if (ok) _load();
  }

  Future<void> _delete(TaskModel t) async {
    final ok = await _repo.deleteTask(t.id);
    if (!mounted) return;
    if (ok) {
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus task'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _create() async {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    var kind = 'reminder';
    var saving = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dlg) => StatefulBuilder(
        builder: (dlg, setDlg) => AlertDialog(
          title: const Text('Task Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: kind,
                  items: _kinds.entries
                      .map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) =>
                      setDlg(() => kind = v ?? 'reminder'),
                  decoration:
                      const InputDecoration(labelText: 'Jenis'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Detail (opsional)',
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
                      if (titleCtrl.text.trim().isEmpty) return;
                      setDlg(() => saving = true);
                      final res = await _repo.createTask(
                        title: titleCtrl.text.trim(),
                        kind: kind,
                        detail: detailCtrl.text.trim().isEmpty
                            ? null
                            : detailCtrl.text.trim(),
                      );
                      if (!dlg.mounted) return;
                      Navigator.pop(dlg, res['success'] == true);
                      if (res['success'] != true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ??
                                'Gagal membuat task'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible =
        _showDone ? _tasks : _tasks.where((t) => !t.done).toList();
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Travel Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _showDone
                ? 'Sembunyikan selesai'
                : 'Tampilkan selesai',
            icon: Icon(_showDone
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () =>
                setState(() => _showDone = !_showDone),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppTheme.primaryContainer,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Task Baru',
            style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : visible.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.task_alt_outlined,
                          size: 64,
                          color: AppTheme.outlineVariant),
                      const SizedBox(height: 12),
                      Text(
                        _tasks.isEmpty
                            ? 'Belum ada task'
                            : 'Semua task selesai 🎉',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 90),
                    itemCount: visible.length,
                    itemBuilder: (context, i) =>
                        _taskCard(context, visible[i]),
                  ),
                ),
    );
  }

  Widget _taskCard(BuildContext context, TaskModel t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius:
            BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
                _kindIcons[t.kind] ?? Icons.task_alt_outlined,
                size: 20,
                color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kinds[t.kind] ?? t.kind,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary),
                ),
                const SizedBox(height: 2),
                Text(t.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: t.done
                            ? TextDecoration.lineThrough
                            : null)),
                if (t.detail != null && t.detail!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(t.detail!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium),
                  ),
                // Payload penerbangan seperti Figma: nomor + kursi.
                if (t.flightNo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd),
                      ),
                      child: Text(
                        'Penerbangan ${t.flightNo}${t.seats.isNotEmpty ? ' • Kursi: ${t.seats.join(', ')}' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Checkbox(
                value: t.done,
                activeColor: AppTheme.primaryContainer,
                onChanged: (_) => _toggle(t),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppTheme.error,
                onPressed: () => _delete(t),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
