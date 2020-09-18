import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  int selectedBusiness = 0;

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  void updateBusiness(int business) {
    this.selectedBusiness = business;
    notifyListeners();
  }
}

Future<Null> changeSelectedBusiness(BuildContext context, int id) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'selected_business';
  await prefs.setInt(key, id);
  Provider.of<AppStateNotifier>(context, listen: false).updateBusiness(id);
}
