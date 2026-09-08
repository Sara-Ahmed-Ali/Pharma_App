import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: 'EGP ', decimalDigits: 2);

  static String currency(double amount) => _currencyFormat.format(amount);

  static String date(DateTime date) =>
      DateFormat('MMM d, yyyy - h:mm a').format(date.toLocal());
}