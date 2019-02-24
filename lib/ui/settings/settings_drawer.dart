import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/ui/settings/accounts_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:logging/logging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:file_picker/file_picker.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/available_currency.dart';
import 'package:natrium_wallet_flutter/model/device_unlock_option.dart';
import 'package:natrium_wallet_flutter/model/device_lock_timeout.dart';
import 'package:natrium_wallet_flutter/model/notification_settings.dart';
import 'package:natrium_wallet_flutter/model/available_language.dart';
import 'package:natrium_wallet_flutter/model/available_themes.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/ui/settings/backupseed_sheet.dart';
import 'package:natrium_wallet_flutter/ui/contacts/add_contact.dart';
import 'package:natrium_wallet_flutter/ui/contacts/contact_details.dart';
import 'package:natrium_wallet_flutter/ui/settings/changerepresentative_sheet.dart';
import 'package:natrium_wallet_flutter/ui/settings/settings_list_item.dart';
import 'package:natrium_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:natrium_wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:natrium_wallet_flutter/ui/transfer/transfer_complete_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';

class SettingsSheet extends StatefulWidget {
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;
  Animation<Offset> _offsetFloat;
  AnimationController _securityController;
  Animation<Offset> _securityOffsetFloat;

  String documentsDirectory;
  String versionString = "";
  String mainAccountName = "Main Account";
  String mainAccountShortName = "MA";
  String mainAccountAddress = "xrb_1yekta1";
  String secondAccountName = "Shopping";
  String secondAccountShortName = "SH";
  String secondAccountAddress = "xrb_1bbedwa";
  String thirdAccountName = "Reddit";
  String thirdAccountShortName = "RE";
  String thirdAccountAddress = "xrb_1reddit";
  String spareAccountName = "";
  String spareAccountShortName = "";
  String spareAccountAddress = "";

  final log = Logger("SettingsSheet");
  bool _hasBiometrics = false;
  AuthenticationMethod _curAuthMethod =
      AuthenticationMethod(AuthMethod.BIOMETRICS);
  NotificationSetting _curNotificiationSetting =
      NotificationSetting(NotificationOptions.ON);
  UnlockSetting _curUnlockSetting = UnlockSetting(UnlockOption.NO);
  LockTimeoutSetting _curTimeoutSetting =
      LockTimeoutSetting(LockTimeoutOption.ONE);
  ThemeSetting _curThemeSetting = ThemeSetting(ThemeOptions.NATRIUM);

  bool _contactsOpen;
  bool _securityOpen;

  List<Contact> _contacts;

  bool notNull(Object o) => o != null;

  // Called if transfer fails
  void transferError() {
    Navigator.of(context).pop();
    UIUtil.showSnackbar(AppLocalization.of(context).transferError, context);
  }

  Future<void> _exportContacts() async {
    List<Contact> contacts = await DBHelper().getContacts();
    if (contacts.length == 0) {
      UIUtil.showSnackbar(
          AppLocalization.of(context).noContactsExport, context);
      return;
    }
    List<Map<String, dynamic>> jsonList = List();
    contacts.forEach((contact) {
      jsonList.add(contact.toJson());
    });
    DateTime exportTime = DateTime.now();
    String filename =
        "natriumcontacts_${exportTime.year}${exportTime.month}${exportTime.day}${exportTime.hour}${exportTime.minute}${exportTime.second}.txt";
    Directory baseDirectory = await getApplicationDocumentsDirectory();
    File contactsFile = File("${baseDirectory.path}/$filename");
    await contactsFile.writeAsString(json.encode(jsonList));
    UIUtil.cancelLockEvent();
    Share.shareFile(contactsFile);
  }

