import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/colors.dart';

class AppStyles {
  // Text style for paragraph text.
  static const TextStyleParagraph = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.medium,
      fontWeight: FontWeight.w200,
      color: AppColors.text);
  // Text style for paragraph text with primary color.
  static const TextStyleParagraphPrimary = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.medium,
      fontWeight: FontWeight.w700,
      color: AppColors.primary);
  // Text style for paragraph text with primary color.
  static const TextStyleParagraphSuccess = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.medium,
      fontWeight: FontWeight.w700,
      color: AppColors.success);
  // For snackbar/Toast text
  static const TextStyleSnackbar = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.small,
      fontWeight: FontWeight.w700,
      color: AppColors.background);
  // Text style for primary button
  static const TextStyleButtonPrimary = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._large,
      fontWeight: FontWeight.w700,
      color: AppColors.background);
  // Green primary button
  static const TextStyleButtonPrimaryGreen = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._large,
      fontWeight: FontWeight.w700,
      color: AppColors.greenDark);
  // Text style for outline button
  static const TextStyleButtonPrimaryOutline = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._large,
      fontWeight: FontWeight.w700,
      color: AppColors.primary);
  static const TextStyleButtonPrimaryOutlineDisabled = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._large,
      fontWeight: FontWeight.w700,
      color: AppColors.primary60);
  // Text style for success outline button
  static const TextStyleButtonSuccessOutline = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._large,
      fontWeight: FontWeight.w700,
      color: AppColors.success);
  // Text style for text outline button
  static const TextStyleButtonTextOutline = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._large,
      fontWeight: FontWeight.w700,
      color: AppColors.text);
  // General address/seed styles
  static const TextStyleAddressPrimary60 = TextStyle(
    color: AppColors.primary60,
    fontSize: AppFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );
  static const TextStyleAddressPrimary = TextStyle(
    color: AppColors.primary,
    fontSize: AppFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );

  static const TextStyleAddressSuccess = TextStyle(
    color: AppColors.success,
    fontSize: AppFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );
  static const TextStyleAddressText60 = TextStyle(
    color: AppColors.text60,
    fontSize: AppFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );
  static const TextStyleAddressText90 = TextStyle(
    color: AppColors.white90,
    fontSize: AppFontSizes.small,
    height: 1.2,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
  );
  // Text style for alternate currencies on home page
  static const TextStyleCurrencyAlt = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.small,
      fontWeight: FontWeight.w600,
      color: AppColors.text60);
  static const TextStyleCurrencyAltHidden = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.small,
      fontWeight: FontWeight.w600,
      color: Colors.transparent);
  // Text style for primary currency on home page
  static const TextStyleCurrency = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._largest,
      fontWeight: FontWeight.w900,
      color: AppColors.primary);
  /* Transaction cards */
  // Text style for transaction card "Received"/"Sent" text
  static const TextStyleTransactionType = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.small,
      fontWeight: FontWeight.w600,
      color: AppColors.text);
  // Amount
  static const TextStyleTransactionAmount = TextStyle(
      fontFamily: "NunitoSans",
      color: AppColors.primary60,
      fontSize: AppFontSizes.smallest,
      fontWeight: FontWeight.w600);
  // Unit (e.g. BAN)
  static const TextStyleTransactionUnit = TextStyle(
    fontFamily: "NunitoSans",
    color: AppColors.primary60,
    fontSize: AppFontSizes.smallest,
    fontWeight: FontWeight.w100,
  );
  // Address
  static const TextStyleTransactionAddress = TextStyle(
    fontSize: AppFontSizes.smallest,
    fontFamily: 'OverpassMono',
    fontWeight: FontWeight.w100,
    color: AppColors.text60,
  );
  // Transaction Welcome
  static const TextStyleTransactionWelcome = TextStyle(
    fontSize: AppFontSizes.small,
    fontWeight: FontWeight.w200,
    color: AppColors.text,
    fontFamily: 'NunitoSans',
  );
  // Transaction Welcome Text
  static const TextStyleTransactionWelcomePrimary = TextStyle(
    fontSize: AppFontSizes.small,
    fontWeight: FontWeight.w200,
    color: AppColors.primary,
    fontFamily: 'NunitoSans',
  );
  // Version info in settings
  static const TextStyleVersion = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.small,
      fontWeight: FontWeight.w100,
      color: AppColors.text60);
  static const TextStyleVersionUnderline = TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.small,
      fontWeight: FontWeight.w100,
      color: AppColors.text60,
      decoration: TextDecoration.underline);
  // Text style for alert dialog header
  static const TextStyleDialogHeader = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes._large,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  // Text style for dialog options
  static const TextStyleDialogOptions = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.medium,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
  // Text style for dialog button text
  static const TextStyleDialogButtonText = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.smallest,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  // Text style for seed text
  static const TextStyleSeed = TextStyle(
    fontSize: AppFontSizes.small,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
    color: AppColors.primary,
    height: 1.3,
    letterSpacing: 1,
  );
  static const TextStyleSeedGray = TextStyle(
    fontSize: AppFontSizes.small,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
    color: AppColors.text60,
    height: 1.3,
    letterSpacing: 1,
  );
  static const TextStyleSeedGreen = TextStyle(
    fontSize: AppFontSizes.small,
    fontWeight: FontWeight.w100,
    fontFamily: 'OverpassMono',
    color: AppColors.green,
    height: 1.3,
    letterSpacing: 1,
  );
  // Text style for general headers like sheet headers
  static TextStyle textStyleHeader(BuildContext context) {
    return TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes.largest(context),
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    );
  }

  // Text style for settings headers
  static TextStyle textStyleSettingsHeader() {
    return TextStyle(
      fontFamily: "NunitoSans",
      fontSize: AppFontSizes._largest,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    );
  }

  // Text style for primary color header
  static const TextStyleHeaderColored = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes._largest,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  // Text style for primary color header
  static const TextStyleHeader2Colored = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.larger,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  static const TextStylePinScreenHeaderColored = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes._large,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  // Text style for setting item header
  static const TextStyleSettingItemHeader = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.medium,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
  static const TextStyleSettingItemHeader60 = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.medium,
    fontWeight: FontWeight.w600,
    color: AppColors.text60,
  );
  static const TextStyleSettingItemHeader45 = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.medium,
    fontWeight: FontWeight.w600,
    color: AppColors.text45,
  );
  // Text style for setting item subheader
  static const TextStyleSettingItemSubheader = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.smallest,
    fontWeight: FontWeight.w100,
    color: AppColors.text60,
  );
  static const TextStyleSettingItemSubheader30 = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: AppFontSizes.smallest,
    fontWeight: FontWeight.w100,
    color: AppColors.text30,
  );

  // Text style for lock screen error
  static const TextStyleErrorMedium = TextStyle(
    fontSize: AppFontSizes.small,
    color: AppColors.primary,
    fontFamily: 'NunitoSans',
    fontWeight: FontWeight.w600,
  );
}

class AppFontSizes {
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

bool smallScreen(BuildContext context) {
  if (MediaQuery.of(context).size.height < 667)
    return true;
  else
    return false;
}
