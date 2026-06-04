part of 'explore_bloc.dart';

abstract class ExploreEvent {}

class ExploreItemsRequested extends ExploreEvent {
  final String? category;
  final String? search;
  ExploreItemsRequested({this.category, this.search});
}

class ExploreCategoryChanged extends ExploreEvent {
  final String category;
  ExploreCategoryChanged({required this.category});
}

class ExploreSearchChanged extends ExploreEvent {
  final String query;
  ExploreSearchChanged({required this.query});
}