  Future<void> _importContacts() async {
    UIUtil.cancelLockEvent();
    String filePath = await FilePicker.getFilePath(
        type: FileType.CUSTOM, fileExtension: "txt");
    File f = File(filePath);
    if (!await f.exists()) {
      UIUtil.showSnackbar(
          AppLocalization.of(context).contactsImportErr, context);
      return;
    }
    try {
      String contents = await f.readAsString();
      Iterable contactsJson = json.decode(contents);
      List<Contact> contacts = List();
      List<Contact> contactsToAdd = List();
      contactsJson.forEach((contact) {
        contacts.add(Contact.fromJson(contact));
      });
      DBHelper dbHelper = DBHelper();
      for (Contact contact in contacts) {
        if (!await dbHelper.contactExistsWithName(contact.name) &&
            !await dbHelper.contactExistsWithAddress(contact.address)) {
          // Contact doesnt exist, make sure name and address are valid
          if (Address(contact.address).isValid()) {
            if (contact.name.startsWith("@") && contact.name.length <= 20) {
              contactsToAdd.add(contact);
            }
          }
        }
      }
      // Save all the new contacts and update states
      int numSaved = await dbHelper.saveContacts(contactsToAdd);
      if (numSaved > 0) {
        _updateContacts();
        EventTaxiImpl.singleton().fire(
            ContactModifiedEvent(contact: Contact(name: "", address: "")));
        UIUtil.showSnackbar(
            AppLocalization.of(context)
                .contactsImportSuccess
                .replaceAll("%1", numSaved.toString()),
            context);
      } else {
        UIUtil.showSnackbar(
            AppLocalization.of(context).noContactsImport, context);
      }
    } catch (e) {
      log.severe(e.toString());
      UIUtil.showSnackbar(
          AppLocalization.of(context).contactsImportErr, context);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _contactsOpen = false;
    _securityOpen = false;
    // Determine if they have face or fingerprint enrolled, if not hide the setting
    BiometricUtil.hasBiometrics().then((bool hasBiometrics) {
      setState(() {
        _hasBiometrics = hasBiometrics;
      });
    });
    // Get default auth method setting
    SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
      setState(() {
        _curAuthMethod = authMethod;
      });
    });
    // Get default unlock settings
    SharedPrefsUtil.inst.getLock().then((lock) {
      setState(() {
        _curUnlockSetting = lock
            ? UnlockSetting(UnlockOption.YES)
            : UnlockSetting(UnlockOption.NO);
      });
    });
    SharedPrefsUtil.inst.getLockTimeout().then((lockTimeout) {
      setState(() {
        _curTimeoutSetting = lockTimeout;
      });
    });
    // Get default notification setting
    SharedPrefsUtil.inst.getNotificationsOn().then((notificationsOn) {
      setState(() {
        _curNotificiationSetting = notificationsOn
            ? NotificationSetting(NotificationOptions.ON)
            : NotificationSetting(NotificationOptions.OFF);
      });
    });
    // Get default theme settings
    SharedPrefsUtil.inst.getTheme().then((theme) {
      setState(() {
        _curThemeSetting = theme;
      });
    });
    // Initial contacts list
    _contacts = List();
    getApplicationDocumentsDirectory().then((directory) {
      documentsDirectory = directory.path;
      setState(() {
        documentsDirectory = directory.path;
      });
      _updateContacts();
    });
    // Register event bus
    _registerBus();
    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For security menu
    _securityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _offsetFloat = Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
        .animate(_controller);
    _securityOffsetFloat =
        Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
            .animate(_securityController);

