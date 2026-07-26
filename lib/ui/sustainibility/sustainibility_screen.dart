
import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
 
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
class SustainabilityScreen extends StatelessWidget {
  const SustainabilityScreen({super.key});
 
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
                    'Kami belum menampilkan skor dampak personal atau sertifikat per-user — '
                    'fitur itu butuh sistem tracking yang belum kami bangun. Halaman ini akan '
                    'diperbarui begitu ada cara jujur untuk mengukurnya.',
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
 