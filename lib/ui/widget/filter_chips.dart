import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/viewmodel/explore/explore_bloc.dart';

/// View: FilterChips
/// Dispatches ExploreCategoryChanged to ExploreBloc directly.
/// No callback needed — BLoC handles state.
class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  static const List<String> categories = [
    'All', 'Hotels', 'Destinations', 'Culinary', 'Beaches', 'Islands', 'Adventure', 'Culture'
  ];

  @override
  Widget build(BuildContext context) {
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
