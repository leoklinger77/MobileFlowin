class AvailableMonth {
  static const List<String> month = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  /// Retorna o nome completo do mês com o ano (ex: Julho 2025)
  static String getMonthWithYear(int index, int offset) {
    final now = DateTime.now();
    final adjustedDate = DateTime(now.year, now.month + offset);
    final name = month[adjustedDate.month - 1];
    return '$name ${adjustedDate.year}';
  }

  /// Retorna o DateTime correspondente ao índice e offset
  // static DateTime getDateFromOffset(int offset) {
  //   final now = DateTime.now();
  //   return DateTime(now.year, now.month + offset);
  // }

  static DateTime getDateFromOffset(int offset) {
    final now = DateTime.now();
    final year = now.year + ((now.month - 1 + offset) ~/ 12);
    final month = ((now.month - 1 + offset) % 12) + 1;
    return DateTime(year, month);
  }
}
