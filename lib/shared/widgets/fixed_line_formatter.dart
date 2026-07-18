import 'package:flutter/services.dart';

class FixedLineFormatter extends TextInputFormatter {
  final int charsPerLine;
  final int maxLines;

  FixedLineFormatter({
    this.charsPerLine = 20,
    this.maxLines = 40,
  });

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final rawText = newValue.text.replaceAll('\n', '');

    final maxChars = charsPerLine * maxLines;
    if (rawText.length > maxChars) {
      return oldValue;
    }

    final buffer = StringBuffer();
    int newOffset = newValue.selection.baseOffset;
    int rawIndex = 0;

    while (rawIndex < rawText.length) {
      if (rawIndex > 0 && rawIndex % charsPerLine == 0) {
        buffer.write('\n');

        if (rawIndex < newValue.selection.baseOffset) {
          newOffset++;
        }
      }

      buffer.write(rawText[rawIndex]);
      rawIndex++;
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, formatted.length),
      ),
    );
  }
}