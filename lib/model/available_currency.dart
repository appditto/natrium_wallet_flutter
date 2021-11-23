import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum AvailableCurrencyEnum {
  USD,
  ARS,
  AUD,
  BRL,
  CAD,
  CHF,
  CLP,
  CNY,
  CZK,
  DKK,
  EUR,
  GBP,
  HKD,
  HUF,
  IDR,
  ILS,
  INR,
  JPY,
  KRW,
  KWD,
  MXN,
  MYR,
  NOK,
  NZD,
  PHP,
  PKR,
  PLN,
  RUB,
  SAR,
  SEK,
  SGD,
  THB,
  TRY,
  TWD,
  AED,
  VES,
  ZAR,
  UAH
}

/// Represent the available authentication methods our app supports
class AvailableCurrency extends SettingSelectionItem {
  AvailableCurrencyEnum currency;

  AvailableCurrency(this.currency);

  String getIso4217Code() {
    return currency.toString().split('.')[1];
  }

  String getDisplayName(BuildContext context) {
    return getCurrencySymbol() + " " + getDisplayNameNoSymbol();
  }

  String getDisplayNameNoSymbol() {
    switch (getIso4217Code()) {
      case "ARS":
        return "Argentine Peso";
      case "AUD":
        return "Australian Dollar";
      case "BRL":
        return "Brazilian Real";
      case "CAD":
        return "Canadian Dollar";
      case "CHF":
        return "Swiss Franc";
      case "CLP":
        return "Chilean Peso";
      case "CNY":
        return "Chinese Yuan";
      case "CZK":
        return "Czech Koruna";
      case "DKK":
        return "Danish Krone";
      case "EUR":
        return "Euro";
      case "GBP":
        return "Great Britain Pound";
      case "HKD":
        return "Hong Kong Dollar";
      case "HUF":
        return "Hungarian Forint";
      case "IDR":
        return "Indonesian Rupiah";
      case "ILS":
        return "Israeli Shekel";
      case "INR":
        return "Indian Rupee";
      case "JPY":
        return "Japanese Yen";
      case "KRW":
        return "South Korean Won";
      case "KWD":
        return "Kuwaiti Dinar";
      case "MXN":
        return "Mexican Peso";
      case "MYR":
        return "Malaysian Ringgit";
      case "NOK":
        return "Norwegian Krone";
      case "NZD":
        return "New Zealand Dollar";
      case "PHP":
        return "Philippine Peso";
      case "PKR":
        return "Pakistani Rupee";
      case "PLN":
        return "Polish Zloty";
      case "RUB":
        return "Russian Ruble";
      case "SAR":
        return "Saudi Riyal";
      case "SEK":
        return "Swedish Krona";
      case "SGD":
        return "Singapore Dollar";
      case "THB":
        return "Thai Baht";
      case "TRY":
        return "Turkish Lira";
      case "TWD":
        return "Taiwan Dollar";
      case "AED":
        return "UAE Dirham";
      case "VES":
        return "Venezuelan Bolivar";
      case "ZAR":
        return "South African Rand";
      case "UAH":
        return "Ukraine hryvnia";
      case "USD":
      default:
        return "US Dollar";
    }
  }

