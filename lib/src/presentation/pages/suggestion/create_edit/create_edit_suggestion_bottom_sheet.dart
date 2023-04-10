import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:suggest_a_feature/src/domain/entities/suggestion.dart';
import 'package:suggest_a_feature/src/presentation/di/injector.dart';
import 'package:suggest_a_feature/src/presentation/pages/suggestion/create_edit/create_edit_suggestion_cubit.dart';
import 'package:suggest_a_feature/src/presentation/pages/suggestion/create_edit/create_edit_suggestion_state.dart';
import 'package:suggest_a_feature/src/presentation/pages/theme/suggestions_theme.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/add_event_photo_button.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/bottom_sheets/label_bottom_sheet.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/bottom_sheets/status_bottom_sheet.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/clickable_list_item.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/network_image.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/photo_view.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/small_photo_preview.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/suggestions_elevated_button.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/suggestions_labels.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/suggestions_switch.dart';
import 'package:suggest_a_feature/src/presentation/pages/widgets/suggestions_text_field.dart';
import 'package:suggest_a_feature/src/presentation/utils/assets_strings.dart';
import 'package:suggest_a_feature/src/presentation/utils/constants/numeric_constants.dart';
import 'package:suggest_a_feature/src/presentation/utils/context_utils.dart';
import 'package:suggest_a_feature/src/presentation/utils/dimensions.dart';
import 'package:suggest_a_feature/src/presentation/utils/image_utils.dart';
import 'package:suggest_a_feature/src/presentation/utils/typedefs.dart';
import 'package:wtf_sliding_sheet/wtf_sliding_sheet.dart';

class CreateEditSuggestionBottomSheet extends StatefulWidget {
  final Suggestion? suggestion;
  final VoidCallback onClose;
  final SheetController controller;
  final OnUploadMultiplePhotosCallback? onUploadMultiplePhotos;
  final OnSaveToGalleryCallback? onSaveToGallery;

  const CreateEditSuggestionBottomSheet({
    required this.onClose,
    required this.controller,
    required this.onUploadMultiplePhotos,
    required this.onSaveToGallery,
    this.suggestion,
    super.key,
  });

  @override
  CreateEditSuggestionBottomSheetState createState() =>
      CreateEditSuggestionBottomSheetState();
}

