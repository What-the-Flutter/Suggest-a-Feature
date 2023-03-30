import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suggest_a_feature/src/domain/entities/suggestion.dart';
import 'package:suggest_a_feature/src/domain/interactors/suggestion_interactor.dart';
import 'package:suggest_a_feature/src/presentation/di/injector.dart'
    as injector;
import 'package:suggest_a_feature/src/presentation/pages/suggestions/suggestions_state.dart';

class SuggestionsCubit extends Cubit<SuggestionsState> {
  final SuggestionInteractor _suggestionInteractor;
  StreamSubscription<List<Suggestion>>? _suggestionSubscription;

  SuggestionsCubit(this._suggestionInteractor)
      : super(
          const SuggestionsState(
            requests: <Suggestion>[],
            inProgress: <Suggestion>[],
            completed: <Suggestion>[],
            isCreateBottomSheetOpened: false,
          ),
        );

  void init() {
    _suggestionSubscription?.cancel();
    _suggestionSubscription = _suggestionInteractor.suggestionsStream.listen(
      _onNewSuggestions,
    );
    _suggestionInteractor.initSuggestions();
  }

  void dispose() {
    _suggestionSubscription?.cancel();
    _suggestionSubscription = null;
  }

  Future<void> _onNewSuggestions(List<Suggestion> suggestions) async {
    suggestions.sort((a, b) => b.upvotesCount.compareTo(a.upvotesCount));

    emit(
      state.newState(
        requests: suggestions
            .where((s) => s.status == SuggestionStatus.requests)
            .toList(growable: false),
        inProgress: suggestions
            .where((s) => s.status == SuggestionStatus.inProgress)
            .toList(growable: false),
        completed: suggestions
            .where((s) => s.status == SuggestionStatus.completed)
            .toList(growable: false),
      ),
    );
  }

  void vote(SuggestionStatus status, int i) {
    switch (status) {
      case SuggestionStatus.requests:
        _voteForSuggestion(state.requests[i]);
        break;
      case SuggestionStatus.inProgress:
        _voteForSuggestion(state.inProgress[i]);
        break;
      case SuggestionStatus.completed:
        _voteForSuggestion(state.completed[i]);
        break;
      case SuggestionStatus.unknown:
      case SuggestionStatus.duplicate:
      case SuggestionStatus.cancelled:
        break;
    }
  }

  void _voteForSuggestion(Suggestion suggestion) {
    final isVoted = suggestion.votedUserIds.contains(injector.i.userId);

    isVoted
        ? _suggestionInteractor.downvote(suggestion.id)
        : _suggestionInteractor.upvote(suggestion.id);
  }

  void openCreateBottomSheet() =>
      emit(state.newState(isCreateBottomSheetOpened: true));

  void closeCreateBottomSheet() =>
      emit(state.newState(isCreateBottomSheetOpened: false));

  void changeActiveTab(SuggestionStatus activeTab) =>
      emit(state.newState(activeTab: activeTab));
}
