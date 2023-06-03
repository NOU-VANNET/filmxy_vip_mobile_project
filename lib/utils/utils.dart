import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool showAds = false;

class Utils {

  Map<String, dynamic> timeLeft(DateTime due, DateTime now) {

    Duration timeUntilDue = due.difference(now);

    int daysUntil = timeUntilDue.inDays;
    int hoursUntil = timeUntilDue.inHours - (daysUntil * 24);
    int minUntil = timeUntilDue.inMinutes - (daysUntil * 24 * 60) - (hoursUntil * 60);
    int secUntil = timeUntilDue.inSeconds - (minUntil * 60);

    String s = secUntil.toString().length <= 2 ? secUntil.toString() : secUntil.toString().substring(secUntil.toString().length - 2);

    bool isFinished = false;
    int day = 0;
    int hour = 0;
    int minute = 0;
    int second = 0;

    if (daysUntil > 0) {
      day = daysUntil;
    }
    if (hoursUntil > 0) {
      hour = hoursUntil;
    }
    if (minUntil > 0) {
      minute = minUntil;
    }
    if (secUntil > 0) {
      second += int.parse(s);
    }

    if(secUntil < 1) {
      isFinished = true;
    }

    Map<String, dynamic> map = {
      "day": day,
      "hour": hour,
      "minute": minute,
      "second": second,
      "finished": isFinished,
    };

    return map;
  }

  void showToast(String message) =>
      Fluttertoast.showToast(msg: message, fontSize: 16);

  void portrait() => SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  void landScape() => SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  Map getCountry(String langCode) {
    final country = languages.firstWhere((e) => e['language']['code'] == langCode);
    return country;
  }

  List<Map<String, dynamic>> languages = [
    {
      "language": {"code": "ps", "name": "Pashto"}
    },
    {
      "language": {"code": "sv", "name": "Swedish"}
    },
    {
      "language": {"code": "sq", "name": "Albanian"}
    },
    {
      "language": {"code": "ar", "name": "Arabic"}
    },
    {
      "language": {"code": "en", "name": "English"}
    },
    {
      "language": {"code": "ca", "name": "Catalan"}
    },
    {
      "language": {"code": "pt", "name": "Portuguese"}
    },
    {
      "language": {"code": "es", "name": "Spanish"}
    },
    {
      "language": {"code": "hy", "name": "Armenian"}
    },
    {
      "language": {"code": "nl", "name": "Dutch"}
    },
    {
      "language": {"code": "de", "name": "German"}
    },
    {
      "language": {"code": "az", "name": "Azerbaijani"}
    },
    {
      "language": {"code": "bn", "name": "Bengali"}
    },
    {
      "language": {"code": "be", "name": "Belarusian"}
    },
    {
      "language": {"code": "fr", "name": "French"}
    },
    {
      "language": {"code": "dz", "name": "Dzongkha"}
    },
    {
      "language": {"code": "bs", "name": "Bosnian"}
    },
    {
      "language": {"code": "no", "name": "Norwegian"}
    },
    {
      "language": {"code": "ms", "name": "Malay"}
    },
    {
      "language": {"code": "bg", "name": "Bulgarian"}
    },
    {
      "language": {"code": "km", "name": "Khmer"}
    },
    {
      "language": {"code": "zh", "name": "Chinese"}
    },
    {
      "language": {"code": "hr", "name": "Croatian"}
    },
    {
      "language": {"code": "tr", "name": "Turkish"}
    },
    {
      "language": {"code": "cs", "name": "Czech"}
    },
    {
      "language": {"code": "da", "name": "Danish"}
    },
    {
      "language": {"code": "et", "name": "Estonian"}
    },
    {
      "language": {"code": "am", "name": "Amharic"}
    },
    {
      "language": {"code": "fo", "name": "Faroese"}
    },
    {
      "language": {
        "code": "fi",
        "iso639_2": "fin",
        "name": "Finnish",
        "nativeName": "suomi"
      }
    },
    {
      "language": {"code": "ka", "name": "Georgian"}
    },
    {
      "language": {"code": "el", "name": "Greek (modern)"}
    },
    {
      "language": {"code": "kl", "name": "Kalaallisut"}
    },
    {
      "language": {"code": "hu", "name": "Hungarian"}
    },
    {
      "language": {"code": "is", "name": "Icelandic"}
    },
    {
      "language": {"code": "hi", "name": "Hindi"}
    },
    {
      "language": {"code": "id", "name": "Indonesian"}
    },
    {
      "language": {"code": "fa", "name": "Persian (Farsi)"}
    },
    {
      "language": {"code": "ga", "name": "Irish"}
    },
    {
      "language": {"code": "he", "name": "Hebrew (modern)"}
    },
    {
      "language": {"code": "it", "name": "Italian"}
    },
    {
      "language": {"code": "ja", "name": "Japanese"}
    },
    {
      "language": {"code": "kk", "name": "Kazakh"}
    },
    {
      "language": {"code": "ky", "name": "Kyrgyz"}
    },
    {
      "language": {"code": "lo", "name": "Lao"}
    },
    {
      "language": {"code": "lv", "name": "Latvian"}
    },
    {
      "language": {"code": "lt", "name": "Lithuanian"}
    },
    {
      "language": {"code": "mk", "name": "Macedonian"}
    },
    {
      "language": {"code": "null", "name": "Malaysian"}
    },
    {
      "language": {"code": "dv", "name": "Divehi"}
    },
    {
      "language": {"code": "mt", "name": "Maltese"}
    },
    {
      "language": {"code": "ro", "name": "Romanian"}
    },
    {
      "language": {"code": "mn", "name": "Mongolian"}
    },
    {
      "language": {"code": "sr", "name": "Serbian"}
    },
    {
      "language": {"code": "my", "name": "Burmese"}
    },
    {
      "language": {"code": "ne", "name": "Nepali"}
    },
    {
      "language": {"code": "ko", "name": "Korean"}
    },
    {
      "language": {"code": "pl", "name": "Polish"}
    },
    {
      "language": {"code": "ru", "name": "Russian"}
    },
    {
      "language": {"code": "rw", "name": "Kinyarwanda"}
    },
    {
      "language": {"code": "sm", "name": "Samoan"}
    },
    {
      "language": {"code": "sk", "name": "Slovak"}
    },
    {
      "language": {"code": "sl", "name": "Slovene"}
    },
    {
      "language": {
        "code": "si",
        "iso639_2": "sin",
        "name": "Sinhalese",
        "nativeName": "සිංහල"
      }
    },
    {
      "language": {"code": "tg", "name": "Tajik"}
    },
    {
      "language": {"code": "th", "name": "Thai"}
    },
    {
      "language": {"code": "tk", "name": "Turkmen"}
    },
    {
      "language": {"code": "uk", "name": "Ukrainian"}
    },
    {
      "language": {"code": "ur", "name": "Urdu"}
    },
    {
      "language": {"code": "uz", "name": "Uzbek"}
    },
    {
      "language": {"code": "vi", "name": "Vietnamese"}
    }
  ];

}
