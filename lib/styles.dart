import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';

class KaliumStyles {
  // Text style for paragraph text.
  static const TextStyleParagraph = TextStyle(
                                      fontSize: KaliumFontSizes.medium,
                                      fontWeight: FontWeight.w200,
                                      color: KaliumColors.text);
  // Text style for primary button
  static const TextStyleButtonPrimary = TextStyle(
                                          fontSize: KaliumFontSizes.large,
                                          fontWeight: FontWeight.w700,
                                          color: KaliumColors.background);
  // Text style for outline button
  static const TextStyleButtonPrimaryOutline = TextStyle(
                                                  fontSize: KaliumFontSizes.large,
                                                  fontWeight: FontWeight.w700,
                                                  color: KaliumColors.primary);
  // General address/seed styles
  static const TextStyleAddressPrimary60 = TextStyle(
                                    color: KaliumColors.primary60,
                                    fontSize: KaliumFontSizes.small,
                                    height: 1.2,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'OverpassMono',
                                  );
  static const TextStyleAddressText60 = TextStyle(
                                          color: KaliumColors.text60,
                                          fontSize: KaliumFontSizes.small,
                                          height: 1.2,
                                          fontWeight: FontWeight.w100,
                                          fontFamily: 'OverpassMono',
                                        );
  // Text style for alternate currencies on home page
  static const TextStyleCurrencyAlt = TextStyle(
                                        fontSize: KaliumFontSizes.small,
                                        fontWeight: FontWeight.w600,
                                        color: KaliumColors.text60);
  // Text style for primary currency on home page
  static const TextStyleCurrency = TextStyle(
                                      fontSize: KaliumFontSizes.largest,
                                      fontWeight: FontWeight.w900,
                                      color: KaliumColors.primary);
  /* Transaction cards */
  // Text style for transaction card "Received"/"Sent" text
  static const TextStyleTransactionType = TextStyle(
                                            fontSize: KaliumFontSizes.small,
                                            fontWeight: FontWeight.w600,
                                            color: KaliumColors.text);
  // Amount
  static const TextStyleTransactionAmount = TextStyle(
                                              color: KaliumColors.primary60,
                                              fontSize: KaliumFontSizes.smallest,
                                              fontWeight: FontWeight.w600);
  // Unit (e.g. BAN)
  static const TextStyleTransactionUnit = TextStyle(
                                              color: KaliumColors.primary60,
                                              fontSize: KaliumFontSizes.smallest,
                                              fontWeight: FontWeight.w100,
                                            );
  // Address
  static const TextStyleTransactionAddress = TextStyle(
                                                fontSize: KaliumFontSizes.smallest,
                                                fontFamily: 'OverpassMono',
                                                fontWeight: FontWeight.w100,
                                                color: KaliumColors.text60,
                                              );
  /* Settings */
  static const  TextStyleVersion = TextStyle(
                                        fontSize: KaliumFontSizes.small,
                                        fontWeight: FontWeight.w100,
                                        color: KaliumColors.text60);
  // Text style for alert dialog header
  static const TextStyleDialogHeader = TextStyle(
                                                  fontSize: KaliumFontSizes.large,
                                                  fontWeight: FontWeight.w700,
                                                  color: KaliumColors.primary,
                                                  );
  // Text style for dialog button text
  static const TextStyleDialogButtonText = TextStyle(
                                                  fontSize: KaliumFontSizes.smallest,
                                                  fontWeight: FontWeight.w600,
                                                  color: KaliumColors.primary,
                                                  );
  // Text style seed text
  static const TextStyleSeed = TextStyle(
                                                  fontSize: KaliumFontSizes.small,
                                                  fontWeight: FontWeight.w100,
                                                  fontFamily: 'OverpassMono',
                                                  color: KaliumColors.primary,
                                                  );
  // Text style seed text
  static const TextStyleHeader = TextStyle(
                                                  fontSize: KaliumFontSizes.largest,
                                                  fontWeight: FontWeight.w700,
                                                  color: KaliumColors.text,
                                                  );

}

class KaliumFontSizes {
  static const smallest = 12.0;
  static const small = 14.0;
  static const medium = 16.0;
  static const large = 20.0;
  static const largest = 30.0;
}


