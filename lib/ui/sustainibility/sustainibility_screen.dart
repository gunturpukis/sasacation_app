
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/api/api_client.dart';
import 'package:sasacation/route/approuter.dart';
 
/// SustainabilityScreen
///
/// INI BUKAN implementasi dari mockup `local_impact_ethics`. Mockup itu
/// menampilkan "Local Impact Score 842/1000", "Rp2.450.000 disalurkan ke
/// UMKM bulan ini", sertifikat digital ("Ocean Protector"), dan fitur
/// "Anti-Algorithm Discovery" — SEMUA angka & sertifikat itu FIKTIF, tidak
/// ada satu pun tabel di backend yang bisa menghasilkannya (tidak ada
/// tracking bisnis lokal vs korporasi, tidak ada sistem sertifikasi).
/// Menampilkan skor personal palsu ke user berpotensi menyesatkan.
///
/// Screen ini adalah versi jujur: halaman informasi statis tentang
/// komitmen Sasacation terhadap pariwisata Lombok, TANPA angka personal
/// yang dikarang. Kalau Anda mau versi yang benar-benar menghitung dampak
/// riil (dari data booking sungguhan), itu butuh pekerjaan backend
/// terpisah dulu — lihat catatan di bagian bawah build().
///
/// KONTRAK BACKEND untuk Impact Score penuh (bila diputuskan): flag
/// `is_local_business` di tabel merchants/hotels + agregasi per user:
/// GET /impact/summary → {score, level, local_pct, local_amount_idr,
/// certificates[]}; GET /impact/discovery → rekomendasi anti-algoritma.
/// Flutter tinggal render angka tersebut ke kartu skor/grafik/sertifikat
/// mengikuti mockup — tidak ada tebakan di sisi client.
/// Item discovery anti-algoritma (F2): rekomendasi yang 100% berbeda dari
/// kebiasaan user. `match_pct` tampil apa adanya dari backend.
class _DiscoveryItem {
  final String id;
  final String name;
  final String location;
  final String image;
  final int matchPct;
  final String matchNote;

  const _DiscoveryItem({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.matchPct,
    required this.matchNote,
  });

  factory _DiscoveryItem.fromJson(Map<String, dynamic> json) {
    final pct = json['match_pct'];
    return _DiscoveryItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      matchPct: pct is num ? pct.toInt() : int.tryParse('$pct') ?? 0,
      matchNote: (json['match_note'] ?? '').toString(),
    );
  }
}

class SustainabilityScreen extends StatefulWidget {
  const SustainabilityScreen({super.key});

  @override
  State<SustainabilityScreen> createState() => _SustainabilityScreenState();
}

class _SustainabilityScreenState extends State<SustainabilityScreen> {
  _DiscoveryItem? _discovery;
  bool _loadingDiscovery = true;
  bool _shuffling = false;
  String? _discoveryError;

  @override
  void initState() {
    super.initState();
    _loadDiscovery(shuffle: false);
  }

  Future<void> _loadDiscovery({required bool shuffle}) async {
    setState(() {
      if (shuffle) {
        _shuffling = true;
      } else {
        _loadingDiscovery = true;
      }
      _discoveryError = null;
    });
    try {
      final res = await ApiClient.get('/impact/discovery', params: {
        'limit': 1,
        if (shuffle) 'shuffle': true,
      });
      final raw = res.data['data'];
      final list = raw is List ? raw : const [];
      if (!mounted) return;
      setState(() {
        _discovery = list.isNotEmpty && list.first is Map
            ? _DiscoveryItem.fromJson(
                Map<String, dynamic>.from(list.first as Map))
            : null;
        _loadingDiscovery = false;
        _shuffling = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _discoveryError = 'Gagal memuat rekomendasi';
        _loadingDiscovery = false;
        _shuffling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Komitmen Sasacation'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.eco_outlined, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text('Wisata yang Bertanggung Jawab',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                const Text(
                  'Sasacation percaya pariwisata Lombok yang berkelanjutan dimulai dari '
                  'pilihan kecil setiap wisatawan — dari akomodasi yang dipilih sampai '
                  'siapa yang menerima manfaatnya.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
 
          _principle(
            context,
            icon: Icons.storefront_outlined,
            title: 'Dukungan ke Pelaku Usaha Lokal',
            description:
                'Kami mendorong penginapan, restoran, dan penyedia aktivitas yang '
                'dikelola langsung oleh warga Lombok untuk lebih mudah ditemukan di '
                'platform ini.',
          ),
          _principle(
            context,
            icon: Icons.recycling_outlined,
            title: 'Minim Sampah, Hormati Alam',
            description:
                'Kami merekomendasikan mitra yang menerapkan praktik ramah lingkungan — '
                'pengelolaan sampah, konservasi terumbu karang, dan penggunaan sumber '
                'daya yang bertanggung jawab.',
          ),
          _principle(
            context,
            icon: Icons.groups_outlined,
            title: 'Hormat pada Budaya Lokal',
            description:
                'Kami mendorong wisatawan untuk mengenal dan menghormati adat serta '
                'kebiasaan masyarakat Sasak dan komunitas lokal lainnya di Lombok.',
          ),
          const SizedBox(height: 28),

          // ─── Anti-Algorithm Discovery (F2, data nyata) ──────────────
          Text('Anti-Algorithm Discovery',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Bosan dengan rekomendasi yang dipersonalisasi? Temukan tempat '
            'yang 100% berbeda dari kebiasaan Anda.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _buildDiscoveryCard(context),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppTheme.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Skor dampak personal dan sertifikat per-user belum ditampilkan — '
                    'fitur itu butuh sistem tracking yang belum ada. Bagian discovery '
                    'di atas sudah memakai data rekomendasi nyata dari server.',
                    style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildDiscoveryCard(BuildContext context) {
    if (_loadingDiscovery) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_discoveryError != null || _discovery == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        child: Row(
          children: [
            const Expanded(
                child: Text('Rekomendasi belum tersedia saat ini')),
            TextButton(
              onPressed: () => _loadDiscovery(shuffle: false),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    final item = _discovery!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () =>
              context.push(AppRouter.hotelDetailPath(item.id)),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: AppTheme.softCardShadow,
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusCard),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surfaceContainerHigh)),
                  Container(
                      decoration: const BoxDecoration(
                          gradient: AppTheme.imageOverlayGradient)),
                  Positioned(
                    left: 14,
                    bottom: 44,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull),
                      ),
                      child: Text(
                          '${item.matchPct}% Match with Your History',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Text(item.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (item.matchNote.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(item.matchNote,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _shuffling ? null : () => _loadDiscovery(shuffle: true),
          icon: _shuffling
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child:
                      CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.shuffle, size: 18),
          label: const Text('Guncang untuk Temukan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primaryContainer),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusButton),
            ),
          ),
        ),
      ],
    );
  }

  Widget _principle(BuildContext context,
      {required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 