class CreateEditSuggestionBottomSheetState
    extends State<CreateEditSuggestionBottomSheet>
    with TickerProviderStateMixin {
  final CreateEditSuggestionCubit _cubit = i.createEditSuggestionCubit;
  final SheetController _labelsSheetController = SheetController();
  final SheetController _statusesSheetController = SheetController();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;

  @override
  void initState() {
    super.initState();
    _cubit.init(widget.suggestion);
    _titleController = TextEditingController(text: widget.suggestion?.title);
    _descriptionController =
        TextEditingController(text: widget.suggestion?.description);
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  bool _listenWhen(
    CreateEditSuggestionState previous,
    CreateEditSuggestionState current,
  ) {
    return (previous.savingImageResultMessageType ==
                SavingResultMessageType.none &&
            current.savingImageResultMessageType !=
                SavingResultMessageType.none) ||
        (!previous.isSubmitted && current.isSubmitted) ||
        (previous.isPhotoViewOpen != current.isPhotoViewOpen);
  }

  void _listener(BuildContext context, CreateEditSuggestionState state) {
    if (state.savingImageResultMessageType != SavingResultMessageType.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.savingImageResultMessageType ==
                    SavingResultMessageType.success
                ? context.localization.savingImageSuccess
                : context.localization.savingImageError,
          ),
        ),
      );
    } else if (state.isSubmitted) {
      widget.onClose();
    } else if (state.isPhotoViewOpen) {
      _openPhotoView(state);
    }
    _cubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEditSuggestionCubit, CreateEditSuggestionState>(
      bloc: _cubit,
      listenWhen: _listenWhen,
      listener: _listener,
      builder: (BuildContext context, CreateEditSuggestionState state) {
        if (state.isLabelsBottomSheetOpen) {
          return _LabelsBottomSheet(
            suggestionList: state.suggestion.labels,
            labelsSheetController: _labelsSheetController,
            cubit: _cubit,
          );
        } else if (state.isStatusBottomSheetOpen && i.isAdmin) {
          return _StatusesBottomSheet(
            suggestionStatus: state.suggestion.status,
            statusesSheetController: _statusesSheetController,
            cubit: _cubit,
          );
        } else if (!state.isPhotoViewOpen) {
          return _CreateEditSuggestionBottomSheet(
            state: state,
            cubit: _cubit,
            titleFocusNode: _titleFocusNode,
            controller: widget.controller,
            onUploadMultiplePhotos: widget.onUploadMultiplePhotos,
            descriptionController: _descriptionController,
            descriptionFocusNode: _descriptionFocusNode,
            titleController: _titleController,
            onClose: widget.onClose,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future<void> _openPhotoView(CreateEditSuggestionState state) async {
    await showDialog<void>(
      useSafeArea: false,
      barrierColor: Colors.black,
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PhotoView(
          initialIndex: state.openPhotoIndex!,
          onDeleteClick: _cubit.removePhoto,
          onDownloadClick: widget.onSaveToGallery != null
              ? (String path) =>
                  _cubit.showSavingResultMessage(widget.onSaveToGallery!(path))
              : null,
          photos: state.suggestion.images,
          previousNavBarColor: theme.thirdBackgroundColor,
        );
      },
    );
    _cubit.changePhotoViewStatus(isPhotoViewOpen: false);
  }
}

class _CreateEditSuggestionBottomSheet extends StatelessWidget {
  final CreateEditSuggestionState state;
  final CreateEditSuggestionCubit cubit;
  final FocusNode titleFocusNode;
  final SheetController controller;
  final OnUploadMultiplePhotosCallback? onUploadMultiplePhotos;
  final TextEditingController descriptionController;
  final FocusNode descriptionFocusNode;
  final TextEditingController titleController;
  final VoidCallback onClose;

  const _CreateEditSuggestionBottomSheet({
    required this.state,
    required this.cubit,
    required this.titleFocusNode,
    required this.controller,
    required this.onUploadMultiplePhotos,
    required this.descriptionController,
    required this.descriptionFocusNode,
    required this.titleController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      controller: controller,
      onOpen: titleFocusNode.requestFocus,
      onClose: ([_]) => onClose(),
      backgroundColor: theme.bottomSheetBackgroundColor,
      previousNavBarColor: theme.primaryBackgroundColor,
      previousStatusBarColor: theme.primaryBackgroundColor,
      initialSnapping: 0.85,
      contentBuilder: (BuildContext context, SheetState sheetState) {
        return _EditSuggestionBottomSheetListView(
          titleController: titleController,
          descriptionController: descriptionController,
          titleFocusNode: titleFocusNode,
          descriptionFocusNode: descriptionFocusNode,
          state: state,
          onUploadMultiplePhotos: onUploadMultiplePhotos,
          onTitleChanged: cubit.changeSuggestionTitle,
          onDescriptionChanged: cubit.changeSuggestionDescription,
          onLabelChanged: (value) => cubit.changeLabelsBottomSheetStatus(
            isLabelsBottomSheetOpen: value,
          ),
          onAnonymityChanged: (value) => cubit.changeSuggestionAnonymity(
            isAnonymous: value,
          ),
          onStatusChanged: (value) => cubit.changeStatusBottomSheetStatus(
            isStatusBottomSheetOpen: value,
          ),
          onSave: cubit.saveSuggestion,
        );
      },
    );
  }
}

class _LabelItems extends StatelessWidget {
  final List<SuggestionLabel> labels;
  final ValueChanged<bool> changeLabelsBottomSheetStatus;

  const _LabelItems({
    required this.labels,
    required this.changeLabelsBottomSheetStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ClickableListItem(
      title: Text(
        context.localization.labels,
        style: theme.textSmallPlusSecondaryBold,
      ),
      trailing: labels.isNotEmpty
          ? SuggestionLabels(labels: labels)
          : SvgPicture.asset(
              AssetStrings.plusIconThickImage,
              package: AssetStrings.packageName,
              colorFilter: ColorFilter.mode(
                theme.primaryIconColor,
                BlendMode.srcIn,
              ),
              height: Dimensions.defaultSize,
            ),
      onClick: () => changeLabelsBottomSheetStatus(true),
      verticalPadding: Dimensions.marginDefault,
    );
  }
}

class _SuggestionStatus extends StatelessWidget {
  final SuggestionStatus suggestionStatus;
  final ValueChanged<bool> changeStatusBottomSheetStatus;

  const _SuggestionStatus({
    required this.suggestionStatus,
    required this.changeStatusBottomSheetStatus,
  });

  String _suggestionStatus(BuildContext context) {
    switch (suggestionStatus) {
      case SuggestionStatus.completed:
        return context.localization.completed;
      case SuggestionStatus.inProgress:
        return context.localization.inProgress;
      case SuggestionStatus.requests:
        return context.localization.requests;
      case SuggestionStatus.cancelled:
        return context.localization.cancelled;
      case SuggestionStatus.duplicate:
        return context.localization.duplicate;
      case SuggestionStatus.unknown:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClickableListItem(
      title: Text(
        context.localization.status,
        style: theme.textSmallPlusSecondaryBold,
      ),
      trailing: Text(
        _suggestionStatus(context),
        style: theme.textSmallPlusBold,
      ),
      onClick: () => changeStatusBottomSheetStatus(true),
      verticalPadding: Dimensions.marginDefault,
    );
  }
}

class _SaveSubmitButton extends StatelessWidget {
  final bool isEditing;
  final bool isLoading;
  final VoidCallback saveSuggestion;

  const _SaveSubmitButton({
    required this.isEditing,
    required this.isLoading,
    required this.saveSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.marginDefault,
        ),
        child: SuggestionsElevatedButton(
          onClick: saveSuggestion,
          isLoading: isLoading,
          buttonText: isEditing
              ? context.localization.save
              : context.localization.suggest,
        ),
      ),
    );
  }
}

class _PostAnonymously extends StatelessWidget {
  final bool isAnonymously;
  final ValueChanged<bool> changeSuggestionAnonymity;

  const _PostAnonymously({
    required this.isAnonymously,
    required this.changeSuggestionAnonymity,
  });

  @override
  Widget build(BuildContext context) {
    return ClickableListItem(
      title: Text(
        context.localization.postAnonymously,
        style: theme.textSmallPlusSecondaryBold,
      ),
      trailing: SuggestionsSwitch(
        value: isAnonymously,
        onChanged: changeSuggestionAnonymity,
      ),
    );
  }
}

class _PhotoPickerItem extends StatelessWidget {
  final CreateEditSuggestionCubit _cubit = i.createEditSuggestionCubit;
  final OnUploadMultiplePhotosCallback? onUploadMultiplePhotos;
  final CreateEditSuggestionState state;

  _PhotoPickerItem({
    required this.state,
    required this.onUploadMultiplePhotos,
  });

  @override
  Widget build(BuildContext context) {
    final tileWidth = state.suggestion.images.length == 1
        ? (MediaQuery.of(context).size.width - Dimensions.margin3x) / 2
        : (MediaQuery.of(context).size.width - Dimensions.margin4x) / 3;
    return state.suggestion.images.isNotEmpty
        ? SizedBox(
            height:
                MediaQuery.of(context).size.height * Dimensions.smallSize / 100,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.marginMiddle),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: state.suggestion.images.length + 1,
                itemBuilder: (BuildContext context, int i) {
                  return _PhotoItem(
                    i: i,
                    state: state,
                    tileWidth: tileWidth,
                    onUploadPhotos: () {
                      final availableNumOfPhotos = maxPhotosForOneSuggestion -
                          state.suggestion.images.length;
                      availableNumOfPhotos > 0
                          ? _cubit.addUploadedPhotos(
                              onUploadMultiplePhotos!(
                                availableNumOfPhotos: availableNumOfPhotos,
                              ),
                            )
                          : ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.localization.eventPhotosRestriction,
                                ),
                              ),
                            );
                    },
                    onPhotoClick: () => _cubit.onPhotoClick(i - 1),
                  );
                },
              ),
            ),
          )
        : _AddButton(
            state: state,
            onUploadPhotos: () => _cubit.addUploadedPhotos(
              onUploadMultiplePhotos!(
                availableNumOfPhotos: maxPhotosForOneSuggestion,
              ),
            ),
          );
  }
}

