import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/notification_model.dart';
import 'package:sasacation/data/repo/notification_repository.dart';
 
/// NotificationsScreen — layar baru, sebelumnya TIDAK ADA sama sekali di
/// app (cuma ada service push token registration, tanpa in-app history).
///
/// Sekarang datanya REAL dari tabel `notifications` (lihat
/// migrateNotifications.js) — terisi otomatis setiap kali sistem mengirim
/// notifikasi nyata (saat ini baru 1 titik pemicu: konfirmasi pembayaran
/// sukses saat checkout). Bukan data mockup/hardcode.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
 
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}
 
class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _loading = true;
 
  @override
  void initState() {
    super.initState();
    _load();
  }
 
  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _repo.getNotifications();
    setState(() {
      _notifications = result['notifications'] as List<NotificationModel>;
      _loading = false;
    });
  }
 
  IconData _iconFor(String type) {
    switch (type) {
      case 'payment_success':
        return Icons.payments_outlined;
      case 'booking_cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
 
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 72, color: AppTheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text('Belum ada notifikasi', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text('Notifikasi tentang booking & pembayaranmu akan muncul di sini',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return GestureDetector(
                        onTap: () {
                          if (!n.isRead) {
                            _repo.markAsRead(n.id);
                            setState(() {
                              _notifications[index] = NotificationModel(
                                id: n.id,
                                title: n.title,
                                body: n.body,
                                type: n.type,
                                data: n.data,
                                readAt: DateTime.now(),
                                createdAt: n.createdAt,
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead ? AppTheme.surfaceContainerLowest : AppTheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: Icon(_iconFor(n.type), size: 20, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title,
                                        style: TextStyle(
                                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                                            fontSize: 14)),
                                    const SizedBox(height: 3),
                                    Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                                    const SizedBox(height: 6),
                                    Text(_timeAgo(n.createdAt),
                                        style: TextStyle(fontSize: 11, color: AppTheme.outline)),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: const BoxDecoration(
                                      color: AppTheme.secondaryContainer, shape: BoxShape.circle),
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