import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextEditor extends StatelessWidget {
  const TextEditor({required this.controller, super.key});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
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
        SizedBox(
          height: 200,
          child: QuillEditor(
            controller: controller,
            scrollController: ScrollController(),
            scrollable: true,
            focusNode: FocusNode(),
            autoFocus: true,
            readOnly: false,
            expands: false,
            padding: EdgeInsets.zero,
          ),
        )
      ],
    );
  }
}
