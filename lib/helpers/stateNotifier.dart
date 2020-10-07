import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appLocalizations.dart';

class AppStateNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  int selectedBusiness = 0;
  String appLocale = "en";
  String currency = "Rs";
  String calendar = "en";

  void updateLocale(String locale) {
    this.appLocale = locale;
    notifyListeners();
  }

  void updateSelectedBusiness(int bid) {
    this.selectedBusiness = bid;
    notifyListeners();
  }

  void updateCurrency(String currency) {
    this.currency = currency;
    notifyListeners();
  }

  void updateCalendar(String calendar) {
    this.calendar = calendar;
    notifyListeners();
  }
}

Future<Null> fetchLocale(BuildContext context) async {
  var prefs = await SharedPreferences.getInstance();
  String code = prefs.getString('language_code') ?? "en";
  Provider.of<AppStateNotifier>(context, listen: false).updateLocale(code);
  AppLocalizations.delegate.load(Locale(code));
}

Future<Null> changeLanguage(BuildContext context, String lang) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'language_code';
  Provider.of<AppStateNotifier>(context, listen: false).updateLocale(lang);

  Locale appLocale = Locale(lang);

  Provider.of<AppStateNotifier>(context, listen: false).updateLocale(lang);
  AppLocalizations.delegate.load(appLocale);

  await prefs.setString(key, lang);
}

Future<Null> changeSelectedBusiness(BuildContext context, int id) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'selected_business';
  await prefs.setInt(key, id);
  Provider.of<AppStateNotifier>(context, listen: false)
      .updateSelectedBusiness(id);
}

Future<Null> changeCurrency(BuildContext context, String currency) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'currency';
  await prefs.setString(key, currency);
  Provider.of<AppStateNotifier>(context, listen: false)
      .updateCurrency(currency);
}

Future<Null> changeCalendar(BuildContext context, String calendar) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'calendar';
  await prefs.setString(key, calendar);
  Provider.of<AppStateNotifier>(context, listen: false)
      .updateCalendar(calendar);
}