class _PhotoItem extends StatelessWidget {
  final int i;
  final CreateEditSuggestionState state;
  final VoidCallback onUploadPhotos;
  final double tileWidth;
  final VoidCallback onPhotoClick;

  const _PhotoItem({
    required this.i,
    required this.state,
    required this.onUploadPhotos,
    required this.tileWidth,
    required this.onPhotoClick,
  });

  @override
  Widget build(BuildContext context) {
    if (i == 0) {
      return GestureDetector(
        onTap: onUploadPhotos,
        child: AddPhotoButton(
          width:
              state.suggestion.images.length > 2 ? tileWidth * 0.9 : tileWidth,
          height: (MediaQuery.of(context).size.width - 80) / 3,
          style: theme.textSmallPlusBold,
          isLoading: state.isLoading,
        ),
      );
    } else {
      return GestureDetector(
        onTap: onPhotoClick,
        child: Container(
          margin: const EdgeInsets.only(
            right: Dimensions.marginDefault,
          ),
          width: tileWidth,
          height: 98,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(Dimensions.smallCircularRadius),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.cover,
            child: SuggestionsNetworkImage(
              url: state.suggestion.images[i - 1],
            ),
          ),
        ),
      );
    }
  }
}

class _AddButton extends StatelessWidget {
  final CreateEditSuggestionState state;
  final VoidCallback onUploadPhotos;

