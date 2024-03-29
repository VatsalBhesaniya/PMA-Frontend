import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextEditor extends StatelessWidget {
  const TextEditor({
    required this.controller,
    this.readOnly = false,
    this.showCursor = true,
    this.minHeight = 300,
    super.key,
  });

  final QuillController controller;
  final bool readOnly;
  final bool showCursor;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        if (!readOnly) _buildToolbar(theme),
        _buildEditor(theme),
      ],
    );
  }

  Column _buildToolbar(ThemeData theme) {
    return Column(
      children: <Widget>[
        QuillToolbar.basic(
          controller: controller,
          iconTheme: QuillIconTheme(
            iconUnselectedFillColor: theme.colorScheme.onSurface,
            iconSelectedColor: theme.colorScheme.primary,
            iconSelectedFillColor: theme.colorScheme.primaryContainer,
            disabledIconColor: theme.colorScheme.primaryContainer,
          ),
          showAlignmentButtons: true,
          toolbarIconAlignment: WrapAlignment.start,
          toolbarSectionSpacing: 0,
          showFontFamily: false,
          showFontSize: false,
          showStrikeThrough: false,
          showHeaderStyle: false,
          showInlineCode: false,
          showLink: false,
          showSearchButton: false,
        ),
        const Divider(),
      ],
    );
  }

  Container _buildEditor(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        minHeight: minHeight,
      ),
      child: QuillEditor(
        readOnly: readOnly,
        showCursor: showCursor,
        controller: controller,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: FocusNode(),
        autoFocus: true,
        expands: false,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