    // Version string
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        versionString = "v${packageInfo.version}";
      });
    });
  }

  StreamSubscription<ContactAddedEvent> _contactAddedSub;
  StreamSubscription<ContactRemovedEvent> _contactRemovedSub;
  StreamSubscription<TransferConfirmEvent> _transferConfirmSub;
  StreamSubscription<TransferCompleteEvent> _transferCompleteSub;
  StreamSubscription<UnlockCallbackEvent> _callbackUnlockSub;

  void _registerBus() {
    // Contact added bus event
    _contactAddedSub = EventTaxiImpl.singleton()
        .registerTo<ContactAddedEvent>()
        .listen((event) {
      setState(() {
        _contacts.add(event.contact);
        //Sort by name
        _contacts.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      });
      // Full update which includes downloading new monKey
      _updateContacts();
    });
    // Contact removed bus event
    _contactRemovedSub = EventTaxiImpl.singleton()
        .registerTo<ContactRemovedEvent>()
        .listen((event) {
      setState(() {
        _contacts.remove(event.contact);
      });
    });
    // Ready to go to transfer confirm
    _transferConfirmSub = EventTaxiImpl.singleton()
        .registerTo<TransferConfirmEvent>()
        .listen((event) {
      AppTransferConfirmSheet(event.balMap, transferError)
          .mainBottomSheet(context);
    });
    // Ready to go to transfer complete
    _transferCompleteSub = EventTaxiImpl.singleton()
        .registerTo<TransferCompleteEvent>()
        .listen((event) {
      StateContainer.of(context).requestUpdate();
      AppTransferCompleteSheet(
              NumberUtil.getRawAsUsableString(event.amount.toString()))
          .mainBottomSheet(context);
    });
    // Unlock callback
    _callbackUnlockSub = EventTaxiImpl.singleton()
        .registerTo<UnlockCallbackEvent>()
        .listen((event) {
      StateContainer.of(context).unlockCallback();
    });
  }

  void _destroyBus() {
    if (_contactAddedSub != null) {
      _contactAddedSub.cancel();
    }
    if (_contactRemovedSub != null) {
      _contactRemovedSub.cancel();
    }
    if (_transferConfirmSub != null) {
      _transferConfirmSub.cancel();
    }
    if (_transferCompleteSub != null) {
      _transferCompleteSub.cancel();
    }
    if (_callbackUnlockSub != null) {
      _callbackUnlockSub.cancel();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _securityController.dispose();
    _destroyBus();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  void _updateContacts() {
    DBHelper().getContacts().then((contacts) {
      for (Contact c in contacts) {
        if (!_contacts.contains(c)) {
          setState(() {
            _contacts.add(c);
          });
        }
      }
      // Re-sort list
      setState(() {
        _contacts.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      });
    });
  }

  Future<void> _authMethodDialog() async {
    switch (await showDialog<AuthMethod>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).authMethod,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.BIOMETRICS);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).biometricsMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.PIN);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).pinMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case AuthMethod.PIN:
        SharedPrefsUtil.inst
            .setAuthMethod(AuthenticationMethod(AuthMethod.PIN))
            .then((result) {
          setState(() {
            _curAuthMethod = AuthenticationMethod(AuthMethod.PIN);
          });
        });
        break;
      case AuthMethod.BIOMETRICS:
        SharedPrefsUtil.inst
            .setAuthMethod(AuthenticationMethod(AuthMethod.BIOMETRICS))
            .then((result) {
          setState(() {
            _curAuthMethod = AuthenticationMethod(AuthMethod.BIOMETRICS);
          });
        });
        break;
    }
  }

  Future<void> _notificationsDialog() async {
    switch (await showDialog<NotificationOptions>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).notifications,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case NotificationOptions.ON:
        SharedPrefsUtil.inst.setNotificationsOn(true).then((result) {
          setState(() {
            _curNotificiationSetting =
                NotificationSetting(NotificationOptions.ON);
          });
          FirebaseMessaging().requestNotificationPermissions();
          FirebaseMessaging().getToken().then((fcmToken) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
          });
        });
        break;
      case NotificationOptions.OFF:
        SharedPrefsUtil.inst.setNotificationsOn(false).then((result) {
          setState(() {
            _curNotificiationSetting =
                NotificationSetting(NotificationOptions.OFF);
          });
          FirebaseMessaging().getToken().then((fcmToken) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
          });
        });
        break;
    }
  }

  Future<void> _lockDialog() async {
    switch (await showDialog<UnlockOption>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).lockAppSetting,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.NO);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).no,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.YES);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).yes,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case UnlockOption.YES:
        SharedPrefsUtil.inst.setLock(true).then((result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.YES);
          });
        });
        break;
      case UnlockOption.NO:
        SharedPrefsUtil.inst.setLock(false).then((result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.NO);
          });
        });
        break;
    }
  }

  List<Widget> _buildCurrencyOptions() {
    List<Widget> ret = new List();
    AvailableCurrencyEnum.values.forEach((AvailableCurrencyEnum value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            AvailableCurrency(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _currencyDialog() async {
    AvailableCurrencyEnum selection =
        await showAppDialog<AvailableCurrencyEnum>(
            context: context,
            builder: (BuildContext context) {
              return AppSimpleDialog(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    AppLocalization.of(context).changeCurrency,
                    style: AppStyles.textStyleDialogHeader(context),
                  ),
                ),
                children: _buildCurrencyOptions(),
              );
            });
    SharedPrefsUtil.inst
        .setCurrency(AvailableCurrency(selection))
        .then((result) {
      if (StateContainer.of(context).curCurrency.currency != selection) {
        setState(() {
          StateContainer.of(context).curCurrency = AvailableCurrency(selection);
        });
        StateContainer.of(context).requestSubscribe();
      }
    });
  }

  List<Widget> _buildLanguageOptions() {
    List<Widget> ret = new List();
    AvailableLanguage.values.forEach((AvailableLanguage value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            LanguageSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _languageDialog() async {
    AvailableLanguage selection = await showAppDialog<AvailableLanguage>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context).language,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLanguageOptions(),
          );
        });
    SharedPrefsUtil.inst.setLanguage(LanguageSetting(selection)).then((result) {
      if (StateContainer.of(context).curLanguage.language != selection) {
        setState(() {
          StateContainer.of(context).updateLanguage(LanguageSetting(selection));
        });
      }
    });
  }

  List<Widget> _buildLockTimeoutOptions() {
    List<Widget> ret = new List();
    LockTimeoutOption.values.forEach((LockTimeoutOption value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            LockTimeoutSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _lockTimeoutDialog() async {
    LockTimeoutOption selection = await showAppDialog<LockTimeoutOption>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context).autoLockHeader,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLockTimeoutOptions(),
          );
        });
    SharedPrefsUtil.inst
        .setLockTimeout(LockTimeoutSetting(selection))
        .then((result) {
      if (_curTimeoutSetting.setting != selection) {
        SharedPrefsUtil.inst
            .setLockTimeout(LockTimeoutSetting(selection))
            .then((_) {
          setState(() {
            _curTimeoutSetting = LockTimeoutSetting(selection);
          });
        });
      }
    });
  }

  List<Widget> _buildThemeOptions() {
    List<Widget> ret = new List();
    ThemeOptions.values.forEach((ThemeOptions value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            ThemeSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _themeDialog() async {
    ThemeOptions selection = await showAppDialog<ThemeOptions>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context).themeHeader,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildThemeOptions(),
          );
        });
    if (_curThemeSetting != ThemeSetting(selection)) {
      SharedPrefsUtil.inst.setTheme(ThemeSetting(selection)).then((result) {
        setState(() {
          StateContainer.of(context).updateTheme(ThemeSetting(selection));
          _curThemeSetting = ThemeSetting(selection);
        });
      });
    }
  }

  Future<bool> _onBackButtonPressed() async {
    if (_contactsOpen) {
      setState(() {
        _contactsOpen = false;
      });
      _controller.reverse();
      return false;
    } else if (_securityOpen) {
      setState(() {
        _securityOpen = false;
      });
      _securityController.reverse();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Drawer in flutter doesn't have a built-in way to push/pop elements
    // on top of it like our Android counterpart. So we can override back button
    // presses and replace the main settings widget with contacts based on a bool
    return new WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            Container(
              color: StateContainer.of(context).curTheme.backgroundDark,
              constraints: BoxConstraints.expand(),
            ),
            buildMainSettings(context),
            SlideTransition(
                position: _offsetFloat, child: buildContacts(context)),
            SlideTransition(
                position: _securityOffsetFloat,
                child: buildSecurityMenu(context)),
          ],
        ),
      ),
    );
  }

  Widget buildMainSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 30,
        ),
        child: Column(
          children: <Widget>[
            // A container for accounts area
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Main Account
                      Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: 60,
                              height: 45,
                              child: FlatButton(
                                onPressed: () => null,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.all(0.0),
                                child: Container(
                                    alignment: Alignment(-1, 0),
                                    child: Icon(
                                      AppIcons.accountwallet,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .success,
                                      size: 45,
                                    )),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 60,
                              height: 45,
                              alignment: Alignment(0, 0.3),
                              child: Text(
                                mainAccountShortName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: StateContainer.of(context)
                                      .curTheme
                                      .backgroundDark,
                                  fontSize: 16,
                                  fontFamily: "NunitoSans",
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // A row for other accounts and account switcher
                      Row(
                        children: <Widget>[
                          // Second Account
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: Icon(
                                    AppIcons.accountwallet,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary,
                                    size: 36,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 36,
                                    alignment: Alignment(0, 0.3),
                                    child: Text(secondAccountShortName,
                                        style: TextStyle(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .backgroundDark,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 36,
                                    color: Colors.transparent,
                                    child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          spareAccountName = secondAccountName;
                                          spareAccountShortName =
                                              secondAccountShortName;
                                          spareAccountAddress =
                                              secondAccountAddress;
                                          secondAccountName = mainAccountName;
                                          secondAccountShortName =
                                              mainAccountShortName;
                                          secondAccountAddress =
                                              mainAccountAddress;
                                          mainAccountName = spareAccountName;
                                          mainAccountShortName =
                                              spareAccountShortName;
                                          mainAccountAddress =
                                              spareAccountAddress;
                                        });
                                        Future.delayed(
                                            Duration(milliseconds: 400), () {
                                          Navigator.pop(context);
                                        });
                                      },
                                      highlightColor: StateContainer.of(context).curTheme.backgroundDark.withOpacity(0.75),
                                      splashColor: StateContainer.of(context).curTheme.backgroundDark.withOpacity(0.75),
                                      padding: EdgeInsets.all(0.0),
                                      child: Container(
                                        width: 48,
                                        height: 36,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Third Account
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: Icon(
                                    AppIcons.accountwallet,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary,
                                    size: 36,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 36,
                                    alignment: Alignment(0, 0.3),
                                    child: Text(thirdAccountShortName,
                                        style: TextStyle(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .backgroundDark,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 36,
                                    color: Colors.transparent,
                                    child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          spareAccountName = thirdAccountName;
                                          spareAccountShortName =
                                              thirdAccountShortName;
                                          spareAccountAddress =
                                              thirdAccountAddress;
                                          thirdAccountName = mainAccountName;
                                          thirdAccountShortName =
                                              mainAccountShortName;
                                          thirdAccountAddress =
                                              mainAccountAddress;
                                          mainAccountName = spareAccountName;
                                          mainAccountShortName =
                                              spareAccountShortName;
                                          mainAccountAddress =
                                              spareAccountAddress;
                                        });
                                        Future.delayed(
                                            Duration(milliseconds: 400), () {
                                          Navigator.pop(context);
                                        });
                                      },
                                      highlightColor: StateContainer.of(context).curTheme.backgroundDark.withOpacity(0.75),
                                      splashColor: StateContainer.of(context).curTheme.backgroundDark.withOpacity(0.75),
                                      padding: EdgeInsets.all(0.0),
                                      child: Container(
                                        width: 48,
                                        height: 36,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Account switcher
                          Container(
                            height: 36,
                            width: 36,
                            margin: EdgeInsets.symmetric(horizontal: 6.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: FlatButton(
                              onPressed: () {
                                AppAccountsSheet().mainBottomSheet(context);
                              },
                              padding: EdgeInsets.all(0.0),
                              shape: CircleBorder(),
                              splashColor:
                                  StateContainer.of(context).curTheme.text30,
                              highlightColor:
                                  StateContainer.of(context).curTheme.text15,
                              child: Icon(
                                AppIcons.accountswitcher,
                                size: 36,
                                color:
                                    StateContainer.of(context).curTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Main account name
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      mainAccountName,
                      style: TextStyle(
                        fontFamily: "NunitoSans",
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        color: StateContainer.of(context).curTheme.text,
                      ),
                    ),
                  ),
                  // Main account address
                  Container(
                    child: Text(
                      mainAccountAddress,
                      style: TextStyle(
                        fontFamily: "OverpassMono",
                        fontWeight: FontWeight.w100,
                        fontSize: 14.0,
                        color: StateContainer.of(context).curTheme.text60,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Settings items
            Expanded(
                child: Stack(
              children: <Widget>[
                ListView(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 30.0, bottom: 10),
                      child: Text(AppLocalization.of(context).preferences,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).changeCurrency,
                        StateContainer.of(context).curCurrency,
                        AppIcons.currency,
                        _currencyDialog),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).language,
                        StateContainer.of(context).curLanguage,
                        AppIcons.language,
                        _languageDialog),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).notifications,
                        _curNotificiationSetting,
                        AppIcons.notifications,
                        _notificationsDialog),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).themeHeader,
                        _curThemeSetting,
                        AppIcons.theme,
                        _themeDialog),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).securityHeader,
                        AppIcons.security, onPressed: () {
                      setState(() {
                        _securityOpen = true;
                      });
                      _securityController.forward();
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(left: 30.0, top: 20.0, bottom: 10.0),
                      child: Text(AppLocalization.of(context).manage,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).contactsHeader,
                        AppIcons.contact, onPressed: () {
                      setState(() {
                        _contactsOpen = true;
                      });
                      _controller.forward();
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).backupSeed,
                        AppIcons.backupseed, onPressed: () {
                      // Authenticate
                      SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
                        BiometricUtil.hasBiometrics().then((hasBiometrics) {
                          if (authMethod.method == AuthMethod.BIOMETRICS &&
                              hasBiometrics) {
                            BiometricUtil.authenticateWithBiometrics(
                                    context,
                                    AppLocalization.of(context)
                                        .fingerprintSeedBackup)
                                .then((authenticated) {
                              if (authenticated) {
                                HapticUtil.fingerprintSucess();
                                new AppSeedBackupSheet()
                                    .mainBottomSheet(context);
                              }
                            });
                          } else {
                            // PIN Authentication
                            Vault.inst.getPin().then((expectedPin) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return new PinScreen(
                                  PinOverlayType.ENTER_PIN,
                                  (pin) {
                                    Navigator.of(context).pop();
                                    new AppSeedBackupSheet()
                                        .mainBottomSheet(context);
                                  },
                                  expectedPin: expectedPin,
                                  description:
                                      AppLocalization.of(context).pinSeedBackup,
                                );
                              }));
                            });
                          }
                        });
                      });
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).settingsTransfer,
                        AppIcons.transferfunds, onPressed: () {
                      AppTransferOverviewSheet().mainBottomSheet(context);
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).changeRepAuthenticate,
                        AppIcons.changerepresentative, onPressed: () {
                      new AppChangeRepresentativeSheet()
                          .mainBottomSheet(context);
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).shareNatrium,
                        AppIcons.share, onPressed: () {
                      Share.share(
                          "Check out Natrium - NANO Wallet for iOS and Android" +
                              " https://natrium.io");
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).logout,
                        AppIcons.logout, onPressed: () {
                      AppDialogs.showConfirmDialog(
                          context,
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).warning, context),
                          AppLocalization.of(context).logoutDetail,
                          AppLocalization.of(context)
                              .logoutAction
                              .toUpperCase(), () {
                        // Show another confirm dialog
                        AppDialogs.showConfirmDialog(
                            context,
                            AppLocalization.of(context).logoutAreYouSure,
                            AppLocalization.of(context).logoutReassurance,
                            CaseChange.toUpperCase(
                                AppLocalization.of(context).yes, context), () {
                          // Unsubscribe from notifications
                          SharedPrefsUtil.inst
                              .setNotificationsOn(false)
                              .then((_) {
                            FirebaseMessaging().getToken().then((fcmToken) {
                              EventTaxiImpl.singleton()
                                  .fire(FcmUpdateEvent(token: fcmToken));
                              // Delete all data
                              Vault.inst.deleteAll().then((_) {
                                SharedPrefsUtil.inst.deleteAll().then((result) {
                                  StateContainer.of(context).logOut();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/', (Route<dynamic> route) => false);
                                });
                              });
                            });
                          });
                        });
                      });
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(versionString,
                              style: AppStyles.textStyleVersion(context)),
                          Text(" | ",
                              style: AppStyles.textStyleVersion(context)),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return UIUtil.showWebview(context,
                                      AppLocalization.of(context).privacyUrl);
                                }));
                              },
                              child: Text(
                                  AppLocalization.of(context).privacyPolicy,
                                  style: AppStyles.textStyleVersionUnderline(
                                      context))),
                          Text(" | ",
                              style: AppStyles.textStyleVersion(context)),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return UIUtil.showWebview(context,
                                      AppLocalization.of(context).eulaUrl);
                                }));
                              },
                              child: Text("EULA",
                                  style: AppStyles.textStyleVersionUnderline(
                                      context))),
                        ],
                      ),
                    ),
                  ].where(notNull).toList(),
                ),
                //List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          StateContainer.of(context).curTheme.backgroundDark,
                          StateContainer.of(context).curTheme.backgroundDark00
                        ],
                        begin: Alignment(0.5, -1.0),
                        end: Alignment(0.5, 1.0),
                      ),
                    ),
                  ),
                ), //List Top Gradient End
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget buildContacts(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          boxShadow: [
            BoxShadow(
                color: StateContainer.of(context).curTheme.overlay30,
                offset: Offset(-5, 0),
                blurRadius: 20),
          ],
        ),
        child: SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035,
            top: 60,
          ),
          child: Column(
            children: <Widget>[
              // Back button and Contacts Text
              Container(
                margin: EdgeInsets.only(bottom: 10.0, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        //Back button
                        Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsets.only(right: 10, left: 10),
                          child: FlatButton(
                              highlightColor:
                                  StateContainer.of(context).curTheme.text15,
                              splashColor:
                                  StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                setState(() {
                                  _contactsOpen = false;
                                });
                                _controller.reverse();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(8.0),
                              child: Icon(AppIcons.back,
                                  color:
                                      StateContainer.of(context).curTheme.text,
                                  size: 24)),
                        ),
                        //Contacts Header Text
                        Text(
                          AppLocalization.of(context).contactsHeader,
                          style: AppStyles.textStyleSettingsHeader(context),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        //Import button
                        Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsets.only(right: 5),
                          child: FlatButton(
                              highlightColor:
                                  StateContainer.of(context).curTheme.text15,
                              splashColor:
                                  StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                _importContacts();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(8.0),
                              child: Icon(AppIcons.import_icon,
                                  color:
                                      StateContainer.of(context).curTheme.text,
                                  size: 24)),
                        ),
                        //Export button
                        Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsets.only(right: 20),
                          child: FlatButton(
                              highlightColor:
                                  StateContainer.of(context).curTheme.text15,
                              splashColor:
                                  StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                _exportContacts();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(8.0),
                              child: Icon(AppIcons.export_icon,
                                  color:
                                      StateContainer.of(context).curTheme.text,
                                  size: 24)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Contacts list + top and bottom gradients
              Expanded(
                child: Stack(
                  children: <Widget>[
                    // Contacts list
                    ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 15.0),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        // Some disaster recovery if monKey is in DB, but doesnt exist in filesystem
                        if (_contacts[index].monkeyPath != null) {
                          File("$documentsDirectory/${_contacts[index].monkeyPath}")
                              .exists()
                              .then((exists) {
                            if (!exists) {
                              DBHelper()
                                  .setMonkeyForContact(_contacts[index], null);
                            }
                          });
                        }
                        // Build contact
                        return buildSingleContact(context, _contacts[index]);
                      },
                    ),
                    //List Top Gradient End
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 20.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark,
                              StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark00
                            ],
                            begin: Alignment(0.5, -1.0),
                            end: Alignment(0.5, 1.0),
                          ),
                        ),
                      ),
                    ),
                    //List Bottom Gradient End
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 15.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark00,
                              StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark,
                            ],
                            begin: Alignment(0.5, -1.0),
                            end: Alignment(0.5, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.TEXT_OUTLINE,
                        AppLocalization.of(context).addContact,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      AddContactSheet().mainBottomSheet(context);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildSingleContact(BuildContext context, Contact contact) {
    return FlatButton(
      onPressed: () {
        ContactDetailsSheet(contact, documentsDirectory)
            .mainBottomSheet(context);
      },
      padding: EdgeInsets.all(0.0),
      child: Column(children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        // Main Container
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          margin: new EdgeInsets.only(left: 36.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //Contact info
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Contact name
                    Text(contact.name,
                        style: AppStyles.textStyleSettingItemHeader(context)),
                    //Contact address
                    Text(
                      Address(contact.address).getShortString(),
                      style: AppStyles.textStyleTransactionAddress(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildSecurityMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: [
          BoxShadow(
              color: StateContainer.of(context).curTheme.overlay30,
              offset: Offset(-5, 0),
              blurRadius: 20),
        ],
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
          top: 60,
        ),
        child: Column(
          children: <Widget>[
            // Back button and Security Text
            Container(
              margin: EdgeInsets.only(bottom: 10.0, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      //Back button
                      Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: FlatButton(
                            highlightColor:
                                StateContainer.of(context).curTheme.text15,
                            splashColor:
                                StateContainer.of(context).curTheme.text15,
                            onPressed: () {
                              setState(() {
                                _securityOpen = false;
                              });
                              _securityController.reverse();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(AppIcons.back,
                                color: StateContainer.of(context).curTheme.text,
                                size: 24)),
                      ),
                      //Security Header Text
                      Text(
                        AppLocalization.of(context).securityHeader,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: <Widget>[
                ListView(
                  padding: EdgeInsets.only(top: 15.0),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 30.0, bottom: 10),
                      child: Text(AppLocalization.of(context).preferences,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    // Authentication Method
                    _hasBiometrics
                        ? Divider(
                            height: 2,
                            color: StateContainer.of(context).curTheme.text15,
                          )
                        : null,
                    _hasBiometrics
                        ? AppSettings.buildSettingsListItemDoubleLine(
                            context,
                            AppLocalization.of(context).authMethod,
                            _curAuthMethod,
                            AppIcons.fingerprint,
                            _authMethodDialog)
                        : null,
                    // Authenticate on Launch
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).lockAppSetting,
                        _curUnlockSetting,
                        AppIcons.lock,
                        _lockDialog),
                    // Authentication Timer
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context).autoLockHeader,
                      _curTimeoutSetting,
                      AppIcons.timer,
                      _lockTimeoutDialog,
                      disabled: _curUnlockSetting.setting == UnlockOption.NO,
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                  ].where(notNull).toList(),
                ),
                //List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          StateContainer.of(context).curTheme.backgroundDark,
                          StateContainer.of(context).curTheme.backgroundDark00
                        ],
                        begin: Alignment(0.5, -1.0),
                        end: Alignment(0.5, 1.0),
                      ),
                    ),
                  ),
                ), //List Top Gradient End
              ],
            )),
          ],
        ),
      ),
    );
  }
}
