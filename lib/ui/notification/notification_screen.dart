import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/notification_model.dart';
import 'package:sasacation/data/repo/notification_repository.dart';
import 'package:sasacation/route/approuter.dart';
 
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
  String _filter = 'Semua';

  /// Kategori mengikuti desain (All/Budget/Weather/Travel) tapi dipetakan ke
  /// tipe nyata yang dikirim backend — tanpa mengarang kategori kosong.
  String _categoryFor(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    if (type.startsWith('payment')) return l10n.me_categoryPayment;
    if (type.startsWith('booking')) return l10n.me_categoryBooking;
    return l10n.me_categoryInfo;
  }
 
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
    if (type.startsWith('payment')) return Icons.payments_outlined;
    if (type == 'booking_cancelled') return Icons.cancel_outlined;
    if (type.startsWith('booking')) return Icons.confirmation_number_outlined;
    return Icons.notifications_outlined;
  }
 
  String _timeAgo(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.me_justNow;
    if (diff.inMinutes < 60) return l10n.me_minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.me_hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.me_daysAgo(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
 
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(l10n.me_notificationsTitle), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 72, color: AppTheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text(l10n.me_emptyTitle, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(l10n.me_emptySubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : _buildFilteredBody(),
    );
  }

  /// Body dengan filter chips + pengelompokan waktu mengikuti desain.
  /// Semua dihitung dari data nyata (client-side, tanpa backend baru).
  Widget _buildFilteredBody() {
    final l10n = AppLocalizations.of(context);
    final allLabel = l10n.me_filterAll;
    final categories = <String>[
      allLabel,
      ...{for (final n in _notifications) _categoryFor(context, n.type)},
    ];
    if (_filter == 'Semua' || !categories.contains(_filter)) _filter = allLabel;
    final filtered = _filter == allLabel
        ? _notifications
        : _notifications.where((n) => _categoryFor(context, n.type) == _filter).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_list_off, size: 56, color: AppTheme.outlineVariant),
            const SizedBox(height: 12),
            Text(l10n.me_emptyFilter(_filter),
                style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
    }

    final now = DateTime.now();
    bool isToday(DateTime dt) =>
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final today = filtered.where((n) => isToday(n.createdAt)).toList();
    final week = filtered
        .where((n) => !isToday(n.createdAt) && now.difference(n.createdAt).inDays < 7)
        .toList();
    final older = filtered
        .where((n) => !isToday(n.createdAt) && now.difference(n.createdAt).inDays >= 7)
        .toList();

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final selected = cat == _filter;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) => setState(() => _filter = cat),
                selectedColor: AppTheme.primaryContainer,
                backgroundColor: AppTheme.surfaceContainerLowest,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  side: BorderSide(
                    color: selected
                        ? AppTheme.primaryContainer
                        : AppTheme.outlineVariant,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                if (today.isNotEmpty) ...[
                  _groupHeader(l10n.me_groupToday),
                  ...today.map(_buildCard),
                ],
                if (week.isNotEmpty) ...[
                  _groupHeader(l10n.me_groupWeek),
                  ...week.map(_buildCard),
                ],
                if (older.isNotEmpty) ...[
                  _groupHeader(l10n.me_groupOlder),
                  ...older.map(_buildCard),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _groupHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppTheme.outline)),
    );
  }

  /// Tombol aksi notifikasi (F7+): petakan `data.action`
  /// ({label, route, params}) dari backend ke route aplikasi.
  /// Hanya route yang punya layar tujuan yang dirender — sisanya (mis.
  /// payment_methods, group_detail, task_detail sebelum UI-nya ada) TIDAK
  /// menampilkan tombol alih-alih navigasi buntu.
  ({String label, String path})? _actionFor(BuildContext context, NotificationModel n) {
    final l10n = AppLocalizations.of(context);
    final data = n.data;
    final rawAction = data['action'];
    String? route;
    Map<String, dynamic> params = {};
    String? label;
    if (rawAction is Map) {
      route = rawAction['route']?.toString();
      label = rawAction['label']?.toString();
      final p = rawAction['params'];
      if (p is Map) params = Map<String, dynamic>.from(p);
    }
    String? param(String a, String b) =>
        (params[a] ?? params[b] ?? data[a] ?? data[b])?.toString();

    final pollId = param('pollId', 'poll_id');
    if ((route == 'poll_detail' || (route == null && pollId != null)) &&
        pollId != null) {
      return (label: label ?? l10n.me_actionVoteNow, path: AppRouter.pollDetailPath(pollId));
    }
    final hotelId = param('hotelId', 'hotel_id');
    if (route == 'hotel_detail' && hotelId != null) {
      return (label: label ?? l10n.me_actionViewHotel, path: AppRouter.hotelDetailPath(hotelId));
    }
    if (route == 'booking_detail') {
      return (label: label ?? l10n.me_actionViewBooking, path: AppRouter.myBookings);
    }
    final tripId = param('itineraryId', 'itinerary_id');
    if (route == 'itinerary_detail' && tripId != null) {
      return (label: label ?? l10n.me_actionViewItinerary, path: AppRouter.tripDetailPath(tripId));
    }
    final groupId = param('groupId', 'group_id');
    if (route == 'group_detail' && groupId != null) {
      return (label: label ?? l10n.me_actionViewGroup, path: AppRouter.groupDetailPath(groupId));
    }
    if (route == 'impact_summary') {
      return (label: label ?? l10n.me_actionViewImpact, path: AppRouter.sustainability);
    }
    if (route == 'wallet') {
      return (label: label ?? l10n.me_actionViewWallet, path: AppRouter.paymentHistory);
    }
    if (route == 'task_detail') {
      // Tanpa layar detail per-task — arahkan ke daftar tasks.
      return (label: label ?? l10n.me_actionViewTasks, path: AppRouter.tasks);
    }
    return null;
  }

  Widget _buildCard(NotificationModel n) {
    final index = _notifications.indexOf(n);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (!n.isRead && index != -1) {
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                              style: TextStyle(
                                  fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                                  fontSize: 14)),
                        ),
                        const SizedBox(width: 8),
                        Text(_categoryFor(context, n.type),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(_timeAgo(context, n.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
                    // Tombol aksi backend (F7+): hanya bila route terpetakan.
                    if (_actionFor(context, n) case (label: final label, path: final path))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.push(path),
                            child: Text(label),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!n.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 4),
                  decoration: const BoxDecoration(
                      color: AppTheme.secondaryContainer, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}