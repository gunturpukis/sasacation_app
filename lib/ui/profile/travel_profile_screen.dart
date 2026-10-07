import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/repo/preferences_repository.dart';

/// F.4 Travel Profile — lihat + edit preferensi travel.
/// Kontrak BE: GET /preferences/profile (alias camelCase + stats),
/// PUT /preferences (body camelCase). Fail-soft: profil null/kosong → mode
/// quiz (isi pertama kali), bukan error.
class TravelProfileScreen extends StatefulWidget {
  const TravelProfileScreen({super.key});

  @override
  State<TravelProfileScreen> createState() => _TravelProfileScreenState();
}

class _TravelProfileScreenState extends State<TravelProfileScreen> {
  final _repo = PreferencesRepository();
  final _locationCtrl = TextEditingController();
  final _interestCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  Map<String, dynamic>? _profile;

  String? _budgetTier;
  final Set<String> _tripTypes = {};
  final Set<String> _amenityPrefs = {};
  final Set<String> _locationPrefs = {};
  final Set<String> _styles = {};
  final Set<String> _interests = {};

  static const _tiers = ['budget', 'mid', 'comfort', 'luxury'];
  static const _tripOptions = [
    'couple', 'family', 'solo', 'friends', 'staycation', 'honeymoon', 'group', 'business'
  ];
  static const _amenityOptions = [
    'pool', 'bathtub', 'breakfast', 'wifi', 'gym', 'spa', 'beach', 'cafe', 'parking', 'restaurant'
  ];
  static const _styleOptions = [
    'relaxation', 'adventure', 'budget', 'gourmet', 'culture', 'nature', 'luxury'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<String> _strList(Map<String, dynamic>? m, String camel, String snake) {
    if (m == null) return [];
    final v = m[camel] ?? m[snake];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await _repo.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _budgetTier = p?['budgetTier']?.toString() ?? p?['budget_tier']?.toString();
      _tripTypes.addAll(_strList(p, 'tripTypes', 'trip_types'));
      _amenityPrefs.addAll(_strList(p, 'amenityPrefs', 'amenity_prefs'));
      _locationPrefs.addAll(_strList(p, 'locationPrefs', 'location_prefs'));
      _styles.addAll(_strList(p, 'travelStyles', 'styles'));
      _interests.addAll(_strList(p, 'interests', 'interests'));
      _loading = false;
    });
  }

  bool get _isEmpty =>
      _tripTypes.isEmpty && _amenityPrefs.isEmpty && _styles.isEmpty && _interests.isEmpty;

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await _repo.savePreferences({
      'budgetTier': _budgetTier,
      'tripTypes': _tripTypes.toList(),
      'amenityPrefs': _amenityPrefs.toList(),
      'locationPrefs': _locationPrefs.toList(),
      'styles': _styles.toList(),
      'interests': _interests.toList(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (isEn ? 'Travel profile saved' : 'Profil travel tersimpan')
            : (isEn ? 'Failed to save. Try again.' : 'Gagal menyimpan. Coba lagi.')),
      ),
    );
    if (ok) _load();
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _interestCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Travel Profile' : 'Profil Travel'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(
                    isEmpty: _isEmpty,
                    wishlistCount: _profile?['stats']?['wishlistCount'] as int?,
                    bookingCount: _profile?['stats']?['bookingCount'] as int?,
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: isEn ? 'Budget' : 'Budget perjalanan',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tiers.map((t) {
                        final sel = _budgetTier == t;
                        return ChoiceChip(
                          label: Text(_tierLabel(t, isEn)),
                          selected: sel,
                          onSelected: (_) => setState(() => _budgetTier = sel ? null : t),
                        );
                      }).toList(),
                    ),
                  ),
                  _Section(
                    title: isEn ? 'Trip types' : 'Tipe perjalanan',
                    child: _MultiChips(
                      options: _tripOptions,
                      selected: _tripTypes,
                      onToggle: (v) => setState(() => _tripTypes.contains(v)
                          ? _tripTypes.remove(v)
                          : _tripTypes.add(v)),
                    ),
                  ),
                  _Section(
                    title: isEn ? 'Favorite facilities' : 'Fasilitas favorit',
                    child: _MultiChips(
                      options: _amenityOptions,
                      selected: _amenityPrefs,
                      onToggle: (v) => setState(() => _amenityPrefs.contains(v)
                          ? _amenityPrefs.remove(v)
                          : _amenityPrefs.add(v)),
                    ),
                  ),
                  _Section(
                    title: isEn ? 'Favorite places' : 'Lokasi favorit',
                    child: _EditableChips(
                      values: _locationPrefs,
                      controller: _locationCtrl,
                      hint: isEn ? 'e.g. bali, beach' : 'mis. bali, pantai',
                      onAdd: (v) => setState(() => _locationPrefs.add(v)),
                      onRemove: (v) => setState(() => _locationPrefs.remove(v)),
                    ),
                  ),
                  _Section(
                    title: isEn ? 'Travel styles' : 'Gaya travel',
                    child: _MultiChips(
                      options: _styleOptions,
                      selected: _styles,
                      onToggle: (v) => setState(() => _styles.contains(v)
                          ? _styles.remove(v)
                          : _styles.add(v)),
                    ),
                  ),
                  _Section(
                    title: isEn ? 'Interests' : 'Minat',
                    child: _EditableChips(
                      values: _interests,
                      controller: _interestCtrl,
                      hint: isEn ? 'e.g. culinary, snorkeling' : 'mis. kuliner, snorkeling',
                      onAdd: (v) => setState(() => _interests.add(v)),
                      onRemove: (v) => setState(() => _interests.remove(v)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(isEn ? 'Save profile' : 'Simpan profil'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  String _tierLabel(String t, bool isEn) {
    const id = {'budget': 'Hemat', 'mid': 'Menengah', 'comfort': 'Nyaman', 'luxury': 'Mewah'};
    const en = {'budget': 'Budget', 'mid': 'Mid-range', 'comfort': 'Comfort', 'luxury': 'Luxury'};
    return (isEn ? en : id)[t] ?? t;
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isEmpty;
  final int? wishlistCount;
  final int? bookingCount;
  const _HeaderCard({required this.isEmpty, this.wishlistCount, this.bookingCount});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.person_pin_outlined, size: 28, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isEmpty
                  ? (isEn
                      ? 'Tell us your travel style — recommendations get smarter.'
                      : 'Ceritakan gaya jalan-jalanmu — rekomendasi jadi lebih pintar.')
                  : (isEn
                      ? 'Recommendations are personalized for you.'
                      : 'Rekomendasi dipersonalisasi untuk kamu.'),
              style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor),
            ),
            if (!isEmpty && (wishlistCount != null || bookingCount != null)) ...[
              const SizedBox(height: 4),
              Text(
                isEn
                    ? '$wishlistCount wishlist · $bookingCount bookings learned'
                    : '$wishlistCount wishlist · $bookingCount booking dipelajari',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

class _MultiChips extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final void Function(String) onToggle;
  const _MultiChips({required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final sel = selected.contains(o);
        return FilterChip(label: Text(o), selected: sel, onSelected: (_) => onToggle(o));
      }).toList(),
    );
  }
}

class _EditableChips extends StatelessWidget {
  final Set<String> values;
  final TextEditingController controller;
  final String hint;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  const _EditableChips({
    required this.values,
    required this.controller,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (values.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map((v) => InputChip(label: Text(v), onDeleted: () => onRemove(v)))
                .toList(),
          ),
        ),
      Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint, isDense: true),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(onPressed: _submit, icon: const Icon(Icons.add)),
      ]),
    ]);
  }

  void _submit() {
    final v = controller.text.trim().toLowerCase();
    if (v.isEmpty) return;
    onAdd(v);
    controller.clear();
  }
}
