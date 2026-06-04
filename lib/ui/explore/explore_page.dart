import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/ui/widget/explore_grid.dart';
import 'package:sasacation/ui/widget/filter_chips.dart';
import 'package:sasacation/ui/widget/search_bar.dart';
import 'package:sasacation/viewmodel/explore/explore_bloc.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // FIX: hanya load jika state masih initial (tidak reset filter saat tab switch)
    final state = context.read<ExploreBloc>().state;
    if (state is ExploreInitial) {
      context.read<ExploreBloc>().add(ExploreItemsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            title: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                final category = state is ExploreLoaded
                    ? (state.selectedCategory == 'All' ? 'Explore Lombok' : state.selectedCategory)
                    : 'Explore Lombok';
                return Text(category,
                    style: const TextStyle(fontWeight: FontWeight.bold));
              },
            ),
            actions: [
              BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  // Tampilkan tombol reset filter jika ada filter aktif
                  final hasFilter = state is ExploreLoaded &&
                      (state.selectedCategory != 'All' || state.searchQuery.isNotEmpty);
                  if (!hasFilter) return const SizedBox.shrink();
                  return TextButton.icon(
                    onPressed: () =>
                        context.read<ExploreBloc>().add(ExploreItemsRequested()),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset', style: TextStyle(fontSize: 13)),
                  );
                },
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(108),
              child: Column(
                children: [
                  CustomSearchBar(),
                  SizedBox(height: 12),
                  FilterChips(),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Result count
          SliverToBoxAdapter(
            child: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                if (state is ExploreLoaded) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${state.items.length} tempat ditemukan',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                        if (state.searchQuery.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('"${state.searchQuery}"',
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
            sliver: SliverToBoxAdapter(child: ExploreGrid()),
          ),
        ],
      ),
    );
  }
}
