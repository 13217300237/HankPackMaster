import 'package:jiffy/jiffy.dart';

class DateTimeUtil {
  // "yyyy-MM-dd HH:mm:ss"

  static String format(int? datetimeInt) {
    return Jiffy.parseFromDateTime(
            DateTime.fromMillisecondsSinceEpoch(datetimeInt ?? 0))
        .format(pattern: "yyyy-MM-dd HH:mm:ss");
  }

  static String nowFormat(){
    return Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss");
  }

  static String nowFormat2(){
    return Jiffy.now().format(pattern: "yyyyMMdd_HHmmss_");
  }

}