  String getCurrencySymbol() {
    switch (getIso4217Code()) {
      case "ARS":
        return "\$";
      case "AUD":
        return "\$";
      case "BRL":
        return "R\$";
      case "CAD":
        return "\$";
      case "CHF":
        return "CHF";
      case "CLP":
        return "\$";
      case "CNY":
        return "¥";
      case "CZK":
        return "Kč";
      case "DKK":
        return "kr.";
      case "EUR":
        return "€";
      case "GBP":
        return "£";
      case "HKD":
        return "HK\$";
      case "HUF":
        return "Ft";
      case "IDR":
        return "Rp";
      case "ILS":
        return "₪";
      case "INR":
        return "₹";
      case "JPY":
        return "¥";
      case "KRW":
        return "₩";
      case "KWD":
        return "KD";
      case "MXN":
        return "\$";
      case "MYR":
        return "RM";
      case "NOK":
        return "kr";
      case "NZD":
        return "\$";
      case "PHP":
        return "₱";
      case "PKR":
        return "Rs";
      case "PLN":
        return "zł";
      case "RUB":
        return "\u20BD";
      case "SAR":
        return "SR";
      case "SEK":
        return "kr";
      case "SGD":
        return "\$";
      case "THB":
        return "THB";
      case "TRY":
        return "₺";
      case "TWD":
        return "NT\$";
      case "AED":
        return "د.إ";
      case "VES":
        return "VES";
      case "ZAR":
        return "R";
      case "UAH":
        return "₴";
      case "USD":
      default:
        return "\$";
    }
  }

  Locale getLocale() {
    switch (getIso4217Code()) {
      case "ARS":
        return Locale("es", "AR");
      case "AUD":
        return Locale("en", "AU");
      case "BRL":
        return Locale("pt", "BR");
      case "CAD":
        return Locale("en", "CA");
      case "CHF":
        return Locale("de", "CH");
      case "CLP":
        return Locale("es", "CL");
      case "CNY":
        return Locale("zh", "CN");
      case "CZK":
        return Locale("cs", "CZ");
      case "DKK":
        return Locale("da", "DK");
      case "EUR":
        return Locale("fr", "FR");
      case "GBP":
        return Locale("en", "GB");
      case "HKD":
        return Locale("zh", "HK");
      case "HUF":
        return Locale("hu", "HU");
      case "IDR":
        return Locale("id", "ID");
      case "ILS":
        return Locale("he", "IL");
      case "INR":
        return Locale("hi", "IN");
      case "JPY":
        return Locale("ja", "JP");
      case "KRW":
        return Locale("ko", "KR");
      case "KWD":
        return Locale("ar", "KW");
      case "MXN":
        return Locale("es", "MX");
      case "MYR":
        return Locale("ta", "MY");
      case "NOK":
        return Locale("no", "NO");
      case "NZD":
        return Locale("en", "NZ");
      case "PHP":
        return Locale("tl", "PH");
      case "PKR":
        return Locale("ur", "PK");
      case "PLN":
        return Locale("pl", "PL");
      case "RUB":
        return Locale("ru", "RU");
      case "SAR":
        return Locale("ar", "SA");
      case "SEK":
        return Locale("sv", "SE");
      case "SGD":
        return Locale("zh", "SG");
      case "THB":
        return Locale("th", "TH");
      case "TRY":
        return Locale("tr", "TR");
      case "TWD":
        return Locale("en", "TW");
      case "AED":
        return Locale("ar", "AE");
      case "VES":
        return Locale("es", "VE");
      case "ZAR":
        return Locale("en", "ZA");
      case "UAH":
        return Locale("uk", "UA");
      case "USD":
      default:
        return Locale("en", "US");
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return currency.index;
  }

  // Get best currency for a given locale
  // Default to USD
  static AvailableCurrency getBestForLocale(Locale locale) {
    AvailableCurrencyEnum.values.forEach((value) {
      AvailableCurrency currency = AvailableCurrency(value);
      if (locale != null && locale.countryCode != null) {
        // Special cases
        if ([
          'AT',
          'BE',
          'CY',
          'EE',
          'FI',
          'FR',
          'DE',
          'GR',
          'IE',
          'IT',
          'LV',
          'LT',
          'LU',
          'MT',
          'NL',
          'PT',
          'SK',
          'SI',
          'ES'
        ].contains(locale.countryCode)) {
          return AvailableCurrency(AvailableCurrencyEnum.EUR);
        } else if (currency.getLocale().countryCode.toUpperCase() ==
            locale.countryCode.toUpperCase()) {
          return currency;
        }
      }
    });
    return AvailableCurrency(AvailableCurrencyEnum.USD);
  }
}
