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
        name: 'dialog_cancel', desc: genericDesc);
  }

  String get close {
    return Intl.message('Close',
        name: 'dialog_close', desc: genericDesc);
  }

  String get confirm {
    return Intl.message('Confirm',
        name: 'dialog_confirm', desc: genericDesc);
  }

  String get no {
    return Intl.message('No',
        name: 'intro_new_wallet_backup_no', desc: genericDesc);
  }

  String get yes {
    return Intl.message('Yes',
        name: 'intro_new_wallet_backup_yes', desc: genericDesc);
  }

  String get send {
    return Intl.message('Send',
        name: 'home_send_cta', desc: genericDesc);
  }

  String get receive {
    return Intl.message('Receive',
        name: 'home_receive_cta', desc: genericDesc);
  }

  String get sent {
    return Intl.message('Sent',
        name: 'history_sent', desc: genericDesc);
  }

  String get received {
    return Intl.message('Received',
        name: 'history_received', desc: genericDesc);
  }

  String get transactions {
    return Intl.message('Transactions',
        name: 'transaction_header', desc: genericDesc);
  }

  String get addressCopied {
    return Intl.message('Address Copied',
        name: 'receive_copied', desc: genericDesc);
  }

  String get copyAddress {
    return Intl.message('Copy Address',
        name: 'receive_copy_cta', desc: genericDesc);
  }

  String get addressShare {
    return Intl.message('Share Address',
        name: 'share_address', desc: genericDesc);
  }

  String get addressHint {
    return Intl.message('Enter Address',
        name: 'send_address_hint', desc: genericDesc);
  }

  String get seed {
    return Intl.message('Seed',
      name: 'intro_new_wallet_seed_header', desc: 'Wallet seed - is not the same thing as a "private key", so do not substitute this with private key');
  }

  String get seedInvalid {
    return Intl.message('Seed is Invalid',
      name: 'intro_seed_invalid', desc: genericDesc);
  }

  String get seedCopied {
    return Intl.message('Seed Copied to Clipboard\nIt is pasteable for 2 minutes.',
      name: 'intro_new_wallet_seed_copied', desc: genericDesc);
  }

  String get scanQrCode {
    return Intl.message('Scan QR Code',
      name: 'send_scan_qr', desc: genericDesc);
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
      name: "transaction_details", desc: genericDesc);  
  }

  /// -- END GENERIC ITEMS

  /// -- CONTACT ITEMS
  static const String contactDesc = "Contact/Addresbook";
  String get removeContact {
    return Intl.message('Remove Contact',
        name: 'contact_remove_btn', desc: contactDesc);
  }

  String getRemoveContactConfirmation(String contactName) {
    return Intl.message('Are you sure you want to delete %1?',
      name: 'contact_remove_sure', desc: contactDesc).replaceFirst(r'%1', contactName);
  }

  String get contactHeader {
    return Intl.message('Contact',
      name: 'contact_view_header', desc: contactDesc);
  }

  String get contactsHeader {
    return Intl.message('Contacts',
      name: 'contact_header', desc: contactDesc);
  }

  String get addContact {
    return Intl.message('Add Contact',
        name: 'contact_add', desc: contactDesc);
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
      name: 'contact_export_none', desc: contactDesc);
  }

  String get noContactsImport {
    return Intl.message("No new contacts to import.",
      name: 'contact_import_none', desc: contactDesc);
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
        name: 'intro_new_wallet_seed_backup_header', desc: introDesc);
  }

  String get backupSeedConfirm {
    return Intl.message('Are you sure that you backed up your wallet seed?',
        name: 'intro_new_wallet_backup', desc: introDesc);
  }

  String get seedBackupInfo {
    return Intl.message("Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
        name: 'intro_new_wallet_seed', desc: introDesc);
  }

  String get importSeed {
    return Intl.message("Import seed",
        name: 'intro_seed_header', desc: introDesc);
  }

  String get importSeedHint {
    return Intl.message("Please enter your seed below.",
        name: 'intro_seed_info', desc: introDesc);
  }

  String get welcomeText {
    return Intl.message("Welcome to Kalium. To begin you may create a new wallet or import an existing one.",
        name: 'intro_welcome_title', desc: introDesc);
  }

  String get newWallet {
    return Intl.message("New Wallet",
        name: 'intro_welcome_new_wallet', desc: introDesc);
  }

  String get importWallet {
    return Intl.message("Import Wallet",
        name: 'intro_welcome_have_wallet', desc: introDesc);
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
        name: 'send_sending', desc: sendDesc);
  }

  String get to {
    return Intl.message("To",
        name: 'send_to', desc: sendDesc);
  }

  String get sendAmountConfirm {
    return Intl.message("Send %1 BANANO",
        name: 'send_pin_description', desc: sendDesc);
  }

  String get sendAmountConfirmPin {
    return sendAmountConfirm;
  }

  String get enterAmount {
    return Intl.message("Enter Amount",
      name: 'send_amount_hint', desc: sendDesc);
  }

  String get enterAddress {
    return Intl.message("Enter Address",
      name: 'enter_address', desc: sendDesc);
  }

  String get invalidAddress {
    return Intl.message("Address entered was invalid",
      name: 'send_invalid_address', desc: sendDesc);
  }

  String get addressMising {
    return Intl.message("Please Enter an Address",
      name: 'send_enter_address', desc: sendDesc);
  }
  
  String get amountMissing {
    return Intl.message("Please Enter an Amount",
      name: 'send_enter_amount', desc: sendDesc);
  }
  
  String get insufficientBalance {
    return Intl.message("Insufficient Balance",
      name: 'send_insufficient_balance', desc: sendDesc);
  }

  String get sendFrom {
    return Intl.message("Send From",
      name: 'send_title', desc: sendDesc);
  }
  /// -- END SEND ITEMS

  /// -- PIN SCREEN
  String pinDesc = "Used on PIN screen";

  String get pinCreateTitle {
    return Intl.message("Create a 6-digit pin",
      name: 'pin_create_title', desc: settingsDesc);
  }

  String get pinConfirmTitle {
    return Intl.message("Confirm your pin",
      name: 'pin_confirm_title', desc: settingsDesc);
  }

  String get pinEnterTitle {
    return Intl.message("Enter pin",
      name: 'pin_enter_title', desc: settingsDesc);
  }

  String get pinConfirmError {
    return Intl.message("Pins do not match",
      name: 'pin_confirm_error', desc: settingsDesc);
  }

  String get pinInvalid {
    return Intl.message("Invalid pin entered",
      name: 'pin_error', desc: settingsDesc);
  }

  /// -- END PIN SCREEN

  /// -- SETTINGS ITEMS
  static const String settingsDesc = 'Uses in settings screens';

  String get changeRepButton {
    return Intl.message("Change",
      name: 'change_representative_change', desc: settingsDesc);
  }

  String get changeRepAuthenticate {
    return Intl.message("Change Representative",
      name: 'settings_change_rep', desc: settingsDesc);
  }

  String get currentlyRepresented {
    return Intl.message("Currently Represented By",
      name: 'change_representative_current_header', desc: settingsDesc);
  }

  String get changeRepSucces {
    return Intl.message("Representative Changed Successfully",
      name: 'change_representative_success', desc: settingsDesc);
  }

  String get repInfoHeader {
    return Intl.message("What is a representative?",
      name: 'change_representative_info_header', desc: settingsDesc);
  }
  
  String get repInfo {
    return Intl.message("A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy.",
      name: 'change_representative_info', desc: settingsDesc);
  }

  String get pinRepChange {
    return Intl.message("Enter PIN to change representative.",
      name: 'change_representative_pin', desc: settingsDesc);
  }

  String get changeRepHint {
    return Intl.message("Enter New Representative",
      name: 'change_representative_hint', desc: settingsDesc);
  }

  String get authMethod {
    return Intl.message("Authentication Method",
      name: 'settings_disable_fingerprint', desc: settingsDesc);
  }

  String get pinMethod {
    return Intl.message("PIN",
      name: 'settings_pin_method', desc: settingsDesc);
  }

  String get privacyPolicy {
    return Intl.message("Privacy Policy",
      name: 'settings_privacy_policy', desc: settingsDesc);
  }

  String get biometricsMethod {
    return Intl.message("Biometrics",
      name: 'settings_fingerprint_method', desc: settingsDesc);
  }

  String get changeCurrency {
    return Intl.message("Change Currency",
      name: 'settings_local_currency', desc: settingsDesc);
  }

  String get language {
    return Intl.message("Language",
      name: 'settings_change_language', desc: settingsDesc);
  }

  String get shareKalium {
    return Intl.message("Share Kalium",
      name: 'settings_share', desc: settingsDesc);
  }

  String get shareKaliumText {
    return Intl.message("Check out Kalium! Banano's official mobile wallet!",
      name: 'share_extra', desc: settingsDesc);
  }

  String get logout {
    return Intl.message("Logout",
      name: 'settings_logout', desc: settingsDesc);
  }

  String get warning {
    return Intl.message("Warning",
      name: 'settings_logout_alert_title', desc: settingsDesc);
  }

  String get logoutDetail {
    return Intl.message("Logging out will remove your seed and all Kalium-related data from this device. If your seed is not backed up, you will never be able to access your funds again",
      name: 'settings_logout_alert_message', desc: settingsDesc);
  }

  String get logoutAction {
    return Intl.message("Delete Seed and Logout",
      name: 'settings_logout_alert_confirm_cta', desc: settingsDesc);
  }

  String get logoutAreYouSure {
    return Intl.message("Are you sure?",
      name: 'settings_logout_warning_title', desc: settingsDesc);
  }

  String get logoutReassurance {
    return Intl.message("As long as you've backed up your seed you have nothing to worry about.",
      name: 'settings_logout_warning_message', desc: settingsDesc);
  }

  String get settingsHeader {
    return Intl.message("Settings",
      name: 'settings_title', desc: settingsDesc);
  }

  String get preferences {
    return Intl.message("Preferences",
      name: 'settings_preferences_header', desc: settingsDesc);
  }

  String get manage {
    return Intl.message("Manage",
      name: 'settings_manage_header', desc: settingsDesc);
  }

  String get backupSeed {
    return Intl.message("Backup Seed",
      name: 'settings_backup_seed', desc: settingsDesc);
  }

  String get fingerprintSeedBackup {
    return Intl.message("Authenticate to backup seed.",
      name: 'settings_fingerprint_title', desc: settingsDesc);
  }

  String get pinSeedBackup {
    return Intl.message("Enter PIN to Backup Seed",
      name: 'settings_pin_title', desc: settingsDesc);
  }

  String get systemDefault {
    return Intl.message("System Default",
      name: 'settings_default_language_string', desc: settingsDesc);
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
    return 'https://bananomonkeys.herokuapp.com/image?format=png&address=$account&size=$size';
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