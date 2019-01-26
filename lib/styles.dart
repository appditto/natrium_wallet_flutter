import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';

class KaliumStyles {
  // Text style for paragraph text.
  static const TextStyleParagraph = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.medium,
      fontWeight: FontWeight.w200,
      color: KaliumColors.text);
  // Text style for paragraph text with primary color.
  static const TextStyleParagraphPrimary = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.medium,
      fontWeight: FontWeight.w700,
      color: KaliumColors.primary);
  // Text style for paragraph text with primary color.
  static const TextStyleParagraphSuccess = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.medium,
      fontWeight: FontWeight.w700,
      color: KaliumColors.success);
  // For snackbar/Toast text
  static const TextStyleSnackbar = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.small,
      fontWeight: FontWeight.w700,
      color: KaliumColors.background);
  // Text style for primary button
  static const TextStyleButtonPrimary = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._large,
      fontWeight: FontWeight.w700,
      color: KaliumColors.background);
  // Green primary button
  static const TextStyleButtonPrimaryGreen = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._large,
      fontWeight: FontWeight.w700,
      color: KaliumColors.greenDark);
  // Text style for outline button
  static const TextStyleButtonPrimaryOutline = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._large,
      fontWeight: FontWeight.w700,
      color: KaliumColors.primary);
  static const TextStyleButtonPrimaryOutlineDisabled = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._large,
      fontWeight: FontWeight.w700,
      color: KaliumColors.primary60);
  // Text style for success outline button
  static const TextStyleButtonSuccessOutline = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._large,
      fontWeight: FontWeight.w700,
      color: KaliumColors.success);
  // Text style for text outline button
  static const TextStyleButtonTextOutline = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._large,
      fontWeight: FontWeight.w700,
      color: KaliumColors.text);
  // General address/seed styles
  static const TextStyleAddressPrimary60 = TextStyle(
    color: KaliumColors.primary60,
    fontSize: KaliumFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );
  static const TextStyleAddressPrimary = TextStyle(
    color: KaliumColors.primary,
    fontSize: KaliumFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );

  static const TextStyleAddressSuccess = TextStyle(
    color: KaliumColors.success,
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
  static const TextStyleAddressText90 = TextStyle(
    color: KaliumColors.white90,
    fontSize: KaliumFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );
  // Text style for alternate currencies on home page
  static const TextStyleCurrencyAlt = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.small,
      fontWeight: FontWeight.w600,
      color: KaliumColors.text60);
  static const TextStyleCurrencyAltHidden = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.small,
      fontWeight: FontWeight.w600,
      color: Colors.transparent);
  // Text style for primary currency on home page
  static const TextStyleCurrency = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._largest,
      fontWeight: FontWeight.w900,
      color: KaliumColors.primary);
  /* Transaction cards */
  // Text style for transaction card "Received"/"Sent" text
  static const TextStyleTransactionType = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.small,
      fontWeight: FontWeight.w600,
      color: KaliumColors.text);
  // Amount
  static const TextStyleTransactionAmount = TextStyle(
      fontFamily: "NunitoSans",
      color: KaliumColors.primary60,
      fontSize: KaliumFontSizes.smallest,
      fontWeight: FontWeight.w600);
  // Unit (e.g. BAN)
  static const TextStyleTransactionUnit = TextStyle(
    fontFamily: "NunitoSans",
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
  // Transaction Welcome
  static const TextStyleTransactionWelcome = TextStyle(
    fontSize: KaliumFontSizes.small,
    fontWeight: FontWeight.w200,
    color: KaliumColors.text,
    fontFamily: 'NunitoSans',
  );
  // Transaction Welcome "BANANO" Text
  static const TextStyleTransactionWelcomePrimary = TextStyle(
    fontSize: KaliumFontSizes.small,
    fontWeight: FontWeight.w200,
    color: KaliumColors.primary,
    fontFamily: 'NunitoSans',
  );
  // Version info in settings
  static const TextStyleVersion = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.small,
      fontWeight: FontWeight.w100,
      color: KaliumColors.text60);
  // Text style for alert dialog header
  static const TextStyleDialogHeader = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes._large,
    fontWeight: FontWeight.w700,
    color: KaliumColors.primary,
  );
  // Text style for dialog options
  static const TextStyleDialogOptions = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes.medium,
    fontWeight: FontWeight.w600,
    color: KaliumColors.text,
  );
  // Text style for dialog button text
  static const TextStyleDialogButtonText = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes.smallest,
    fontWeight: FontWeight.w600,
    color: KaliumColors.primary,
  );
  // Text style for seed text
  static const TextStyleSeed = TextStyle(
    fontSize: KaliumFontSizes.small,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
    color: KaliumColors.primary,
    height: 1.3,
  );
  // Text style for seed text
  static const TextStyleSeedHidden = TextStyle(
    fontSize: KaliumFontSizes.smallest,
    fontWeight: FontWeight.w100,
    fontFamily: 'KaliumIcons',
    color: KaliumColors.primary,
    height: 1.3,
  );
  static const TextStyleSeedGray = TextStyle(
    fontSize: KaliumFontSizes.small,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
    color: KaliumColors.text60,
    height: 1.3,
  );
  static const TextStyleSeedGreen = TextStyle(
    fontSize: KaliumFontSizes.small,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
    color: KaliumColors.green,
    height: 1.3,
  );
  // Text style for general headers like sheet headers
  static TextStyle textStyleHeader(BuildContext context) {
    return TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes.largest(context),
      fontWeight: FontWeight.w700,
      color: KaliumColors.text,
    );
  }
  // Text style for settings headers
  static TextStyle textStyleSettingsHeader() {
    return TextStyle(
      fontFamily: "NunitoSans",
      fontSize: KaliumFontSizes._largest,
      fontWeight: FontWeight.w700,
      color: KaliumColors.text,
    );
  }

  // Text style for primary color header
  static const TextStyleHeaderColored = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes._largest,
    fontWeight: FontWeight.w700,
    color: KaliumColors.primary,
  );
  // Text style for primary color header
  static const TextStyleHeader2Colored = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes.larger,
    fontWeight: FontWeight.w700,
    color: KaliumColors.primary,
  );
  static const TextStylePinScreenHeaderColored = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes._large,
    fontWeight: FontWeight.w700,
    color: KaliumColors.primary,
  );
  // Text style for setting item header
  static const TextStyleSettingItemHeader = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes.medium,
    fontWeight: FontWeight.w600,
    color: KaliumColors.text,
  );
  // Text style for setting item subheader
  static const TextStyleSettingItemSubheader = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: KaliumFontSizes.smallest,
    fontWeight: FontWeight.w100,
    color: KaliumColors.text60,
  );
}

class KaliumFontSizes {
  static const smallest = 12.0;
  static const small = 14.0;
  static const medium = 16.0;
  static const _large = 20.0;
  static const larger = 24.0;
  static const _largest = 28.0;
  static const largestc = 28.0;
  static const _sslarge = 18.0;
  static const _sslargest = 22.0;
  static double largest(context) {
    if (smallScreen(context)) {
      return _sslargest;
    }
    return _largest;
  }
  static double large(context) {
    if (smallScreen(context)) {
      return _sslarge;
    }
    return _large;
  }
}

bool smallScreen(BuildContext context){
  if(MediaQuery.of(context).size.height<667)
    return true;
  else return false;
}
