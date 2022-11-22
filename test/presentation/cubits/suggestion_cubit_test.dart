import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:suggest_a_feature/src/presentation/di/injector.dart';
import 'package:suggest_a_feature/src/presentation/pages/suggestion/suggestion_cubit.dart';
import 'package:suggest_a_feature/src/presentation/pages/suggestion/suggestion_state.dart';
import 'package:suggest_a_feature/src/presentation/utils/image_utils.dart';
import 'package:suggest_a_feature/suggest_a_feature.dart';

import '../../utils/mocked_entities.dart';
import '../../utils/shared_mocks.mocks.dart';

void main() {
  group(
    'suggestion cubit',
    () {
      final mockSuggestionInteractor = MockSuggestionInteractor();
      final mockSuggestionsTheme = MockSuggestionsTheme();
      final mockSuggestionsDataSource = MockSuggestionsDataSource();

      final emptySuggestionState = SuggestionState(
        isPopped: false,
        isEditable: false,
        author: const SuggestionAuthor.empty(),
        savingImageResultMessageType: SavingResultMessageType.none,
        bottomSheetType: SuggestionBottomSheetType.none,
        suggestion: mockedSuggestion,
      );

      final commentedSuggestion = mockedSuggestion.copyWith(comments: [mockedComment]);

      setUp(() {
        i.init(
            theme: mockSuggestionsTheme,
            userId: '1',
            suggestionsDataSource: mockSuggestionsDataSource);
      });

      blocTest<SuggestionCubit, SuggestionState>(
        'create comment',
        build: () {
          when(mockSuggestionInteractor.createComment(mockedCreateCommentModel))
              .thenAnswer((_) async => Wrapper(data: mockedComment, status: 200));
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => emptySuggestionState,
        act: (cubit) => cubit.createComment(
          'Comment1',
          true,
          (id) async => mockedSuggestionAuthor,
        ),
        expect: () => [
          SuggestionState(
            isPopped: false,
            isEditable: false,
            author: const SuggestionAuthor.empty(),
            savingImageResultMessageType: SavingResultMessageType.none,
            bottomSheetType: SuggestionBottomSheetType.none,
            suggestion: commentedSuggestion,
          ),
        ],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'delete suggestion',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => emptySuggestionState,
        act: (cubit) => cubit.deleteSuggestion(),
        expect: () => [
          SuggestionState(
            isPopped: true,
            isEditable: false,
            author: const SuggestionAuthor.empty(),
            savingImageResultMessageType: SavingResultMessageType.none,
            bottomSheetType: SuggestionBottomSheetType.none,
            suggestion: mockedSuggestion,
          ),
        ],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'upvote',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => emptySuggestionState,
        act: (cubit) => cubit.vote(),
        expect: () => [
          SuggestionState(
            isPopped: false,
            isEditable: false,
            author: const SuggestionAuthor.empty(),
            savingImageResultMessageType: SavingResultMessageType.none,
            bottomSheetType: SuggestionBottomSheetType.none,
            suggestion: mockedSuggestion.copyWith(
              isVoted: true,
              upvotesCount: 1,
            ),
          ),
        ],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'downvote',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => SuggestionState(
          isPopped: false,
          isEditable: false,
          author: const SuggestionAuthor.empty(),
          savingImageResultMessageType: SavingResultMessageType.none,
          bottomSheetType: SuggestionBottomSheetType.none,
          suggestion: mockedSuggestion.copyWith(
            isVoted: true,
            upvotesCount: 1,
          ),
        ),
        act: (cubit) => cubit.vote(),
        expect: () => [emptySuggestionState],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'add notification',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => emptySuggestionState,
        act: (cubit) => cubit.changeNotification(true),
        expect: () => [
          SuggestionState(
            isPopped: false,
            isEditable: false,
            author: const SuggestionAuthor.empty(),
            savingImageResultMessageType: SavingResultMessageType.none,
            bottomSheetType: SuggestionBottomSheetType.none,
            suggestion: mockedSuggestion.copyWith(
              shouldNotifyAfterCompleted: true,
            ),
          ),
        ],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'delete notification',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => SuggestionState(
          isPopped: false,
          isEditable: false,
          author: const SuggestionAuthor.empty(),
          savingImageResultMessageType: SavingResultMessageType.none,
          bottomSheetType: SuggestionBottomSheetType.none,
          suggestion: mockedSuggestion.copyWith(
            shouldNotifyAfterCompleted: true,
          ),
        ),
        act: (cubit) => cubit.changeNotification(false),
        expect: () => [emptySuggestionState],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'show successful result message',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => emptySuggestionState,
        act: (cubit) => cubit.showSavingResultMessage(Future.value(true)),
        expect: () => [
          SuggestionState(
            isPopped: false,
            isEditable: false,
            author: const SuggestionAuthor.empty(),
            savingImageResultMessageType: SavingResultMessageType.success,
            bottomSheetType: SuggestionBottomSheetType.none,
            suggestion: mockedSuggestion,
          ),
        ],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'show failed result message',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => emptySuggestionState,
        act: (cubit) => cubit.showSavingResultMessage(Future.value(false)),
        expect: () => [
          SuggestionState(
            isPopped: false,
            isEditable: false,
            author: const SuggestionAuthor.empty(),
            savingImageResultMessageType: SavingResultMessageType.fail,
            bottomSheetType: SuggestionBottomSheetType.none,
            suggestion: mockedSuggestion,
          ),
        ],
      );

      blocTest<SuggestionCubit, SuggestionState>(
        'open Bottom Sheet',
        build: () {
          return SuggestionCubit(
            mockSuggestionInteractor,
          );
        },
        seed: () => emptySuggestionState,
        act: (cubit) => cubit.openCreateCommentBottomSheet(),
        expect: () => [
          SuggestionState(
            isPopped: false,
            isEditable: false,
            author: const SuggestionAuthor.empty(),
            savingImageResultMessageType: SavingResultMessageType.none,
            bottomSheetType: SuggestionBottomSheetType.createComment,
            suggestion: mockedSuggestion,
          ),
        ],
      );
    },
  );
}
