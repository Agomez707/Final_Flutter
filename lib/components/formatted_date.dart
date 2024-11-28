import 'package:intl/intl.dart';

 // Convierte el Timestamp a DateTime

String formatDate(dateToFormated) {
  final DateTime dateTime = dateToFormated.toDate();
  // Formatea la fecha
  final String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

  return formattedDate;
}

