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

  String get receive {
    return Intl.message('Receive',
        name: 'receive', desc: genericDesc);
  }

  String get sent {
    return Intl.message('Sent',
        name: 'sent', desc: genericDesc);
  }

  String get received {
    return Intl.message('Received',
        name: 'received', desc: genericDesc);
  }

  String get transactions {
    return Intl.message('Transactions',
        name: 'transactions', desc: genericDesc);
  }

  String get addressCopied {
    return Intl.message('Address Copied',
        name: 'address_copied_clipboard', desc: genericDesc);
  }

  String get copyAddress {
    return Intl.message('Copy Address',
        name: 'copy_address_clipboard', desc: genericDesc);
  }

  String get addressShare {
    return Intl.message('Share Address',
        name: 'share_address', desc: genericDesc);
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

  String get scanQrCode {
    return Intl.message('Scan QR Code',
      name: 'scan_qr_code', desc: genericDesc);
  }

  String get fileReadErr {
    return Intl.message("Couldn't read file",
      name: "file_error", desc: genericDesc);
  }

  String get fileParseErr {
    return Intl.message("Couldn't parse file",
      name: "file_parse_error", desc: genericDesc);  
  }

  String get viewDetails {
    return Intl.message("View Details",
      name: "view_details", desc: genericDesc);  
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

  String get contactInvalid {
    return Intl.message("Invalid Contact",
      name: 'contact_invalid', desc: contactDesc);
  }

  String get noContactsExport {
    return Intl.message("There's no contacts to export.",
      name: 'contacts_none_export', desc: contactDesc);
  }

  String get noContactsImport {
    return Intl.message("No new contacts to import.",
      name: 'contacts_none_import', desc: contactDesc);
  }

  String get contactsImportSuccess {
    return Intl.message("Sucessfully imported %1 contacts.",
      name: 'contacts_import_success', desc: contactDesc);
  }

  String get contactAdded {
    return Intl.message("%1 added to contacts.",
      name: 'contact_added', desc: contactDesc);
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

  /// -- SEND ITEMS
  static const String sendDesc = "Used on send-related screens";

  String get sentTo {
    return Intl.message("Sent To",
        name: 'sent_to', desc: sendDesc);
  }

  String get sending {
    return Intl.message("Sending",
        name: 'sending', desc: sendDesc);
  }

  String get to {
    return Intl.message("To",
        name: 'to', desc: sendDesc);
  }

  String get sendAmountConfirm {
    return Intl.message("Send %1 BANANO",
        name: 'send_amount_banano', desc: sendDesc);
  }

  String get sendAmountConfirmPin {
    return Intl.message("Enter PIN to send %1 BANANO",
        name: 'send_amount_banano', desc: sendDesc);
  }

  String get enterAmount {
    return Intl.message("Enter Amount",
      name: 'enter_amount', desc: sendDesc);
  }

  String get enterAddress {
    return Intl.message("Enter Address",
      name: 'enter_address', desc: sendDesc);
  }

  String get invalidAddress {
    return Intl.message("Address entered was invalid",
      name: 'address_invalid', desc: sendDesc);
  }

  String get addressMising {
    return Intl.message("Please Enter an Address",
      name: 'address_missing', desc: sendDesc);
  }
  
  String get amountMissing {
    return Intl.message("Please Enter an Amount",
      name: 'amount_missing', desc: sendDesc);
  }
  
  String get insufficientBalance {
    return Intl.message("Insufficient Balance",
      name: 'balance_insufficient', desc: sendDesc);
  }

  String get sendFrom {
    return Intl.message("Send From",
      name: 'send_from', desc: sendDesc);
  }
  /// -- END SEND ITEMS

  /// -- SETTINGS ITEMS
  static const String settingsDesc = 'Uses in settings screens';

  String get changeRepButton {
    return Intl.message("Change",
      name: 'change_rep_button', desc: settingsDesc);
  }

  String get changeRepAuthenticate {
    return Intl.message("Change Representative",
      name: 'change_rep', desc: settingsDesc);
  }

  String get changeRepSucces {
    return Intl.message("Representative Changed Successfully",
      name: 'change_rep_success', desc: settingsDesc);
  }

  String get repInfoHeader {
    return Intl.message("What is a representative?",
      name: 'rep_info_header', desc: settingsDesc);
  }
  
  String get repInfo {
    return Intl.message("A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy.",
      name: 'rep_details', desc: settingsDesc);
  }

  String get pinRepChange {
    return Intl.message("Enter PIN to change representative.",
      name: 'change_rep_pin', desc: settingsDesc);
  }

  String get authMethod {
    return Intl.message("Authentication Method",
      name: 'auth_method', desc: settingsDesc);
  }

  String get pinMethod {
    return Intl.message("PIN",
      name: 'pin_method', desc: settingsDesc);
  }

  String get biometricsMethod {
    return Intl.message("Biometrics",
      name: 'biometrics_method', desc: settingsDesc);
  }

  String get changeCurrency {
    return Intl.message("Change Currency",
      name: 'change_currency', desc: settingsDesc);
  }

  String get language {
    return Intl.message("Language",
      name: 'change_language', desc: settingsDesc);
  }

  String get shareKalium {
    return Intl.message("Share Kalium",
      name: 'share_kalium', desc: settingsDesc);
  }

  String get shareKaliumText {
    return Intl.message("Check out Kalium! Banano's official mobile wallet!",
      name: 'share_kalium_text', desc: settingsDesc);
  }

  String get logout {
    return Intl.message("Logout",
      name: 'logout', desc: settingsDesc);
  }

  String get warning {
    return Intl.message("Warning",
      name: 'warning', desc: settingsDesc);
  }

  String get logoutDetail {
    return Intl.message("Logging out will remove your seed and all Kalium-related data from this device. If your seed is not backed up, you will never be able to access your funds again",
      name: 'logout_detail', desc: settingsDesc);
  }

  String get logoutAction {
    return Intl.message("Delete Seed and Logout",
      name: 'logout_action', desc: settingsDesc);
  }

  String get logoutAreYouSure {
    return Intl.message("Are you sure?",
      name: 'logout_sure', desc: settingsDesc);
  }

  String get logoutReassurance {
    return Intl.message("As long as you've backed up your seed you have nothing to worry about.",
      name: 'logout_sure', desc: settingsDesc);
  }

  String get settingsHeader {
    return Intl.message("Settings",
      name: 'settings_header', desc: settingsDesc);
  }

  String get preferences {
    return Intl.message("Preferences",
      name: 'preferences', desc: settingsDesc);
  }

  String get manage {
    return Intl.message("Manage",
      name: 'manage', desc: settingsDesc);
  }

  String get backupSeed {
    return Intl.message("Backup Seed",
      name: 'backup_seed', desc: settingsDesc);
  }

  String get fingerprintSeedBackup {
    return Intl.message("Authenticate to backup seed.",
      name: 'auth_seed_backup', desc: settingsDesc);
  }

  String get pinSeedBackup {
    return Intl.message("Enter PIN to Backup Seed",
      name: 'pin_seed_backup', desc: settingsDesc);
  }

  String get systemDefault {
    return Intl.message("System Default",
      name: 'system_default', desc: settingsDesc);
  }

  /// -- END SETTINGS ITEMS

  /// -- NON-TRANSLATABLE ITEMS
  String getBlockExplorerUrl(String hash) {
    return 'https://creeper.banano.cc/explorer/block/$hash';
  }

  String getAccountExplorerUrl(String account) {
    return 'https://creeper.banano.cc/explorer/account/$account';
  }

  String getMonkeyDownloadUrl(String account, { int size = 1000 }) {
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