  const _AddButton({
    required this.state,
    required this.onUploadPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return ClickableListItem(
      title: Text(
        context.localization.addPhoto,
        style: theme.textSmallPlusSecondaryBold,
      ),
      trailing: state.isLoading
          ? CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryIconColor),
            )
          : SvgPicture.asset(
              AssetStrings.plusIconThickImage,
              package: AssetStrings.packageName,
              colorFilter: ColorFilter.mode(
                theme.primaryIconColor,
                BlendMode.srcIn,
              ),
              height: state.suggestion.images.isNotEmpty
                  ? Dimensions.smallSize
                  : Dimensions.defaultSize,
            ),
      onClick: onUploadPhotos,
      verticalPadding: Dimensions.marginDefault,
    );
  }
}

class _PhotoPreview extends StatefulWidget {
  final List<String> suggestionImages;
  final VoidCallback onPreviewClick;

  const _PhotoPreview({
    required this.suggestionImages,
    required this.onPreviewClick,
  });

  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<_PhotoPreview> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPreviewClick,
      child: SizedBox(
        width: widget.suggestionImages.length <= 3
            ? Dimensions.microSize +
                Dimensions.smallSize * widget.suggestionImages.length
            : Dimensions.veryBigSize,
        child: Stack(
          children: <Widget>[
            if (widget.suggestionImages.isNotEmpty)
              SizedBox(
                width: Dimensions.defaultSize,
                child: SmallPhotoPreview(
                  src: widget.suggestionImages[0],
                  heroTag: 'photo_view',
                  backgroundColor: theme.secondaryBackgroundColor,
                ),
              ),
            if (widget.suggestionImages.length >= 2)
              Container(
                width: Dimensions.largeSize,
                padding: const EdgeInsets.only(left: Dimensions.marginDefault),
                child: SmallPhotoPreview(
                  src: widget.suggestionImages[1],
                  heroTag: 'photo_view',
                  backgroundColor: theme.secondaryBackgroundColor,
                ),
              ),
            if (widget.suggestionImages.length >= 3)
              Container(
                width: Dimensions.veryBigSize,
                padding: const EdgeInsets.only(left: Dimensions.margin2x),
                child: SmallPhotoPreview(
                  src: widget.suggestionImages[2],
                  heroTag: 'photo_view',
                  backgroundColor: theme.secondaryBackgroundColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditSuggestionBottomSheetListView extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final FocusNode titleFocusNode;
  final FocusNode descriptionFocusNode;
  final CreateEditSuggestionState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<bool> onLabelChanged;
  final ValueChanged<bool> onStatusChanged;
  final ValueChanged<bool> onAnonymityChanged;
  final VoidCallback onSave;
  final OnUploadMultiplePhotosCallback? onUploadMultiplePhotos;

  const _EditSuggestionBottomSheetListView({
    required this.titleController,
    required this.descriptionController,
    required this.titleFocusNode,
    required this.descriptionFocusNode,
    required this.state,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onLabelChanged,
    required this.onStatusChanged,
    required this.onAnonymityChanged,
    required this.onSave,
    required this.onUploadMultiplePhotos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.marginSmall,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        SuggestionsTextField(
          controller: titleController,
          focusNode: titleFocusNode,
          hintText: context.localization.title,
          padding: const EdgeInsets.fromLTRB(
            Dimensions.marginDefault,
            Dimensions.marginDefault,
            Dimensions.marginSmall,
            Dimensions.marginDefault,
          ),
          onChanged: (String text) {
            if (state.suggestion.title != text) {
              onTitleChanged(text);
            }
          },
          isShowError: state.isShowTitleError,
        ),
        const SizedBox(height: Dimensions.marginDefault),
        SuggestionsTextField(
          controller: descriptionController,
          focusNode: descriptionFocusNode,
          hintText: context.localization.description,
          padding: const EdgeInsets.fromLTRB(
            Dimensions.marginDefault,
            Dimensions.marginDefault,
            Dimensions.marginSmall,
            Dimensions.marginDefault,
          ),
          onChanged: (String text) {
            if (state.suggestion.description != text) {
              onDescriptionChanged(text);
            }
          },
        ),
        const SizedBox(height: Dimensions.marginBig),
        Divider(color: theme.dividerColor, thickness: 0.5, height: 1.5),
        _LabelItems(
          labels: state.suggestion.labels,
          changeLabelsBottomSheetStatus: onLabelChanged,
        ),
        ..._suggestionStatus(),
        ..._multiplePicker(),
        ..._anonymitySwitch(),
        _SaveSubmitButton(
          isEditing: state.isEditing,
          isLoading: state.isLoading,
          saveSuggestion: onSave,
        ),
      ],
    );
  }

  List<Widget> _suggestionStatus() {
    if (i.isAdmin && state.isEditing) {
      return <Widget>[
        Divider(color: theme.dividerColor, thickness: 0.5, height: 1.5),
        _SuggestionStatus(
          suggestionStatus: state.suggestion.status,
          changeStatusBottomSheetStatus: onStatusChanged,
        ),
      ];
    }
    return [];
  }

  List<Widget> _multiplePicker() {
    if (onUploadMultiplePhotos != null) {
      return <Widget>[
        if (state.suggestion.images.isNotEmpty)
          const SizedBox.shrink()
        else
          const _DividerWithIndent(),
        _PhotoPickerItem(
          state: state,
          onUploadMultiplePhotos: onUploadMultiplePhotos,
        ),
      ];
    }
    return [];
  }

  List<Widget> _anonymitySwitch() {
    if (!state.isEditing) {
      return <Widget>[
        const _DividerWithIndent(),
        const SizedBox(height: Dimensions.marginSmall),
        _PostAnonymously(
          isAnonymously: state.suggestion.isAnonymous,
          changeSuggestionAnonymity: onAnonymityChanged,
        ),
        const SizedBox(height: Dimensions.marginSmall),
      ];
    }
    return [];
  }
}

class _StatusesBottomSheet extends StatelessWidget {
  final SuggestionStatus suggestionStatus;
  final SheetController statusesSheetController;
  final CreateEditSuggestionCubit cubit;

  const _StatusesBottomSheet({
    required this.suggestionStatus,
    required this.statusesSheetController,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBottomSheet(
      controller: statusesSheetController,
      selectedStatus: suggestionStatus,
      onCancel: ([_]) => statusesSheetController.collapse()?.then(
            (_) => cubit.changeStatusBottomSheetStatus(
              isStatusBottomSheetOpen: false,
            ),
          ),
      onDone: (SuggestionStatus status) {
        cubit.changeStatus(status);
        statusesSheetController.collapse()?.then(
              (_) => cubit.changeStatusBottomSheetStatus(
                isStatusBottomSheetOpen: false,
              ),
            );
      },
    );
  }
}

class _LabelsBottomSheet extends StatelessWidget {
  final List<SuggestionLabel> suggestionList;
  final SheetController labelsSheetController;
  final CreateEditSuggestionCubit cubit;

  const _LabelsBottomSheet({
    required this.suggestionList,
    required this.labelsSheetController,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return LabelBottomSheet(
      controller: labelsSheetController,
      selectedLabels: suggestionList,
      onCancel: ([_]) => labelsSheetController.collapse()?.then(
            (_) => cubit.changeLabelsBottomSheetStatus(
              isLabelsBottomSheetOpen: false,
            ),
          ),
      onDone: (List<SuggestionLabel> labels) {
        cubit.selectLabels(labels);
        labelsSheetController.collapse()?.then(
              (_) => cubit.changeLabelsBottomSheetStatus(
                isLabelsBottomSheetOpen: false,
              ),
            );
      },
    );
  }
}

class _DividerWithIndent extends StatelessWidget {
  const _DividerWithIndent();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: theme.dividerColor,
      thickness: 0.5,
      height: 1.5,
      indent: Dimensions.marginDefault,
      endIndent: Dimensions.marginDefault,
    );
  }
}
