import 'package:background_fetch/background_fetch.dart';
import 'package:cron/cron.dart';
import 'package:shared_preferences/shared_preferences.dart';

void autoBackupData(String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String lastBackup = prefs.getString("last_backup");
  DateTime lastBackupDate = DateTime.now();
  if (lastBackup != null) {
    lastBackupDate = DateTime.parse(lastBackup);
  }
  DateTime todayDate = DateTime.now();
  if (todayDate.difference(lastBackupDate).inDays > 7) {
    var cron = new Cron();
    cron.schedule(new Schedule.parse('8-11 * * * *'), () async {
      await prefs.setString('last_backup', todayDate.toString());
    });
  }

  print('[BackgroundFetch] Headless event received.');
  BackgroundFetch.finish(taskId);
}
