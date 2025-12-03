class AppFunctions {
  AppFunctions._();

  static String formatNumber(double value) {
    if (value == 0) return '0';

    if (value == value.roundToDouble()) {
      return _addCommas(value.toInt().toString());
    }

    String formatted = value.toStringAsFixed(2);

    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }

    final parts = formatted.split('.');
    parts[0] = _addCommas(parts[0]);
    return parts.join('.');
  }

  static String _addCommas(String value) {
    if (value.length <= 3) return value;

    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(regex, (match) => '${match[1]},');
  }

}

