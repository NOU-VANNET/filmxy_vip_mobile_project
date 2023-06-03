import 'package:timeago/timeago.dart' as timeago;

extension DATETIMEEXTENSIONS on DateTime {
  ///Return true if expired otherwise false ||
  ///Params validate: minutes, hours, days, months, years || number: the number should expire of the validate.
  bool checkExpireDate({int number = 6, String validate = 'days'}) {

    String ago = timeago.format(this, getPrefixSuffix: false);

    String s = ago.split(' ').first;

    int number = int.parse((s == 'a' || s == 'about') ? '1' : s);
    String m = ago.split(' ').last;

    if (validate == 'minutes') {
      if (number == 1 && ago == 'a minute') {
        return true;
      } else {
        if (m == 'minutes') {
          return number >= number;
        } else {
          return ago == 'about an hour' ||
              m == 'hours' ||
              ago == 'a day' ||
              m == 'days' ||
              ago == 'about a month' ||
              m == 'months' ||
              ago == 'about a year' ||
              m == 'years';
        }
      }
    } else if (validate == 'hours') {
      if (number == 1 && ago == 'about an hour') {
        return true;
      } else {
        if (m == 'hours') {
          return number >= number;
        } else {
          return ago == 'a day' ||
              m == 'days' ||
              ago == 'about a month' ||
              m == 'months' ||
              ago == 'about a year' ||
              m == 'years';
        }
      }
    } else if (validate == 'days') {
      if (number == 1 && ago == 'a day') {
        return true;
      } else {
        if (m == 'days') {
          return number >= number;
        } else {
          return ago == 'about a month' ||
              m == 'months' ||
              ago == 'about a year' ||
              m == 'years';
        }
      }
    } else if (validate == 'months') {
      if (number == 1 && ago == 'about a month') {
        return true;
      } else {
        if (m == 'months') {
          return number >= number;
        } else {
          return ago == 'about a year' ||
              m == 'years';
        }
      }
    } else if (validate == 'years') {
      if (number == 1 && ago == 'about a year') {
        return true;
      } else {
        return number >= number;
      }
    } else {
      throw Exception('Unknown validate value!');
    }
  }

  DateTime getUTC() {
    final t = this;
    return DateTime.utc(t.year, t.month, t.day, t.hour, t.minute, t.second, t.millisecond);
  }

}