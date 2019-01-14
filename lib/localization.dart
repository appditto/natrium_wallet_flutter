import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

/// Localization
class KaliumLocalization {
  static Locale currentLocale = Locale('en', 'US');

  static Future<KaliumLocalization> load(Locale locale) {
    currentLocale = locale;
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new KaliumLocalization();
    });
  }

  static KaliumLocalization of(BuildContext context) {
    return Localizations.of<KaliumLocalization>(context, KaliumLocalization);
  }

  /// -- GENERIC ITEMS
  static const String genericDesc = "Frequently used actions";
  String get cancel {
    return Intl.message('Cancel',
        name: 'cancel', desc: genericDesc);
  }

  String get close {
    return Intl.message('Close',
        name: 'close', desc: genericDesc);
  }

  String get confirm {
    return Intl.message('Confirm',
        name: 'confirm', desc: genericDesc);
  }

  String get no {
    return Intl.message('No',
        name: 'no', desc: genericDesc);
  }

  String get yes {
    return Intl.message('Yes',
        name: 'yes', desc: genericDesc);
  }

  String get send {
    return Intl.message('Send',
        name: 'send', desc: genericDesc);
  }

  String get addressCopied {
    return Intl.message('Address Copied',
        name: 'address_copied_clipboard', desc: genericDesc);
  }

  String get copyAddress {
    return Intl.message('Copy Address',
        name: 'copy_address_clipboard', desc: genericDesc);
  }

  String get addressHint {
    return Intl.message('Enter Address',
        name: 'enter_address_hint', desc: genericDesc);
  }

  String get seed {
    return Intl.message('Seed',
      name: 'seed', desc: 'Wallet seed - is not the same thing as a "private key", so do not substitute this with private key');
  }

  String get seedInvalid {
    return Intl.message('Invalid Seed',
      name: 'seed_invalid', desc: genericDesc);
  }

  String get seedCopied {
    return Intl.message('Seed Copied to Clipboard',
      name: 'seed_copied', desc: genericDesc);
  }
  /// -- END GENERIC ITEMS

  /// -- CONTACT ITEMS
  static const String contactDesc = "Contact/Addresbook";
  String get removeContact {
    return Intl.message('Remove Contact',
        name: 'remove_contact', desc: contactDesc);
  }

  String getRemoveContactConfirmation(String contactName) {
    return Intl.message('Are you sure you want to delete %1?',
      name: 'remove_contact_confirm', desc: contactDesc).replaceFirst(r'%1', contactName);
  }

  String get contactHeader {
    return Intl.message('Contact',
      name: 'contact_header_singular', desc: contactDesc);
  }

  String get contactsHeader {
    return Intl.message('Contacts',
      name: 'contact_header_plural', desc: contactDesc);
  }

  String get addContact {
    return Intl.message('Add Contact',
        name: 'add_contact', desc: contactDesc);
  }

  String get contactNameHint {
    return Intl.message('Enter a Name @',
        name: 'contact_name_hint', desc: contactDesc);
  }
  /// -- END CONTACT ITEMS

  /// -- INTRO ITEMS
  static const String introDesc = "Introduction Screens";
  String get backupYourSeed {
    return Intl.message('Backup your seed',
        name: 'backup_ur_seed', desc: introDesc);
  }

  String get backupSeedConfirm {
    return Intl.message('Are you sure that you backed up your wallet seed?',
        name: 'backup_seed_confirm', desc: introDesc);
  }

  String get seedBackupInfo {
    return Intl.message("Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
        name: 'backup_seed_info', desc: introDesc);
  }

  String get importSeed {
    return Intl.message("Import seed",
        name: 'import_seed_header', desc: introDesc);
  }

  String get importSeedHint {
    return Intl.message("Please enter your seed below.",
        name: 'import_seed_hint', desc: introDesc);
  }

  String get welcomeText {
    return Intl.message("Welcome to Kalium. To begin you may create a new wallet or import an existing one.",
        name: 'welcome_text', desc: introDesc);
  }

  String get newWallet {
    return Intl.message("New Wallet",
        name: 'new_wallet_button', desc: introDesc);
  }

  String get importWallet {
    return Intl.message("Import Wallet",
        name: 'import_wallet_button', desc: introDesc);
  }
  /// -- END INTRO ITEMS

  /// -- NON-TRANSLATABLE ITEMS
  String getBlockExplorerUrl(String hash) {
    return 'https://creeper.banano.cc/explorer/block/$hash';
  }

  String getAccountExplorerUrl(String account) {
    return 'https://creeper.banano.cc/explorer/account/$account';
  }

  String getMonkeyDownloadUrl(String account) {
    return 'https://bananomonkeys.herokuapp.com/image?format=png&address=$account';
  }
  /// -- END NON-TRANSLATABLE ITEMS
}

class KaliumLocalizationsDelegate extends LocalizationsDelegate<KaliumLocalization> {
  const KaliumLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<KaliumLocalization> load(Locale locale) {
    return KaliumLocalization.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<KaliumLocalization> old) {
    return true;
  }
}