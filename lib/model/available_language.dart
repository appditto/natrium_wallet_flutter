import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum AvailableLanguage {
  DEFAULT,
  ARABIC,
  ENGLISH,
  CATALAN,
  CHINESE_SIMPLIFIED,
  CHINESE_TRADITIONAL,
  DANISH,
  DUTCH,
  FRENCH,
  GERMAN,
  HEBREW,
  HINDI,
  HUNGARIAN,
  INDONESIAN,
  JAPANESE,
  KOREAN,
  LATVIAN,
  ITALIAN,
  MALAY,
  POLISH,
  PORTUGUESE,
  ROMANIAN,
  BULGARIAN,
  RUSSIAN,
  SLOVENIAN,
  SPANISH,
  SWEDISH,
  TAGALOG,
  TURKISH,
  VIETNAMESE,
  UKRAINIAN,
  NORWEGIAN,
  BENGALI,
}

/// Represent the available languages our app supports
class LanguageSetting extends SettingSelectionItem {
  AvailableLanguage language;

  LanguageSetting(this.language);

  String getDisplayName(BuildContext context) {
    switch (language) {
      case AvailableLanguage.ENGLISH:
        return "English (en)";
      case AvailableLanguage.ARABIC:
        return "العَرَبِيَّة‎ (ar)";
      case AvailableLanguage.BULGARIAN:
        return "Български език (bg)";
      case AvailableLanguage.FRENCH:
        return "Français (fr)";
      case AvailableLanguage.DANISH:
        return "Dansk (da)";
      case AvailableLanguage.GERMAN:
        return "Deutsch (de)";
      case AvailableLanguage.SPANISH:
        return "Español (es)";
      case AvailableLanguage.HINDI:
        return "हिन्दी (hi)";
      case AvailableLanguage.HUNGARIAN:
        return "Magyar (hu)";
      case AvailableLanguage.HEBREW:
        return "Hebrew (he)";
      case AvailableLanguage.INDONESIAN:
        return "Bahasa Indonesia (id)";
      case AvailableLanguage.JAPANESE:
        return "日本語 (ja)";
      case AvailableLanguage.KOREAN:
        return "한국어 (ko)";
      case AvailableLanguage.LATVIAN:
        return "Latviešu (lv)";
      case AvailableLanguage.ITALIAN:
        return "Italiano (it)";
      case AvailableLanguage.DUTCH:
        return "Nederlands (nl)";
      case AvailableLanguage.POLISH:
        return "Polski (pl)";
      case AvailableLanguage.PORTUGUESE:
        return "Português (pt)";
      case AvailableLanguage.ROMANIAN:
        return "Română (ro)";
      case AvailableLanguage.SLOVENIAN:
        return "Slovenščina (sl)";
      case AvailableLanguage.RUSSIAN:
        return "Русский язык (ru)";
      case AvailableLanguage.SWEDISH:
        return "Svenska (sv)";
      case AvailableLanguage.TAGALOG:
        return "Tagalog (tl)";
      case AvailableLanguage.TURKISH:
        return "Türkçe (tr)";
      case AvailableLanguage.VIETNAMESE:
        return "Tiếng Việt (vi)";
      case AvailableLanguage.CHINESE_SIMPLIFIED:
        return "简体字 (zh-Hans)";
      case AvailableLanguage.CHINESE_TRADITIONAL:
        return "繁體中文 (zh-Hant)";
      case AvailableLanguage.MALAY:
        return "Bahasa Melayu (ms)";
      case AvailableLanguage.CATALAN:
        return "Català (ca)";
      case AvailableLanguage.UKRAINIAN:
        return "Ukrainian (uk)";
      case AvailableLanguage.NORWEGIAN:
        return "Norsk (no)";
      case AvailableLanguage.BENGALI:
        return "Bengali (bn)";
      default:
        return AppLocalization.of(context).systemDefault;
    }
  }

  String getLocaleString() {
    switch (language) {
      case AvailableLanguage.ENGLISH:
        return "en";
      case AvailableLanguage.ARABIC:
        return "ar";
      case AvailableLanguage.BULGARIAN:
        return "bg";
      case AvailableLanguage.FRENCH:
        return "fr";
      case AvailableLanguage.GERMAN:
        return "de";
      case AvailableLanguage.SPANISH:
        return "es";
      case AvailableLanguage.HINDI:
        return "hi";
      case AvailableLanguage.HUNGARIAN:
        return "hu";
      case AvailableLanguage.HEBREW:
        return "he";
      case AvailableLanguage.INDONESIAN:
        return "id";
      case AvailableLanguage.JAPANESE:
        return "ja";
      case AvailableLanguage.KOREAN:
        return "ko";
      case AvailableLanguage.LATVIAN:
        return "lv";
      case AvailableLanguage.ITALIAN:
        return "it";
      case AvailableLanguage.DUTCH:
        return "nl";
      case AvailableLanguage.POLISH:
        return "pl";
      case AvailableLanguage.PORTUGUESE:
        return "pt";
      case AvailableLanguage.ROMANIAN:
        return "ro";
      case AvailableLanguage.RUSSIAN:
        return "ru";
      case AvailableLanguage.SLOVENIAN:
        return "sl";
      case AvailableLanguage.SWEDISH:
        return "sv";
      case AvailableLanguage.TAGALOG:
        return "tl";
      case AvailableLanguage.TURKISH:
        return "tr";
      case AvailableLanguage.VIETNAMESE:
        return "vi";
      case AvailableLanguage.CHINESE_SIMPLIFIED:
        return "zh-Hans";
      case AvailableLanguage.CHINESE_TRADITIONAL:
        return "zh-Hant";
      case AvailableLanguage.MALAY:
        return "ms";
      case AvailableLanguage.DANISH:
        return "da";
      case AvailableLanguage.CATALAN:
        return "ca";
      case AvailableLanguage.UKRAINIAN:
        return "uk";
      case AvailableLanguage.NORWEGIAN:
        return "no";
      case AvailableLanguage.BENGALI:
        return "bn";
      default:
        return "DEFAULT";
    }
  }

  Locale getLocale() {
    String localeStr = getLocaleString();
    if (localeStr == 'DEFAULT') {
      return Locale('en');
    } else if (localeStr == 'zh-Hans' || localeStr == 'zh-Hant') {
      return Locale.fromSubtags(
          languageCode: 'zh', scriptCode: localeStr.split('-')[1]);
    }
    return Locale(localeStr);
  }

  // For saving to shared prefs
  int getIndex() {
    return language.index;
  }
}
