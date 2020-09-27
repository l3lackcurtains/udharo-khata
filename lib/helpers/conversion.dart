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

String amountFormat(String lang, double n) {
  num x = n % 1 == 0 ? n.toInt() : n;
  var currencyFormat = NepaliNumberFormat(
    symbol: lang == "ne" ? "रु" : "Rs.",
    language: lang == "ne" ? Language.nepali : Language.english,
    isMonetory: true,
  );
  String amount = currencyFormat.format(x);

  return amount;
}

String doubleWithoutDecimalToString(double val) {
  num x = val % 1 == 0 ? val.toInt() : val;
  return x.toString();
}
