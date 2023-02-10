import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextEditor extends StatelessWidget {
  const TextEditor({
    required this.controller,
    this.readOnly = false,
    this.showCursor = true,
    super.key,
  });

  final QuillController controller;
  final bool readOnly;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (!readOnly) _buildToolbar(),
        _buildEditor(),
      ],
    );
  }

  Column _buildToolbar() {
    return Column(
      children: <Widget>[
        QuillToolbar.basic(
          controller: controller,
          showAlignmentButtons: true,
          toolbarIconAlignment: WrapAlignment.start,
          showFontFamily: false,
          showFontSize: false,
          showStrikeThrough: false,
          showHeaderStyle: false,
          showInlineCode: false,
          showLink: false,
          showSearchButton: false,
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Container _buildEditor() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
      ),
      padding: const EdgeInsets.all(16),
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
