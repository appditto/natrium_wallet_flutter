import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:kalium_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:logging/logging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/app_icons.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';
import 'package:kalium_wallet_flutter/model/address.dart';
import 'package:kalium_wallet_flutter/model/authentication_method.dart';
import 'package:kalium_wallet_flutter/model/available_currency.dart';
import 'package:kalium_wallet_flutter/model/device_unlock_option.dart';
import 'package:kalium_wallet_flutter/model/device_lock_timeout.dart';
import 'package:kalium_wallet_flutter/model/notification_settings.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/model/db/contact.dart';
import 'package:kalium_wallet_flutter/model/db/appdb.dart';
import 'package:kalium_wallet_flutter/ui/settings/backupseed_sheet.dart';
import 'package:kalium_wallet_flutter/ui/contacts/add_contact.dart';
import 'package:kalium_wallet_flutter/ui/contacts/contact_details.dart';
import 'package:kalium_wallet_flutter/ui/settings/changerepresentative_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_list_item.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_complete_sheet.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/widgets/security.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/biometrics.dart';
import 'package:kalium_wallet_flutter/util/fileutil.dart';
import 'package:kalium_wallet_flutter/util/hapticutil.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';

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

  final log = Logger("SettingsSheet");
  bool _hasBiometrics = false;
  AuthenticationMethod _curAuthMethod =
      AuthenticationMethod(AuthMethod.BIOMETRICS);
  NotificationSetting _curNotificiationSetting =
      NotificationSetting(NotificationOptions.ON);
  UnlockSetting _curUnlockSetting =
      UnlockSetting(UnlockOption.NO);
  LockTimeoutSetting _curTimeoutSetting =
      LockTimeoutSetting(LockTimeoutOption.ONE);

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
        "kaliumcontacts_${exportTime.year}${exportTime.month}${exportTime.day}${exportTime.hour}${exportTime.minute}${exportTime.second}.txt";
    Directory baseDirectory = await getApplicationDocumentsDirectory();
    File contactsFile = File("${baseDirectory.path}/$filename");
    await contactsFile.writeAsString(json.encode(jsonList));
    Share.shareFile(contactsFile);
  }

  Future<void> _importContacts() async {
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
        RxBus.post(Contact(name: "", address: ""),
            tag: RX_CONTACT_MODIFIED_TAG);
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
        _curUnlockSetting = lock ? UnlockSetting(UnlockOption.YES) : UnlockSetting(UnlockOption.NO);
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
        _curNotificiationSetting =
            notificationsOn ? NotificationSetting(NotificationOptions.ON) 
                            : NotificationSetting(NotificationOptions.OFF);
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
    _securityOffsetFloat = Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
        .animate(_securityController);

    // Version string
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        versionString = "v${packageInfo.version}";
      });
    });
  }

  void _registerBus() {
    // Contact added bus event
    RxBus.register<Contact>(tag: RX_CONTACT_ADDED_TAG).listen((contact) {
      setState(() {
        _contacts.add(contact);
        //Sort by name
        _contacts.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      });
      // Full update which includes downloading new monKey
      _updateContacts();
    });
    // Contact removed bus event
    RxBus.register<Contact>(tag: RX_CONTACT_REMOVED_TAG).listen((contact) {
      setState(() {
        _contacts.remove(contact);
      });
    });
    // Ready to go to transfer confirm
    RxBus.register<Map<String, AccountBalanceItem>>(
            tag: RX_TRANSFER_CONFIRM_TAG)
        .listen((Map<String, AccountBalanceItem> privKeyMap) {
      AppTransferConfirmSheet(privKeyMap, transferError)
          .mainBottomSheet(context);
    });
    // Ready to go to transfer complete
    RxBus.register<BigInt>(tag: RX_TRANSFER_COMPLETE_TAG)
        .listen((BigInt amount) {
      StateContainer.of(context).requestUpdate();
      AppTransferCompleteSheet(
              NumberUtil.getRawAsUsableString(amount.toString()))
          .mainBottomSheet(context);
    });
    // Unlock callback
    RxBus.register<String>(tag: RX_UNLOCK_CALLBACK_TAG).listen((result) {
      StateContainer.of(context).unlockCallback();
    });
  }

  void _destroyBus() {
    RxBus.destroy(tag: RX_CONTACT_ADDED_TAG);
    RxBus.destroy(tag: RX_CONTACT_REMOVED_TAG);
    RxBus.destroy(tag: RX_TRANSFER_CONFIRM_TAG);
    RxBus.destroy(tag: RX_UNLOCK_CALLBACK_TAG);
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
        _destroyBus();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        _registerBus();
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
      // Get any monKeys that are missing
      for (Contact c in _contacts) {
        // Download monKeys if not existing
        if (c.monkeyWidget == null) {
          if (c.monkeyPath != null) {
            setState(() {
              c.monkeyWidget = Image.file(
                  File("$documentsDirectory/${c.monkeyPath}"),
                  width: smallScreen(context) ? 55 : 70,
                  height: smallScreen(context) ? 55 : 70);
            });
          } else {
            UIUtil.downloadOrRetrieveMonkey(
                    context, c.address, MonkeySize.SMALL)
                .then((result) {
              FileUtil.pngHasValidSignature(result).then((valid) {
                if (valid) {
                  setState(() {
                    c.monkeyWidget = Image.file(result);
                    c.monkeyPath = path.basename(result.path);
                  });
                  DBHelper().setMonkeyForContact(c, c.monkeyPath);
                }
              });
            });
          }
        }
        if (c.monkeyWidgetLarge == null) {
          UIUtil.downloadOrRetrieveMonkey(context, c.address, MonkeySize.NORMAL)
              .then((result) {
            FileUtil.pngHasValidSignature(result).then((valid) {
              if (valid) {
                setState(() {
                  c.monkeyWidgetLarge = Image.file(result,
                      width: smallScreen(context) ? 130 : 200,
                      height: smallScreen(context) ? 130 : 200);
                });
              }
            });
          });
        }
      }
    });
  }

  Future<void> _authMethodDialog() async {
    switch (await showDialog<AuthMethod>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).authMethod,
              style: AppStyles.TextStyleDialogHeader,
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
                    style: AppStyles.TextStyleDialogOptions,
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
                    style: AppStyles.TextStyleDialogOptions,
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
              style: AppStyles.TextStyleDialogHeader,
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
                    style: AppStyles.TextStyleDialogOptions,
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
                    style: AppStyles.TextStyleDialogOptions,
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
            RxBus.post(fcmToken, tag: RX_FCM_UPDATE_TAG);
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
            RxBus.post(fcmToken, tag: RX_FCM_UPDATE_TAG);
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
              style: AppStyles.TextStyleDialogHeader,
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
                    style: AppStyles.TextStyleDialogOptions,
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
                    style: AppStyles.TextStyleDialogOptions,
                  ),
                ),
              ),
            ],
          );
        })) {
      case UnlockOption.YES:
        SharedPrefsUtil.inst.setLock(true).then((result) {
          setState(() {
            _curUnlockSetting =
                UnlockSetting(UnlockOption.YES);
          });
        });
        break;
      case UnlockOption.NO:
        SharedPrefsUtil.inst.setLock(false).then((result) {
          setState(() {
            _curUnlockSetting =
                UnlockSetting(UnlockOption.NO);
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
            style: AppStyles.TextStyleDialogOptions,
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
                    style: AppStyles.TextStyleDialogHeader,
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
            style: AppStyles.TextStyleDialogOptions,
          ),
        ),
      ));
    });
    return ret;
  }


  Future<void> _lockTimeoutDialog() async {
    LockTimeoutOption selection =
        await showAppDialog<LockTimeoutOption>(
            context: context,
            builder: (BuildContext context) {
              return AppSimpleDialog(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    AppLocalization.of(context).autoLockHeader,
                    style: AppStyles.TextStyleDialogHeader,
                  ),
                ),
                children: _buildLockTimeoutOptions(),
              );
            });
    SharedPrefsUtil.inst
        .setLockTimeout(LockTimeoutSetting(selection))
        .then((result) {
      if (_curTimeoutSetting.setting != selection) {
        SharedPrefsUtil.inst.setLockTimeout(LockTimeoutSetting(selection)).then((_) {
          setState(() {
            _curTimeoutSetting = LockTimeoutSetting(selection);
          });
        });
      }
    });
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
              color: AppColors.backgroundDark,
              constraints: BoxConstraints.expand(),
            ),
            buildMainSettings(context),
            SlideTransition(
                position: _offsetFloat, child: buildContacts(context)),
            SlideTransition(
                position: _securityOffsetFloat, child: buildSecurityMenu(context)),
          ],
        ),
      ),
    );
  }

  Widget buildMainSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 30.0, top: 60.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Text(
                  AppLocalization.of(context).settingsHeader,
                  style: AppStyles.textStyleSettingsHeader(),
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
                            color: AppColors.text60)),
                  ),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context).changeCurrency,
                      StateContainer.of(context).curCurrency,
                      AppIcons.currency,
                      _currencyDialog),
                  /*
                  Divider(height: 2),
                  buildSettingsListItemDoubleLine(
                      AppLocalization.of(context).language,
                      AppLocalization.of(context).systemDefault,
                      AppIcons.language),*/
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context).notifications,
                      _curNotificiationSetting,
                      AppIcons.notifications,
                      _notificationsDialog),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemSingleLine(
                      AppLocalization.of(context).securityHeader,
                      AppIcons.security, onPressed: () {
                    setState(() {
                      _securityOpen = true;
                    });
                    _securityController.forward();
                  }),
                  Divider(height: 2),
                  Container(
                    margin:
                        EdgeInsets.only(left: 30.0, top: 20.0, bottom: 10.0),
                    child: Text(AppLocalization.of(context).manage,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100,
                            color: AppColors.text60)),
                  ),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemSingleLine(
                      AppLocalization.of(context).contactsHeader,
                      AppIcons.contacts, onPressed: () {
                    setState(() {
                      _contactsOpen = true;
                    });
                    _controller.forward();
                  }),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemSingleLine(
                      AppLocalization.of(context).backupSeed,
                      AppIcons.backupseed, onPressed: () {
                    // Authenticate
                    SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
                      BiometricUtil.hasBiometrics().then((hasBiometrics) {
                        if (authMethod.method == AuthMethod.BIOMETRICS &&
                            hasBiometrics) {
                          BiometricUtil.authenticateWithBiometrics(
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
                                description: AppLocalization.of(context)
                                    .pinSeedBackup,
                              );
                            }));
                          });
                        }
                      });
                    });
                  }),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemSingleLine(
                      AppLocalization.of(context).settingsTransfer,
                      AppIcons.transferfunds, onPressed: () {
                    AppTransferOverviewSheet().mainBottomSheet(context);
                  }),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemSingleLine(
                      AppLocalization.of(context).changeRepAuthenticate,
                      AppIcons.changerepresentative, onPressed: () {
                    new AppChangeRepresentativeSheet()
                        .mainBottomSheet(context);
                  }),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemSingleLine(
                      AppLocalization.of(context).shareKalium,
                      AppIcons.share, onPressed: () {
                    Share.share(AppLocalization.of(context).shareKaliumText +
                        " https://kalium.banano.cc");
                  }),
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemSingleLine(
                      AppLocalization.of(context).logout, AppIcons.logout,
                      onPressed: () {
                    AppDialogs.showConfirmDialog(
                        context,
                        AppLocalization.of(context).warning.toUpperCase(),
                        AppLocalization.of(context).logoutDetail,
                        AppLocalization.of(context)
                            .logoutAction
                            .toUpperCase(), () {
                      // Show another confirm dialog
                      AppDialogs.showConfirmDialog(
                          context,
                          AppLocalization.of(context).logoutAreYouSure,
                          AppLocalization.of(context).logoutReassurance,
                          AppLocalization.of(context).yes.toUpperCase(), () {
                        // Unsubscribe from notifications
                        SharedPrefsUtil.inst.setNotificationsOn(false).then((_) {
                          FirebaseMessaging().getToken().then((fcmToken) {
                            RxBus.post(fcmToken, tag: RX_FCM_UPDATE_TAG);
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
                  Divider(height: 2),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(versionString,
                            style: AppStyles.TextStyleVersion),
                        Text(" | ",
                            style: AppStyles.TextStyleVersion),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return UIUtil.showWebview(
                                   AppLocalization.of(context).privacyUrl);
                              }));      
                            },
                            child: Text(AppLocalization.of(context).privacyPolicy,
                                    style: AppStyles.TextStyleVersionUnderline)
                        ),
                        Text(" | ",
                            style: AppStyles.TextStyleVersion),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return UIUtil.showWebview(
                                   AppLocalization.of(context).eulaUrl);
                              }));                              
                            },
                            child: Text("EULA",
                                    style: AppStyles.TextStyleVersionUnderline)
                        ),
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
                        AppColors.backgroundDark,
                        AppColors.backgroundDark00
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
    );
  }

  Widget buildContacts(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        boxShadow: [
          BoxShadow(color: AppColors.overlay30, offset: Offset(-5, 0), blurRadius: 20),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Back button and Contacts Text
          Container(
            margin: EdgeInsets.only(top: 60.0, bottom: 10.0),
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
                              color: AppColors.text, size: 24)),
                    ),
                    //Contacts Header Text
                    Text(
                      AppLocalization.of(context).contactsHeader,
                      style: AppStyles.textStyleSettingsHeader(),
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
                          onPressed: () {
                            _importContacts();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)),
                          padding: EdgeInsets.all(8.0),
                          child: Icon(AppIcons.import_icon,
                              color: AppColors.text, size: 24)),
                    ),
                    //Export button
                    Container(
                      height: 40,
                      width: 40,
                      margin: EdgeInsets.only(right: 20),
                      child: FlatButton(
                          onPressed: () {
                            _exportContacts();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)),
                          padding: EdgeInsets.all(8.0),
                          child: Icon(AppIcons.export_icon,
                              color: AppColors.text, size: 24)),
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
                          AppColors.backgroundDark,
                          AppColors.backgroundDark00
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
                          AppColors.backgroundDark00,
                          AppColors.backgroundDark,
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
    );
  }

  Widget buildSingleContact(BuildContext context, Contact contact) {
    return FlatButton(
      onPressed: () {
        ContactDetailsSheet(contact, documentsDirectory)
            .mainBottomSheet(context);
      },
      padding: EdgeInsets.all(0.0),
      child: Column(children: <Widget>[
        Divider(height: 2),
        // Main Container
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          margin: new EdgeInsets.only(left: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //Container for monKey
              contact.monkeyWidget != null && _contactsOpen
                  ? Container(
                      width: smallScreen(context) ? 55 : 70,
                      height: smallScreen(context) ? 55 : 70,
                      child: contact.monkeyWidget,
                    )
                  : SizedBox(
                      width: smallScreen(context) ? 55 : 70,
                      height: smallScreen(context) ? 55 : 70),
              //Contact info
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Contact name
                    Text(
                      contact.name,
                      style: AppStyles.TextStyleSettingItemHeader,
                    ),
                    //Contact address
                    Text(
                      Address(contact.address).getShortString(),
                      style: AppStyles.TextStyleTransactionAddress,
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
        color: AppColors.backgroundDark,
        boxShadow: [
          BoxShadow(color: AppColors.overlay30, offset: Offset(-5, 0), blurRadius: 20),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Back button and Security Text
          Container(
            margin: EdgeInsets.only(top: 60.0, bottom: 10.0),
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
                              color: AppColors.text, size: 24)),
                    ),
                    //Security Header Text
                    Text(
                      AppLocalization.of(context).securityHeader,
                      style: AppStyles.textStyleSettingsHeader(),
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
                            color: AppColors.text60)),
                  ),
                  // Authentication Method
                  _hasBiometrics ? Divider(height: 2) : null,
                  _hasBiometrics
                      ? AppSettings.buildSettingsListItemDoubleLine(
                          context,
                          AppLocalization.of(context).authMethod,
                          _curAuthMethod,
                          AppIcons.fingerprint,
                          _authMethodDialog)
                      : null,
                  // Authenticate on Launch
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context).lockAppSetting,
                      _curUnlockSetting,
                      AppIcons.lock,
                      _lockDialog),
                  // Authentication Timer
                  Divider(height: 2),
                  AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context).autoLockHeader,
                      _curTimeoutSetting,
                      AppIcons.timer,
                      _lockTimeoutDialog,
                      disabled: _curUnlockSetting.setting == UnlockOption.NO,
                  ),
                  Divider(height: 2),
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
                        AppColors.backgroundDark,
                        AppColors.backgroundDark00
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
    );
  }
}
