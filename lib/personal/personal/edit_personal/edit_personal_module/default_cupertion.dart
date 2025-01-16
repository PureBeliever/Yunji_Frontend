import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
//日期选择器
class MyDefaultCupertinoLocalizations extends DefaultCupertinoLocalizations {
  static const List<String> _months = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  @override
  String datePickerMonth(int monthIndex) => _months[monthIndex - 1];

  static Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
        MyDefaultCupertinoLocalizations());
  }

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
  _CupertinoLocalizationsDelegate();
}

class _CupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      MyDefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(_CupertinoLocalizationsDelegate old) => false;

  @override
  String toString() => 'MyDefaultCupertinoLocalizations.delegate(en_US)';
}

