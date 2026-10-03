import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/repo/explore_repository.dart';
import 'package:sasacation/viewmodel/explore/explore_bloc.dart';

/// View: FilterChips
/// Dispatches ExploreCategoryChanged to ExploreBloc directly.
/// No callback needed — BLoC handles state.
///
/// F16: daftar chip mengikuti kategori backend yang `available: true`
/// (dari isi DB). 'Destinations' dipertahankan sebagai pseudo-kategori
/// (terverifikasi mengembalikan item via `category=destinations`).
/// Bila daftar backend tak termuat (offline), fallback ke daftar lokal
/// agar layar tetap berfungsi seperti semula.
class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  static const List<String> fallbackCategories = [
    'All', 'Hotels', 'Destinations', 'Culinary', 'Beaches', 'Islands', 'Adventure', 'Culture'
  ];

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  List<String>? _categories;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available =
        await ExploreRepository().getAvailableCategoryLabels();
    if (!mounted) return;
    setState(() {
      // 'All' selalu ada; 'Destinations' pseudo-kategori yang didukung.
      _categories = [
        'All',
        for (final c in FilterChips.fallbackCategories.skip(1))
          if (c == 'Destinations' || available.isEmpty || available.contains(c))
            c,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories ?? FilterChips.fallbackCategories;
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        final selected = state is ExploreLoaded
            ? state.selectedCategory
            : 'All';

        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    // Dispatch event ke ExploreBloc (ViewModel)
                    context
                        .read<ExploreBloc>()
                        .add(ExploreCategoryChanged(category: cat));
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: AppTheme.primaryColor,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
