import 'package:flutter/material.dart';
import 'package:suggest_a_feature/src/domain/entities/suggestion.dart';
import 'package:suggest_a_feature/src/presentation/pages/theme/suggestions_theme.dart';
import 'package:suggest_a_feature/src/presentation/utils/dimensions.dart';
import 'package:suggest_a_feature/src/presentation/utils/label_utils.dart';

class SuggestionLabels extends StatelessWidget {
  final List<SuggestionLabel> labels;

  const SuggestionLabels({
    required this.labels,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimensions.marginBig,
      runSpacing: Dimensions.marginMiddle,
      children: labels
          .where((SuggestionLabel label) => label != SuggestionLabel.unknown)
          .map((SuggestionLabel label) => _label(label, context))
          .toList(),
    );
  }

  Widget _label(SuggestionLabel label, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: Dimensions.microSize,
          height: Dimensions.microSize,
          decoration: BoxDecoration(
            color: label.labelColor(),
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: label.labelColor().withOpacity(0.16),
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Text(
          label.labelName(context),
          style: theme.textSmallPlusBold.copyWith(
            color: label.labelColor(),
          ),
        ),
      ],
    );
  }
}
