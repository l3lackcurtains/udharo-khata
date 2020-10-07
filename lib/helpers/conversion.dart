import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';

Map<String, String> formatDate(BuildContext context, DateTime date) {
  String lang = Provider.of<AppStateNotifier>(context).appLocale;
  String calendar = Provider.of<AppStateNotifier>(context).calendar;
  if (calendar == 'ne') {
    NepaliUtils(lang == 'ne' ? Language.nepali : Language.english);
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

String amountFormat(BuildContext context, double n) {
  String lang = Provider.of<AppStateNotifier>(context).appLocale;
  String currency = Provider.of<AppStateNotifier>(context).currency;
  num x = n % 1 == 0 ? n.toInt() : n;
  var currencyFormat = NepaliNumberFormat(
    symbol: currency,
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
