part of 'explore_bloc.dart';

abstract class ExploreState {}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<ExploreItemModel> items;
  final String selectedCategory;
  final String searchQuery;

  ExploreLoaded({
    required this.items,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });
}

class ExploreError extends ExploreState {
  final String message;
  ExploreError({required this.message});
}
