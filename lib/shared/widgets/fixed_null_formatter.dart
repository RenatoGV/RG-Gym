import 'package:flutter/services.dart';

class FixedNullFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    if (oldValue.text == '0' &&
        text.length == 2 &&
        text.startsWith('0')) {
      text = text.substring(1);
    }

    if (text.isEmpty) {
      text = '0';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}