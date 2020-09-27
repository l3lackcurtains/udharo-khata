import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';

Map<String, String> formatDate(String lang, DateTime date) {
  if (lang == 'ne') {
    NepaliUtils(Language.nepali);
    NepaliDateTime nt = date.toNepaliDateTime();
    String formatted = nt.format("dd, MMMM yyyy");
    String day = nt.format("dd");
    String month = nt.format("MMMM");
    String year = nt.format("yyyy");
    return {"full": formatted, "day": day, "month": month, "year": year};
  }
  String formatted = DateFormat("dd, MMMM yyyy").format(date);
  String day = DateFormat("dd").format(date);
  String month = DateFormat("MMM").format(date);
  String year = DateFormat("yyyy").format(date);
  return {"full": formatted, "day": day, "month": month, "year": year};
}

String amountFormat(double n) {
  return "Rs. " + n.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
}
