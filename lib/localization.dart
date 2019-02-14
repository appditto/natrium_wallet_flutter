import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:natrium_wallet_flutter/model/available_language.dart';

import 'l10n/messages_all.dart';

/// Localization
class AppLocalization {
  static Locale currentLocale = Locale('en', 'US');

  static Future<AppLocalization> load(Locale locale) {
    currentLocale = locale;
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalization();
    });
  }

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  /// -- GENERIC ITEMS
  String get cancel {
    return Intl.message('Cancel',
        desc: 'dialog_cancel', name: 'cancel');
  }

  String get close {
    return Intl.message('Close',
        desc: 'dialog_close', name: 'close');
  }

  String get confirm {
    return Intl.message('Confirm',
        desc: 'dialog_confirm', name: 'confirm');
  }

  String get no {
    return Intl.message('No',
        desc: 'intro_new_wallet_backup_no', name: 'no');
  }

  String get yes {
    return Intl.message('Yes',
        desc: 'intro_new_wallet_backup_yes', name: 'yes');
  }

  String get onStr {
    return Intl.message('On',
        desc: 'generic_on', name: 'onStr');
  }

  String get off {
    return Intl.message('Off',
        desc: 'generic_off', name: 'off');
  }

  String get send {
    return Intl.message('Send',
        desc: 'home_send_cta', name: 'send');
  }

  String get receive {
    return Intl.message('Receive',
        desc: 'home_receive_cta', name: 'receive');
  }

  String get sent {
    return Intl.message('Sent',
        desc: 'history_sent', name: 'sent');
  }

  String get received {
    return Intl.message('Received',
        desc: 'history_received', name: 'received');
  }

  String get transactions {
    return Intl.message('Transactions',
        desc: 'transaction_header', name: 'transactions');
  }

  String get addressCopied {
    return Intl.message('Address Copied',
        desc: 'receive_copied', name: 'addressCopied');
  }

  String get copyAddress {
    return Intl.message('Copy Address',
        desc: 'receive_copy_cta', name: 'copyAddress');
  }

  String get addressShare {
    return Intl.message('Share Address',
        desc: 'receive_share_cta', name: 'addressShare');
  }

  String get addressHint {
    return Intl.message('Enter Address',
        desc: 'send_address_hint', name: 'addressHint');
  }

  String get seed {
    return Intl.message('Seed',
      desc: 'intro_new_wallet_seed_header', name: 'seed');
  }

  String get seedInvalid {
    return Intl.message('Seed is Invalid',
      desc: 'intro_seed_invalid', name: 'seedInvalid');
  }

  String get seedCopied {
    return Intl.message('Seed Copied to Clipboard\nIt is pasteable for 2 minutes.',
      desc: 'intro_new_wallet_seed_copied', name: 'seedCopied');
  }

  String get scanQrCode {
    return Intl.message('Scan QR Code',
      desc: 'send_scan_qr', name: 'scanQrCode');
  }

  String get contactsImportErr {
    return Intl.message('Failed to import contacts',
      desc: 'contact_import_error', name: 'contactsImportErr');
  }

  String get viewDetails {
    return Intl.message("View Details",
      desc: "transaction_details", name: 'viewDetails');  
  }

  String get qrInvalidSeed {
    return Intl.message("QR code does not contain a valid seed or private key",
      desc: "qr_invalid_seed", name: 'qrInvalidSeed');
  }

  String get qrInvalidAddress {
    return Intl.message("QR code does not contain a valid address",
      desc: "qr_invalid_address", name: 'qrInvalidAddress');
  }

  /// -- END GENERIC ITEMS

  /// -- CONTACT ITEMS

  String get removeContact {
    return Intl.message('Remove Contact',
        desc: 'contact_remove_btn', name: 'removeContact');
  }

  String get removeContactConfirmation {
    return Intl.message('Are you sure you want to delete %1?',
      desc: 'contact_remove_sure', name: 'removeContactConfirmation');
  }

  String get contactHeader {
    return Intl.message('Contact',
      desc: 'contact_view_header', name: 'contactHeader');
  }

  String get contactsHeader {
    return Intl.message('Contacts',
      desc: 'contact_header', name: 'contactsHeader');
  }

  String get addContact {
    return Intl.message('Add Contact',
        desc: 'contact_add_button', name: 'addContact');
  }

  String get contactNameHint {
    return Intl.message('Enter a Name @',
        desc: 'contact_name_hint', name: 'contactNameHint');
  }

  String get contactInvalid {
    return Intl.message("Invalid Contact Name",
      desc: 'contact_invalid_name', name: 'contactInvalid');
  }

  String get noContactsExport {
    return Intl.message("There's no contacts to export.",
      desc: 'contact_export_none', name: 'noContactsExport');
  }

  String get noContactsImport {
    return Intl.message("No new contacts to import.",
      desc: 'contact_import_none', name: 'noContactsImport');
  }

  String get contactsImportSuccess {
    return Intl.message("Sucessfully imported %1 contacts.",
      desc: 'contact_import_success', name: 'contactsImportSuccess');
  }

  String get contactAdded {
    return Intl.message("%1 added to contacts.",
      desc: 'contact_added', name: 'contactAdded');
  }

  String get contactRemoved {
    return Intl.message("%1 has been removed from contacts!",
      desc: 'contact_removed', name: 'contactRemoved');
  }

  String get contactNameMissing {
    return Intl.message("Choose a Name for this Contact",
      desc: 'contact_name_missing', name: 'contactNameMissing');
  }

  String get contactExists {
    return Intl.message("Contact Already Exists",
      desc: 'contact_name_exists', name: 'contactExists');
  }

  /// -- END CONTACT ITEMS

  /// -- INTRO ITEMS
  String get backupYourSeed {
    return Intl.message('Backup your seed',
        desc: 'intro_new_wallet_seed_backup_header', name: 'backupYourSeed');
  }

  String get backupSeedConfirm {
    return Intl.message('Are you sure that you backed up your wallet seed?',
        desc: 'intro_new_wallet_backup', name: 'backupSeedConfirm');
  }

  String get seedBackupInfo {
    return Intl.message("Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
        desc: 'intro_new_wallet_seed', name: 'seedBackupInfo');
  }

  String get copySeed {
    return Intl.message("Copy Seed",
      desc: 'copy_seed_btn', name: 'copySeed');
  }

  String get seedCopiedShort {
    return Intl.message("Seed Copied",
      desc: 'seed_copied_btn', name: 'seedCopiedShort');
  }

  String get importSeed {
    return Intl.message("Import seed",
        desc: 'intro_seed_header', name: 'importSeed');
  }

  String get importSeedHint {
    return Intl.message("Please enter your seed below.",
        desc: 'intro_seed_info', name: 'importSeedHint');
  }

  String get welcomeText {
    return Intl.message("Welcome to Natrium. To begin you may create a new wallet or import an existing one.",
        desc: 'intro_welcome_title', name: 'welcomeText');
  }

  String get newWallet {
    return Intl.message("New Wallet",
        desc: 'intro_welcome_new_wallet', name: 'newWallet');
  }

  String get importWallet {
    return Intl.message("Import Wallet",
        desc: 'intro_welcome_have_wallet', name: 'importWallet');
  }
  /// -- END INTRO ITEMS

  /// -- SEND ITEMS
  String get sentTo {
    return Intl.message("Sent To",
        desc: 'sent_to', name: 'sentTo');
  }

  String get sending {
    return Intl.message("Sending",
        desc: 'send_sending', name: 'sending');
  }

  String get to {
    return Intl.message("To",
        desc: 'send_to', name: 'to');
  }

  String get sendAmountConfirm {
    return Intl.message("Send %1 NANO",
        desc: 'send_pin_description', name: 'sendAmountConfirm');
  }

  String get sendAmountConfirmPin {
    return sendAmountConfirm;
  }

  String get sendError {
    return Intl.message("An error occured. Try again later.",
      desc: 'send_generic_error', name: 'sendError');
  }

  String get enterAmount {
    return Intl.message("Enter Amount",
      desc: 'send_amount_hint', name: 'enterAmount');
  }

  String get enterAddress {
    return Intl.message("Enter Address",
      desc: 'enter_address', name: 'enterAddress');
  }

  String get invalidAddress {
    return Intl.message("Address entered was invalid",
      desc: 'send_invalid_address', name: 'invalidAddress');
  }

  String get addressMising {
    return Intl.message("Please Enter an Address",
      desc: 'send_enter_address', name: 'addressMising');
  }
  
  String get amountMissing {
    return Intl.message("Please Enter an Amount",
      desc: 'send_enter_amount', name: 'amountMissing');
  }
  
  String get insufficientBalance {
    return Intl.message("Insufficient Balance",
      desc: 'send_insufficient_balance', name: 'insufficientBalance');
  }

  String get sendFrom {
    return Intl.message("Send From",
      desc: 'send_title', name: 'sendFrom');
  }
  /// -- END SEND ITEMS

  /// -- PIN SCREEN
  String get pinCreateTitle {
    return Intl.message("Create a 6-digit pin",
      desc: 'pin_create_title', name: 'pinCreateTitle');
  }

  String get pinConfirmTitle {
    return Intl.message("Confirm your pin",
      desc: 'pin_confirm_title', name: 'pinConfirmTitle');
  }

  String get pinEnterTitle {
    return Intl.message("Enter pin",
      desc: 'pin_enter_title', name: 'pinEnterTitle');
  }

  String get pinConfirmError {
    return Intl.message("Pins do not match",
      desc: 'pin_confirm_error', name: 'pinConfirmError');
  }

  String get pinInvalid {
    return Intl.message("Invalid pin entered",
      desc: 'pin_error', name: 'pinInvalid');
  }

  /// -- END PIN SCREEN

  /// -- SETTINGS ITEMS

  String get themeHeader {
    return Intl.message("Theme",
      desc: 'theme_header', name: 'themeHeader');
  }

  String get changeRepButton {
    return Intl.message("Change",
      desc: 'change_representative_change', name: 'changeRepButton');
  }

  String get changeRepAuthenticate {
    return Intl.message("Change Representative",
      desc: 'settings_change_rep', name: 'changeRepAuthenticate');
  }

  String get currentlyRepresented {
    return Intl.message("Currently Represented By",
      desc: 'change_representative_current_header', name: 'currentlyRepresented');
  }

  String get changeRepSucces {
    return Intl.message("Representative Changed Successfully",
      desc: 'change_representative_success', name: 'changeRepSucces');
  }

  String get repInfoHeader {
    return Intl.message("What is a representative?",
      desc: 'change_representative_info_header', name: 'repInfoHeader');
  }
  
  String get repInfo {
    return Intl.message("A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy.",
      desc: 'change_representative_info', name: 'repInfo');
  }

  String get pinRepChange {
    return Intl.message("Enter PIN to change representative.",
      desc: 'change_representative_pin', name: 'pinRepChange');
  }

  String get changeRepHint {
    return Intl.message("Enter New Representative",
      desc: 'change_representative_hint', name: 'changeRepHint');
  }

  String get authMethod {
    return Intl.message("Authentication Method",
      desc: 'settings_disable_fingerprint', name: 'authMethod');
  }

  String get pinMethod {
    return Intl.message("PIN",
      desc: 'settings_pin_method', name: 'pinMethod');
  }

  String get privacyPolicy {
    return Intl.message("Privacy Policy",
      desc: 'settings_privacy_policy', name: 'privacyPolicy');
  }

  String get biometricsMethod {
    return Intl.message("Biometrics",
      desc: 'settings_fingerprint_method', name: 'biometricsMethod');
  }

  String get changeCurrency {
    return Intl.message("Change Currency",
      desc: 'settings_local_currency', name: 'changeCurrency');
  }

  String get language {
    return Intl.message("Language",
      desc: 'settings_change_language', name: 'language');
  }

  String get shareNatrium {
    return Intl.message("Share Natrium",
      desc: 'settings_share', name: 'shareNatrium');
  }

  String get shareNatriumText {
    return Intl.message("Check out Natrium! A premier NANO mobile wallet!",
      desc: 'share_extra', name: 'shareNatriumText');
  }

  String get logout {
    return Intl.message("Logout",
      desc: 'settings_logout', name: 'logout');
  }

  String get warning {
    return Intl.message("Warning",
      desc: 'settings_logout_alert_title', name: 'warning');
  }

  String get logoutDetail {
    return Intl.message("Logging out will remove your seed and all Natrium-related data from this device. If your seed is not backed up, you will never be able to access your funds again",
      desc: 'settings_logout_alert_message', name: 'logoutDetail');
  }

  String get logoutAction {
    return Intl.message("Delete Seed and Logout",
      desc: 'settings_logout_alert_confirm_cta', name: 'logoutAction');
  }

  String get logoutAreYouSure {
    return Intl.message("Are you sure?",
      desc: 'settings_logout_warning_title', name: 'logoutAreYouSure');
  }

  String get logoutReassurance {
    return Intl.message("As long as you've backed up your seed you have nothing to worry about.",
      desc: 'settings_logout_warning_message', name: 'logoutReassurance');
  }

  String get settingsHeader {
    return Intl.message("Settings",
      desc: 'settings_title', name: 'settingsHeader');
  }

  String get preferences {
    return Intl.message("Preferences",
      desc: 'settings_preferences_header', name: 'preferences');
  }

  String get manage {
    return Intl.message("Manage",
      desc: 'settings_manage_header', name: 'manage');
  }

  String get backupSeed {
    return Intl.message("Backup Seed",
      desc: 'settings_backup_seed', name: 'backupSeed');
  }

  String get fingerprintSeedBackup {
    return Intl.message("Authenticate to backup seed.",
      desc: 'settings_fingerprint_title', name: 'fingerprintSeedBackup');
  }

  String get pinSeedBackup {
    return Intl.message("Enter PIN to Backup Seed",
      desc: 'settings_pin_title', name: 'pinSeedBackup');
  }

  String get systemDefault {
    return Intl.message("System Default",
      desc: 'settings_default_language_string', name: 'systemDefault');
  }

  String get notifications {
    return Intl.message("Notifications",
      desc: 'notifications_settings', name: 'notifications');
  }

  String get notificationTitle {
    return Intl.message("Received %1 NANO",
      desc: 'notification_title', name: 'notificationTitle');
  }

  String get notificationBody {
    return Intl.message("Open Natrium to view this transaction",
      desc: 'notification_body', name: 'notificationBody');
  }

  String get notificationHeaderSupplement {
    return Intl.message("Tap to open",
      desc: 'notificaiton_header_suplement', name: 'notificationHeaderSupplement');
  }


  /// -- END SETTINGS ITEMS

  /// -- TRANSFER
  // Settings
  String get settingsTransfer {
    return Intl.message("Load from Paper Wallet",
      desc: 'settings_transfer', name: 'settingsTransfer');
  }

  String get transferError {
    return Intl.message("An error has occurred during the transfer. Please try again later.",
      desc: 'transfer_error', name: 'transferError');
  }

  String get paperWallet {
    return Intl.message("Paper Wallet",
      desc: 'paper_wallet', name: 'paperWallet');
  }

  String get kaliumWallet {
    return Intl.message("Natrium Wallet",
      desc: 'kalium_wallet', name: 'kaliumWallet');
  }

  String get manualEntry {
    return Intl.message("Manual Entry",
      desc: 'transfer_manual_entry', name: 'manualEntry');
  } 

  String get mnemonicPhrase {
    return Intl.message("Mnemonic Phrase",
      desc: 'mnemonic_phrase', name: 'mnemonicPhrase');
  }  

  String get rawSeed {
    return Intl.message("Raw Seed",
      desc: 'raw_seed', name: 'rawSeed');
  }

  // Initial Screen

  String get transferHeader {
    return Intl.message("Transfer Funds",
      desc: 'transfer_header', name: 'transferHeader');
  }

  String get transfer {
    return Intl.message("Transfer",
      desc: 'transfer_btn', name: 'transfer');
  }

  String get transferManualHint {
    return Intl.message("Please enter the seed below.",
      desc: 'transfer_hint', name: 'transferManualHint');
  }

  String get transferIntro {
    return Intl.message("This process will transfer the funds from a paper wallet to your Natrium wallet.\n\nTap the \"%1\" button to start.",
      desc: 'transfer_intro', name: 'transferIntro');
  }

  String get transferQrScanHint {
    return Intl.message("Scan a Nano \nseed or private key",
      desc: 'transfer_qr_scan_hint', name: 'transferQrScanHint');
  }

  String get transferQrScanError {
    return Intl.message("This QR code does not contain a valid seed.",
      desc: 'transfer_qr_scan_error', name: 'transferQrScanError');
  }

  String get transferNoFunds {
    return Intl.message("This seed does not have any NANO on it",
      desc: 'transfer_no_funds_toast', name: 'transferNoFunds');
  }

  // Confirm screen

  String get transferConfirmInfo {
    return Intl.message("A wallet with a balance of %1 NANO has been detected.\n",
      desc: 'transfer_confirm_info_first', name: 'transferConfirmInfo');
  }

  String get transferConfirmInfoSecond {
    return Intl.message("Tap confirm to transfer the funds.\n",
      desc: 'transfer_confirm_info_second', name: 'transferConfirmInfoSecond');
  }

  String get transferConfirmInfoThird {
    return Intl.message("Transfer may take several seconds to complete.",
      desc: 'transfer_confirm_info_third', name: 'transferConfirmInfoThird');
  }

  String get transferLoading {
    return Intl.message("Transferring",
      desc: 'transfer_loading_text', name: 'transferLoading');
  }

  // Compelte screen

  String get transferComplete {
    return Intl.message("%1 NANO successfully transferred to your Natrium Wallet.\n",
      desc: 'transfer_complete_text', name: 'transferComplete');
  }

  String get transferClose {
    return Intl.message("Tap anywhere to close the window.",
      desc: 'transfer_close_text', name: 'transferClose');
  }

  // -- END TRANSFER ITEMS

  // Scan

  String get scanInstructions {
    return Intl.message("Scan a Nano \naddress QR code",
      desc: 'scan_send_instruction_label', name: 'scanInstructions');
  }

  /// -- LOCK SCREEN 

  String get unlockPin {
    return Intl.message("Enter PIN to Unlock Natrium",
      desc: 'unlock_kalium_pin', name: 'unlockPin');
  }

  String get unlockBiometrics {
    return Intl.message("Authenticate to Unlock Natrium",
      desc: 'unlock_kalium_bio', name: 'unlockBiometrics');
  }

  String get lockAppSetting {
    return Intl.message("Authenticate on Launch",
      desc: 'authenticate_on_launch', name: 'lockAppSetting');
  }

  String get locked {
    return Intl.message("Locked",
      desc: 'lockedtxt', name: 'locked');
  }

  String get unlock {
    return Intl.message("Unlock",
      desc: 'unlocktxt', name: 'unlock');
  }

  String get tooManyFailedAttempts {
    return Intl.message("Too many failed unlock attempts.",
      desc: 'fail_toomany_attempts', name: 'tooManyFailedAttempts');
  }


  /// -- END LOCK SCREEN

  /// -- SECURITY SETTINGS SUBMENU

  String get securityHeader {
    return Intl.message("Security",
      desc: 'security_header', name:'securityHeader');
  }

  String get autoLockHeader {
    return Intl.message("Automatically Lock",
      desc: 'auto_lock_header', name:'autoLockHeader');
  }

  String get xMinutes {
    return Intl.message("After %1 minutes",
      desc: 'after_minutes', name: 'xMinutes');
  }

  String get xMinute {
    return Intl.message("After %1 minute",
      desc: 'after_minute', name: 'xMinute');
  }

  String get instantly {
    return Intl.message("Instantly",
      desc: 'insantly', name: 'instantly');
  }

  /// -- END SECURITY SETTINGS SUBMENU

  /// -- EXAMPLE HOME SCREEN CARDS

  String get exampleCardIntro {
    return Intl.message("Welcome to Natrium. Once you receive NANO, transactions will show up like this:",
      desc: 'example_card_intro', name: 'exampleCardIntro');
  }

  String get exampleCardLittle {
    return Intl.message("A little",
      desc: 'example_card_little', name: 'exampleCardLittle');
  }

  String get exampleCardLot {
    return Intl.message("A lot of",
      desc: 'example_card_lot', name: 'exampleCardLot');
  }

  String get exampleCardTo {
    return Intl.message("to someone",
      desc: 'example_card_to', name: 'exampleCardTo');
  }

  String get exampleCardFrom {
    return Intl.message("from someone",
      desc: 'example_card_from', name: 'exampleCardFrom');
  }

  /// -- END EXAMPLE HOME SCREEN CARDS

  /// -- NON-TRANSLATABLE ITEMS
  String getBlockExplorerUrl(String hash) {
    return 'https://nanocrawler.cc/explorer/block/$hash';
  }

  String getAccountExplorerUrl(String account) {
    return 'https://nanocrawler.cc/explorer/account/$account';
  }

  String get eulaUrl {
    return 'https://avengemedia.github.io/kalium/eula_natrium.html';
  }

  String get privacyUrl {
    return 'https://avengemedia.github.io/kalium/privacy.html';
  }

  /// -- END NON-TRANSLATABLE ITEMS
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  final LanguageSetting languageSetting;

  const AppLocalizationsDelegate(this.languageSetting);

  @override
  bool isSupported(Locale locale) {
    return languageSetting != null;
  }

  @override
  Future<AppLocalization> load(Locale locale) {
    if (languageSetting.language == AvailableLanguage.DEFAULT) {
      return AppLocalization.load(locale);
    }
    return AppLocalization.load(Locale(languageSetting.getLocaleString()));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}