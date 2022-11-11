import '../../../domain/entities/suggestion.dart';
import '../../../domain/entities/suggestion_author.dart';
import '../../utils/image_utils.dart';

class SuggestionState {
  final bool isPopped;
  final bool isEditable;
  final SuggestionAuthor author;
  final Suggestion suggestion;
  final SavingResultMessageType savingImageResultMessageType;
  final SuggestionBottomSheetType bottomSheetType;

  SuggestionState({
    required this.isPopped,
    required this.isEditable,
    required this.author,
    required this.suggestion,
    required this.savingImageResultMessageType,
    required this.bottomSheetType,
  });

  SuggestionState newState({
    bool? isPopped,
    bool? isEditable,
    SuggestionAuthor? author,
    Suggestion? suggestion,
    SavingResultMessageType? savingImageResultMessageType,
    SuggestionBottomSheetType? bottomSheetType,
  }) {
    return SuggestionState(
      isPopped: isPopped ?? this.isPopped,
      isEditable: isEditable ?? this.isEditable,
      author: author ?? this.author,
      suggestion: suggestion ?? this.suggestion,
      bottomSheetType: bottomSheetType ?? this.bottomSheetType,
      savingImageResultMessageType:
          savingImageResultMessageType ?? this.savingImageResultMessageType,
    );
  }
}

enum SuggestionBottomSheetType {
  none,
  confirmation,
  notification,
  editDelete,
  createEdit,
  createComment,
}
