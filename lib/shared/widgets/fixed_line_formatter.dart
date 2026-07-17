import 'package:flutter/services.dart';

class FixedLineFormatter extends TextInputFormatter {
  final int charsPerLine;
  final int maxLines;

  FixedLineFormatter({
    this.charsPerLine = 20,
    this.maxLines = 40,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('\n', '');

    final maxChars = charsPerLine * maxLines;

    if (text.length > maxChars) {
      return oldValue;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % charsPerLine == 0) {
        buffer.write('\n');
      }

      buffer.write(text[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}