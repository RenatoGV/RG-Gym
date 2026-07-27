class FormatHelper {
  static String formatDouble(double value) {
    final rounded = double.parse(value.toStringAsFixed(2));

    return rounded.remainder(1) == 0
        ? rounded.toInt().toString()
        : rounded.toString();
  }
}