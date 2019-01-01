import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';

class KaliumStyles {
  // Text style for paragraph text.
  static const TextStyleParagraph = TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w200,
                                      fontFamily: 'NunitoSans',
                                      color: KaliumColors.text);
  // Text style for primary button
  static const TextStyleButtonPrimary = TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w700,
                                          color: KaliumColors.background);
  // Text style for outline button
  static const TextStyleButtonPrimaryOutline = TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: KaliumColors.primary);
  // General address/seed styles
  static const TextStyleAddressPrimary60 = TextStyle(
                                    color: KaliumColors.primary60,
                                    fontSize: 14.0,
                                    height: 1.2,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'OverpassMono',
                                  );
  static const TextStyleAddressText60 = TextStyle(
                                          color: KaliumColors.text60,
                                          fontSize: 14.0,
                                          height: 1.2,
                                          fontWeight: FontWeight.w100,
                                          fontFamily: 'OverpassMono',
                                        );
  // Text style for alternate currencies on home page
  static const TextStyleCurrencyAlt = TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: KaliumColors.text60);
  // Text style for primary currency on home page
  static const TextStyleCurrency = TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w900,
                                      color: KaliumColors.primary);
  /* Transaction cards */
  // Text style for transaction card "Received"/"Sent" text
  static const TextStyleTransactionType = TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: KaliumColors.text);
  // Amount
  static const TextStyleTransactionAmount = TextStyle(
                                              color: KaliumColors.primary60,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600);
  // Unit (e.g. BAN)
  static const TextStyleTransactionUnit = TextStyle(
                                              color: KaliumColors.primary60,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w100,
                                            );
  // Address
  static const TextStyleTransactionAddress = TextStyle(
                                                fontSize: 11.0,
                                                fontFamily: 'OverpassMono',
                                                fontWeight: FontWeight.w100,
                                                color: KaliumColors.text60,
                                              );
  /* Settings */
  static const  TextStyleVersion = TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w100,
                                        color: KaliumColors.text60);
}