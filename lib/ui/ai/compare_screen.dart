import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/repo/compare_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/utils/money.dart';

/// F.3 AI Hotel Compare — layar hasil perbandingan 2–3 hotel.
/// Dibuka dengan `extra`: List<String> hotelIds (dari wishlist/search).
/// Fail-soft: error BE → pesan + tombol kembali (no-fake-data).
class CompareScreen extends StatefulWidget {
  final List<String> hotelIds;
  const CompareScreen({super.key, required this.hotelIds});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late final Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = CompareRepository().compare(widget.hotelIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bandingkan Hotel'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('🤖 AI membandingkan hotel...', style: TextStyle(color: Colors.grey)),
              ]),
            );
          }
          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('${snap.error ?? 'Gagal membandingkan'}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Kembali'),
                  ),
                ]),
              ),
            );
          }
          final data = snap.data!;
          final matrix = List<Map<String, dynamic>>.from(
            (data['matrix'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
          );
          final tradeoffs = List<String>.from(data['tradeoffs'] ?? []);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Verdict AI
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${data['verdict'] ?? ''}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor)),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              const Text('Perbandingan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Aspek')),
                    for (final m in matrix) DataColumn(label: Text('${m['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    _row('Harga', matrix, (m) => MoneyText((m['price'] as num?)?.toDouble() ?? 0)),
                    _row('Lokasi', matrix, (m) => _stars(m['locationScore'])),
                    _row('Kamar', matrix, (m) => _stars(m['roomScore'])),
                    _row('Breakfast', matrix, (m) => Text(m['breakfast'] == true ? '✅' : '❌')),
                    _row('Pool', matrix, (m) => Text(m['pool'] == true ? '✅' : '❌')),
                    _row('Couple', matrix, (m) => _stars(m['coupleFit'])),
                    _row('Value', matrix, (m) => Text('${m['value'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Trade-offs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...tradeoffs.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('•  '),
                      Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                    ]),
                  )),
              const SizedBox(height: 16),
              Row(children: [
                for (int i = 0; i < matrix.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(AppRouter.hotelDetailPath('${matrix[i]['hotelId']}')),
                      child: Text('${matrix[i]['name'] ?? 'Detail'}', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ]),
            ]),
          );
        },
      ),
    );
  }

  DataRow _row(String label, List<Map<String, dynamic>> matrix, Widget Function(Map<String, dynamic>) cell) {
    return DataRow(cells: [DataCell(Text(label)), for (final m in matrix) DataCell(cell(m))]);
  }

  Widget _stars(dynamic v) {
    final n = (v is num) ? v.toInt() : 3;
    return Text('⭐' * n.clamp(1, 5));
  }
}
