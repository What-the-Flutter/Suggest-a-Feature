// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';
import 'suggest_a_feature.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suggest a feature Example',
      home: Scaffold(
        body: SuggestionsPage(
          onGetUserById: (String id) => Future<SuggestionAuthor>(
            () => const SuggestionAuthor(id: '1', username: 'Author'),
          ),
          suggestionsDataSource: MySuggestionDataSource(userId: '1'),
          theme: SuggestionsTheme.initial(),
          userId: '1',
        ),
      ),
    );
  }
}

class MySuggestionDataSource implements SuggestionsDataSource {
  final SuggestionAuthor _suggestionAuthor = const SuggestionAuthor(id: '1', username: 'Author');
  Map<String, dynamic> suggestions = <String, Suggestion>{};
  Map<String, dynamic> comments = <String, Comment>{};

  MySuggestionDataSource({required this.userId});
  @override
  final String userId;

  @override
  Future<Suggestion> createSuggestion(CreateSuggestionModel suggestionModel) async {
    final Suggestion suggestion = Suggestion(
      id: _generateSuggestionId(),
      title: suggestionModel.title,
      description: suggestionModel.description,
      labels: suggestionModel.labels,
      images: suggestionModel.images,
      authorId: suggestionModel.authorId,
      isAnonymous: suggestionModel.isAnonymous,
      creationTime: DateTime.now(),
      status: suggestionModel.status,
    );
    suggestions[suggestion.id] = suggestion;
    return getSuggestionById(suggestion.id);
  }

  @override
  Future<Suggestion> getSuggestionById(String suggestionId) async {
    return suggestions[suggestionId];
  }

  @override
  Future<List<Suggestion>> getAllSuggestions() async {
    return suggestions.isNotEmpty ? suggestions.values.cast<Suggestion>().toList() : <Suggestion>[];
  }

  @override
  Future<Suggestion> updateSuggestion(Suggestion suggestion) async {
    suggestions[suggestion.id] = suggestion;
    return suggestions[suggestion.id];
  }

  @override
  Future<void> deleteSuggestionById(String suggestionId) async {
    suggestions.remove(suggestionId);
    return;
  }

  @override
  Future<Comment> createComment(CreateCommentModel commentModel) async {
    final Comment comment = Comment(
      id: _generateCommentId(),
      suggestionId: commentModel.suggestionId,
      author: _suggestionAuthor,
      isAnonymous: commentModel.isAnonymous,
      text: commentModel.text,
      creationTime: DateTime.now(),
    );
    comments[comment.id] = comment;
    return comment;
  }

  @override
  Future<List<Comment>> getAllComments(String suggestionId) async {
    return comments.isNotEmpty ? comments.values.cast<Comment>().toList() : <Comment>[];
  }

  @override
  Future<void> deleteCommentById(String commentId) async {
    comments.remove(commentId);
    return;
  }

  @override
  Future<void> addNotifyToUpdateUser(String suggestionId) async {
    final Set<String> modifiedSet = <String>{...suggestions[suggestionId]!.notifyUserIds, userId};
    suggestions[suggestionId] = suggestions[suggestionId]!.copyWith(
      notifyUserIds: modifiedSet,
    );
    return;
  }

  @override
  Future<void> deleteNotifyToUpdateUser(String suggestionId) async {
    final Set<String> modifiedSet = <String>{
      ...suggestions[suggestionId]!.notifyUserIds..remove(userId)
    };
    suggestions[suggestionId] = suggestions[suggestionId]!.copyWith(
      notifyUserIds: modifiedSet,
    );
    return;
  }

  @override
  Future<void> upvote(String suggestionId) async {
    final Set<String> modifiedSet = <String>{...suggestions[suggestionId]!.votedUserIds, userId};
    suggestions[suggestionId] = suggestions[suggestionId]!.copyWith(
      votedUserIds: modifiedSet,
    );
    return;
  }

  @override
  Future<void> downvote(String suggestionId) async {
    final Set<String> modifiedSet = <String>{
      ...suggestions[suggestionId]!.votedUserIds..remove(userId)
    };
    suggestions[suggestionId] = suggestions[suggestionId]!.copyWith(
      votedUserIds: modifiedSet,
    );
    return;
  }

  String _generateCommentId() {
    if (comments.isEmpty) {
      return '1';
    } else {
      final Comment lastAddedComment = comments.values.last;
      int lastId = int.parse(lastAddedComment.id);
      ++lastId;
      return lastId.toString();
    }
  }

  String _generateSuggestionId() {
    if (suggestions.isEmpty) {
      return '1';
    } else {
      final Suggestion lastAddedSuggestion = suggestions.values.last;
      int lastId = int.parse(lastAddedSuggestion.id);
      ++lastId;
      return lastId.toString();
    }
  }
}
