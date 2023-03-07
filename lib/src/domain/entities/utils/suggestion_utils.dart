import 'package:flutter/foundation.dart';
import 'package:suggest_a_feature/src/domain/entities/suggestion.dart';

extension LabelExt on SuggestionLabel {
  String get value => describeEnum(this);

  static SuggestionLabel labelType(String? type) {
    switch (type) {
      case 'feature':
        return SuggestionLabel.feature;
      case 'bug':
        return SuggestionLabel.bug;
      default:
        return SuggestionLabel.unknown;
    }
  }
}
