class FormatHelper {
  static String formatDouble(double value) {
    return value.remainder(1) == 0
        ? value.toInt().toString()
        : value.toString();
  }
}