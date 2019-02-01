import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum AvailableCurrencyEnum { USD, AUD, BRL, CAD, CHF, CLP, CNY, CZK, DKK,
                  EUR, GBP, HKD, HUF, IDR, ILS, INR, JPY, KRW,
                  MXN, MYR, NOK, NZD, PHP, PKR, PLN, RUB, SEK,
                  SGD, THB, TRY, TWD, VES, ZAR }

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
      case "SEK":
          return "Swedish Krona";
      case "SGD":
          return "Singapore Dollar";
      case "THB":
          return "Thai Baht";
      case "TRY":
          return "Turkish Lira";
      case "TWD":
          return "Taiwan New Dollar";
      case "VES":
          return "Venezuelan Bolivar";
      case "ZAR":
          return "South African Rand";
      case "USD":
      default:
          return "US Dollar";
      }
  }

  String getCurrencySymbol() {
    switch (getIso4217Code()) {
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
      case "VES":
          return "VES";
      case "ZAR":
          return "R\$";
      case "USD":
      default:
          return "\$";
    }
  }

  Locale getLocale() {
    switch (getIso4217Code()) {
      case "AUD":
          return new Locale("en", "AU");
      case "BRL":
          return new Locale("pt", "BR");
      case "CAD":
          return new Locale("en", "CA");
      case "CHF":
          return new Locale("de", "CH");
      case "CLP":
          return new Locale("es", "CL");
      case "CNY":
          return new Locale("zh", "CN");
      case "CZK":
          return new Locale("cs", "CZ");
      case "DKK":
          return new Locale("da", "DK");
      case "EUR":
          return new Locale("fr", "FR");
      case "GBP":
          return new Locale("en", "GB");
      case "HKD":
          return new Locale("zh", "HK");
      case "HUF":
          return new Locale("hu", "HU");
      case "IDR":
          return new Locale("id", "ID");
      case "ILS":
          return new Locale("he", "IL");
      case "INR":
          return new Locale("hi", "IN");
      case "JPY":
          return new Locale("ja", "JP");
      case "KRW":
          return new Locale("ko", "KR");
      case "MXN":
          return new Locale("es", "MX");
      case "MYR":
          return new Locale("ta", "MY");
      case "NOK":
          return new Locale("nn", "NO");
      case "NZD":
          return new Locale("en", "NZ");
      case "PHP":
          return new Locale("tl", "PH");
      case "PKR":
          return new Locale("ur", "PK");
      case "PLN":
          return new Locale("pl", "PL");
      case "RUB":
          return new Locale("ru", "RU");
      case "SEK":
          return new Locale("sv", "SE");
      case "SGD":
          return new Locale("zh", "SG");
      case "THB":
          return new Locale("th", "TH");
      case "TRY":
          return new Locale("tr", "TR");
      case "TWD":
          return new Locale("en", "TW");
      case "VES":
          return new Locale("es", "VE");
      case "ZAR":
          return new Locale("en", "ZA");
      case "USD":
      default:
          return new Locale("en", "US");
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return currency.index;
  }

  // Get best currency for a given locale
  // Default to USD
  static AvailableCurrency getBestForLocale(Locale locale) {
    return AvailableCurrency(AvailableCurrencyEnum.USD);
    // TODO - Since adding KaliumLocalizations we only get language code in locale, not country code
    // Cause the below code to crash
    AvailableCurrencyEnum.values.forEach((value) {
      AvailableCurrency currency = AvailableCurrency(value);
      if (currency.getLocale().countryCode.toUpperCase() == locale.countryCode.toUpperCase()) {
        return currency;
      }
    });
    return AvailableCurrency(AvailableCurrencyEnum.USD);
  }
}