import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/data/repo/explore_repository.dart';

part 'explore_event.dart';
part 'explore_state.dart';

/// ExploreBloc = ViewModel for Explore screen
/// Handles: category filtering + search query together
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ExploreRepository _exploreRepository;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  ExploreBloc({ExploreRepository? exploreRepository})
      : _exploreRepository = exploreRepository ?? ExploreRepository(),
        super(ExploreInitial()) {
    on<ExploreItemsRequested>(_onItemsRequested);
    on<ExploreCategoryChanged>(_onCategoryChanged);
    on<ExploreSearchChanged>(_onSearchChanged);
  }

  Future<void> _onItemsRequested(
    ExploreItemsRequested event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreLoading());
    final category = event.category == 'All' ? null : event.category?.toLowerCase();
    final items = await _exploreRepository.getExplore(
      category: category,
      search: event.search?.isNotEmpty == true ? event.search : null,
    );
    emit(ExploreLoaded(
      items: items,
      selectedCategory: event.category ?? 'All',
      searchQuery: event.search ?? '',
    ));
  }

  Future<void> _onCategoryChanged(
    ExploreCategoryChanged event,
    Emitter<ExploreState> emit,
  ) async {
    _selectedCategory = event.category;
    emit(ExploreLoading());
    final category = _selectedCategory == 'All' ? null : _selectedCategory.toLowerCase();
    final items = await _exploreRepository.getExplore(
      category: category,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
    emit(ExploreLoaded(
      items: items,
      selectedCategory: _selectedCategory,
      searchQuery: _searchQuery,
    ));
  }

  Future<void> _onSearchChanged(
    ExploreSearchChanged event,
    Emitter<ExploreState> emit,
  ) async {
    _searchQuery = event.query;
    emit(ExploreLoading());
    final category = _selectedCategory == 'All' ? null : _selectedCategory.toLowerCase();
    final items = await _exploreRepository.getExplore(
      category: category,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
    emit(ExploreLoaded(
      items: items,
      selectedCategory: _selectedCategory,
      searchQuery: _searchQuery,
    ));
  }
}
