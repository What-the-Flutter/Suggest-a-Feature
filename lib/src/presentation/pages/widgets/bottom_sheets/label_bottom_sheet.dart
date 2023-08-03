import 'package:flutter/material.dart';
import 'package:suggest_a_feature/src/domain/entities/suggestion.dart';
import 'package:suggest_a_feature/src/presentation/pages/theme/suggestions_theme.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/bottom_sheets/bottom_sheet_actions.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/clickable_list_item.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/suggestions_labels.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/suggestions_radio_button.dart';
import 'package:suggest_a_feature/src/presentation/utils/context_utils.dart';
import 'package:suggest_a_feature/src/presentation/utils/dimensions.dart';
import 'package:wtf_sliding_sheet/wtf_sliding_sheet.dart';

class LabelBottomSheet extends StatefulWidget {
  final VoidCallback onCancel;
  final SheetController controller;
  final ValueChanged<List<SuggestionLabel>> onDone;
  final List<SuggestionLabel> selectedLabels;

  const LabelBottomSheet({
    required this.onCancel,
    required this.onDone,
    required this.controller,
    required this.selectedLabels,
    super.key,
  });

  @override
  State<LabelBottomSheet> createState() => _LabelBottomSheetState();
}

class _LabelBottomSheetState extends State<LabelBottomSheet> {
  final List<SuggestionLabel> selectedLabels = <SuggestionLabel>[];

  @override
  void initState() {
    super.initState();
    selectedLabels.addAll(widget.selectedLabels);
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: context.localization.labels,
      titleBottomPadding: 0,
      controller: widget.controller,
      previousNavBarColor: theme.bottomSheetBackgroundColor,
      previousStatusBarColor: theme.thirdBackgroundColor,
      onClose: ([ClosureType? closureType]) async {
        if (closureType == ClosureType.backButton) {
          widget.onCancel();
        } else {
          await widget.controller.collapse();
          widget.onCancel();
        }
      },
      backgroundColor: theme.bottomSheetBackgroundColor,
      contentBuilder: (_, __) {
        return _LabelsListView(
          onTap: (label) => setState(
            () => selectedLabels.contains(label)
                ? selectedLabels.remove(label)
                : selectedLabels.add(label),
          ),
          onCancel: widget.onCancel,
          onDone: widget.onDone,
          selectedLabels: selectedLabels,
        );
      },
    );
  }
}

class _LabelsListView extends StatelessWidget {
  final ValueChanged<SuggestionLabel> onTap;
  final List<SuggestionLabel> selectedLabels;
  final VoidCallback onCancel;
  final ValueChanged<List<SuggestionLabel>> onDone;

  const _LabelsListView({
    required this.onTap,
    required this.selectedLabels,
    required this.onCancel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: Dimensions.marginMiddle),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: _LabelsRow(selectedLabels: selectedLabels, onTap: onTap),
        ),
        BottomSheetActions(
          onCancel: onCancel,
          onDone: () => onDone(selectedLabels),
        ),
      ],
    );
  }
}

class _LabelsRow extends StatelessWidget {
  final List<SuggestionLabel> selectedLabels;
  final ValueChanged<SuggestionLabel> onTap;

  const _LabelsRow({
    required this.onTap,
    required this.selectedLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.marginMiddle),
      child: Column(
        children: <Widget>[
          ClickableListItem(
            title: const SuggestionLabels(labels: [SuggestionLabel.feature]),
            trailing: SuggestionsRadioButton(
              selected: selectedLabels.contains(SuggestionLabel.feature),
            ),
            onClick: () => onTap(SuggestionLabel.feature),
            verticalPadding: Dimensions.marginMiddle,
          ),
          ClickableListItem(
            title: const SuggestionLabels(labels: [SuggestionLabel.bug]),
            trailing: SuggestionsRadioButton(
              selected: selectedLabels.contains(SuggestionLabel.bug),
            ),
            onClick: () => onTap(SuggestionLabel.bug),
            verticalPadding: Dimensions.marginMiddle,
          ),
        ],
      ),
    );
  }
}
