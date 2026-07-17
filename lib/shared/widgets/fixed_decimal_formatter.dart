import 'package:flutter/services.dart';

class FixedDecimalFormatter extends TextInputFormatter {
  final int decimalDigits;
  final int maxIntegerDigits;

  const FixedDecimalFormatter({
    this.decimalDigits = 1,
    this.maxIntegerDigits = 3,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Solo conservar números
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final maxDigits = maxIntegerDigits + decimalDigits;

    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    // Siempre al menos los decimales
    while (digits.length < decimalDigits + 1) {
      digits = '0$digits';
    }

    final split = digits.length - decimalDigits;

    final integer =
        digits.substring(0, split).replaceFirst(RegExp(r'^0+(?=\d)'), '');

    final decimal = digits.substring(split);

    final formatted =
        '${integer.isEmpty ? '0' : integer}.$decimal';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}