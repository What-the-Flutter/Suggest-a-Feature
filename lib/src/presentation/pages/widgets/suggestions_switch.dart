import 'package:flutter/cupertino.dart';
import 'package:suggest_a_feature/src/presentation/pages/theme/theme_extension.dart';

class SuggestionsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SuggestionsSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      activeColor: context.theme.colorScheme.primary,
      trackColor: context.theme.colorScheme.background,
      thumbColor: value
          ? context.theme.colorScheme.onPrimary
          : context.theme.dividerColor,
      onChanged: onChanged,
    );
  }
}
