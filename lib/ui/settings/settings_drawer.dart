import 'dart:async';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:natrium_wallet_flutter/model/available_block_explorer.dart';
import 'package:natrium_wallet_flutter/model/natricon_option.dart';
import 'package:natrium_wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:natrium_wallet_flutter/ui/accounts/accounts_sheet.dart';
import 'package:natrium_wallet_flutter/ui/settings/disable_password_sheet.dart';
import 'package:natrium_wallet_flutter/ui/settings/set_password_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:natrium_wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:natrium_wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/available_currency.dart';
import 'package:natrium_wallet_flutter/model/device_unlock_option.dart';
import 'package:natrium_wallet_flutter/model/device_lock_timeout.dart';
import 'package:natrium_wallet_flutter/model/notification_settings.dart';
import 'package:natrium_wallet_flutter/model/available_language.dart';
import 'package:natrium_wallet_flutter/model/available_themes.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/ui/settings/backupseed_sheet.dart';
import 'package:natrium_wallet_flutter/ui/settings/changerepresentative_sheet.dart';
import 'package:natrium_wallet_flutter/ui/settings/settings_list_item.dart';
import 'package:natrium_wallet_flutter/ui/settings/contacts_widget.dart';
import 'package:natrium_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:natrium_wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:natrium_wallet_flutter/ui/transfer/transfer_complete_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/flat_button.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/util/ninja/api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';

import '../../appstate_container.dart';
import '../../util/sharedprefsutil.dart';

class SettingsSheet extends StatefulWidget {
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;
  Animation<Offset> _offsetFloat;
  AnimationController _securityController;
  Animation<Offset> _securityOffsetFloat;

  String versionString = "";

  final Logger log = sl.get<Logger>();
  bool _hasBiometrics = false;
  AuthenticationMethod _curAuthMethod =
      AuthenticationMethod(AuthMethod.BIOMETRICS);
  NotificationSetting _curNotificiationSetting =
      NotificationSetting(NotificationOptions.ON);
  NatriconSetting _curNatriconSetting = NatriconSetting(NatriconOptions.ON);
  UnlockSetting _curUnlockSetting = UnlockSetting(UnlockOption.NO);
  LockTimeoutSetting _curTimeoutSetting =
      LockTimeoutSetting(LockTimeoutOption.ONE);
  ThemeSetting _curThemeSetting = ThemeSetting(ThemeOptions.NATRIUM);

  bool _securityOpen;
  bool _loadingAccounts;

  bool _contactsOpen;

  bool notNull(Object o) => o != null;

  // Called if transfer fails
  void transferError() {
    Navigator.of(context).pop();
    UIUtil.showSnackbar(AppLocalization.of(context).transferError, context);
  }

  @override
  void initState() {
    super.initState();
    _contactsOpen = false;
    _securityOpen = false;
    _loadingAccounts = false;
    // Determine if they have face or fingerprint enrolled, if not hide the setting
    sl.get<BiometricUtil>().hasBiometrics().then((bool hasBiometrics) {
      setState(() {
        _hasBiometrics = hasBiometrics;
      });
    });
    // Get default auth method setting
    sl.get<SharedPrefsUtil>().getAuthMethod().then((authMethod) {
      setState(() {
        _curAuthMethod = authMethod;
      });
    });
    // Get default unlock settings
    sl.get<SharedPrefsUtil>().getLock().then((lock) {
      setState(() {
        _curUnlockSetting = lock
            ? UnlockSetting(UnlockOption.YES)
            : UnlockSetting(UnlockOption.NO);
      });
    });
    sl.get<SharedPrefsUtil>().getLockTimeout().then((lockTimeout) {
      setState(() {
        _curTimeoutSetting = lockTimeout;
      });
    });
    // Get default notification setting
    sl.get<SharedPrefsUtil>().getNotificationsOn().then((notificationsOn) {
      setState(() {
        _curNotificiationSetting = notificationsOn
            ? NotificationSetting(NotificationOptions.ON)
            : NotificationSetting(NotificationOptions.OFF);
      });
    });
    // Get default natricon setting
    sl.get<SharedPrefsUtil>().getUseNatricon().then((useNatricon) {
      setState(() {
        _curNatriconSetting = useNatricon
            ? NatriconSetting(NatriconOptions.ON)
            : NatriconSetting(NatriconOptions.OFF);
      });
    });
    // Get default theme settings
    sl.get<SharedPrefsUtil>().getTheme().then((theme) {
      setState(() {
        _curThemeSetting = theme;
      });
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

  StreamSubscription<TransferConfirmEvent> _transferConfirmSub;
  StreamSubscription<TransferCompleteEvent> _transferCompleteSub;

  void _registerBus() {
    // Ready to go to transfer confirm
    _transferConfirmSub = EventTaxiImpl.singleton()
        .registerTo<TransferConfirmEvent>()
        .listen((event) {
      Sheets.showAppHeightNineSheet(
          context: context,
          widget: AppTransferConfirmSheet(
            privKeyBalanceMap: event.balMap,
            errorCallback: transferError,
          ));
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
  }

  void _destroyBus() {
    if (_transferConfirmSub != null) {
      _transferConfirmSub.cancel();
    }
    if (_transferCompleteSub != null) {
      _transferCompleteSub.cancel();
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

  Future<void> _authMethodDialog() async {
    switch (await showDialog<AuthMethod>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
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
        sl
            .get<SharedPrefsUtil>()
            .setAuthMethod(AuthenticationMethod(AuthMethod.PIN))
            .then((result) {
          setState(() {
            _curAuthMethod = AuthenticationMethod(AuthMethod.PIN);
          });
        });
        break;
      case AuthMethod.BIOMETRICS:
        sl
            .get<SharedPrefsUtil>()
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
        barrierColor: StateContainer.of(context).curTheme.barrier,
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
        sl.get<SharedPrefsUtil>().setNotificationsOn(true).then((result) {
          setState(() {
            _curNotificiationSetting =
                NotificationSetting(NotificationOptions.ON);
          });
          FirebaseMessaging.instance.requestPermission();
          FirebaseMessaging.instance.getToken().then((fcmToken) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
          });
        });
        break;
      case NotificationOptions.OFF:
        sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((result) {
          setState(() {
            _curNotificiationSetting =
                NotificationSetting(NotificationOptions.OFF);
          });
          FirebaseMessaging.instance.getToken().then((fcmToken) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
          });
        });
        break;
    }
  }

  Future<void> _natriconDialog() async {
    switch (await showDialog<NatriconOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).natricon,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NatriconOptions.ON);
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
                  Navigator.pop(context, NatriconOptions.OFF);
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
      case NatriconOptions.ON:
        sl.get<SharedPrefsUtil>().setUseNatricon(true).then((result) {
          setState(() {
            StateContainer.of(context).setNatriconOn(true);
            _curNatriconSetting = NatriconSetting(NatriconOptions.ON);
          });
        });
        break;
      case NatriconOptions.OFF:
        sl.get<SharedPrefsUtil>().setUseNatricon(false).then((result) {
          setState(() {
            StateContainer.of(context).setNatriconOn(false);
            _curNatriconSetting = NatriconSetting(NatriconOptions.OFF);
          });
        });
        break;
    }
  }

  Future<void> _lockDialog() async {
    switch (await showDialog<UnlockOption>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
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
        sl.get<SharedPrefsUtil>().setLock(true).then((result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.YES);
          });
        });
        break;
      case UnlockOption.NO:
        sl.get<SharedPrefsUtil>().setLock(false).then((result) {
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
                    AppLocalization.of(context).currency,
                    style: AppStyles.textStyleDialogHeader(context),
                  ),
                ),
                children: _buildCurrencyOptions(),
              );
            });
    sl
        .get<SharedPrefsUtil>()
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
    sl
        .get<SharedPrefsUtil>()
        .setLanguage(LanguageSetting(selection))
        .then((result) {
      if (StateContainer.of(context).curLanguage.language != selection) {
        setState(() {
          StateContainer.of(context).updateLanguage(LanguageSetting(selection));
        });
      }
    });
  }

  List<Widget> _buildExplorerOptions() {
    List<Widget> ret = new List();
    AvailableBlockExplorerEnum.values
        .forEach((AvailableBlockExplorerEnum value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            AvailableBlockExplorer(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _explorerDialog() async {
    AvailableBlockExplorerEnum selection =
        await showAppDialog<AvailableBlockExplorerEnum>(
            context: context,
            builder: (BuildContext context) {
              return AppSimpleDialog(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    AppLocalization.of(context).blockExplorer,
                    style: AppStyles.textStyleDialogHeader(context),
                  ),
                ),
                children: _buildExplorerOptions(),
              );
            });
    sl
        .get<SharedPrefsUtil>()
        .setBlockExplorer(AvailableBlockExplorer(selection))
        .then((result) {
      if (StateContainer.of(context).curBlockExplorer.explorer != selection) {
        setState(() {
          StateContainer.of(context)
              .updateBlockExplorer(AvailableBlockExplorer(selection));
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
    sl
        .get<SharedPrefsUtil>()
        .setLockTimeout(LockTimeoutSetting(selection))
        .then((result) {
      if (_curTimeoutSetting.setting != selection) {
        sl
            .get<SharedPrefsUtil>()
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
      sl
          .get<SharedPrefsUtil>()
          .setTheme(ThemeSetting(selection))
          .then((result) {
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
                position: _offsetFloat,
                child: ContactsList(_controller, _contactsOpen)),
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
              margin:
                  EdgeInsetsDirectional.only(start: 26.0, end: 20, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Main Account
                      StateContainer.of(context).natriconOn
                          ? Container(
                              margin: EdgeInsetsDirectional.only(start: 4.0),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        border: Border.all(
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary,
                                            width: 1.5),
                                      ),
                                      alignment: AlignmentDirectional(-1, 0),
                                      // natricon
                                      child: SvgPicture.network(
                                        UIUtil.getNatriconURL(
                                            StateContainer.of(context)
                                                .selectedAccount
                                                .address,
                                            StateContainer.of(context)
                                                .getNatriconNonce(
                                                    StateContainer.of(context)
                                                        .selectedAccount
                                                        .address)),
                                        key: Key(UIUtil.getNatriconURL(
                                            StateContainer.of(context)
                                                .selectedAccount
                                                .address,
                                            StateContainer.of(context)
                                                .getNatriconNonce(
                                                    StateContainer.of(context)
                                                        .selectedAccount
                                                        .address))),
                                        placeholderBuilder:
                                            (BuildContext context) => Container(
                                          child: FlareActor(
                                            "assets/ntr_placeholder_animation.flr",
                                            animation: "main",
                                            fit: BoxFit.contain,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100.0)),
                                        highlightColor:
                                            StateContainer.of(context)
                                                .curTheme
                                                .text15,
                                        splashColor: StateContainer.of(context)
                                            .curTheme
                                            .text15,
                                        padding: EdgeInsets.all(0.0),
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
                                        ),
                                        onPressed: () {
                                          AccountDetailsSheet(
                                                  StateContainer.of(context)
                                                      .selectedAccount)
                                              .mainBottomSheet(context);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              margin: EdgeInsetsDirectional.only(start: 4.0),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                        width: 60,
                                        height: 45,
                                        alignment: AlignmentDirectional(-1, 0),
                                        child: Icon(
                                          AppIcons.accountwallet,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .success,
                                          size: 45,
                                        )),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 60,
                                      height: 45,
                                      alignment: AlignmentDirectional(0, 0.3),
                                      child: Text(
                                        StateContainer.of(context)
                                            .selectedAccount
                                            .getShortName()
                                            .toUpperCase(),
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
                                  Center(
                                    child: Container(
                                      width: 60,
                                      height: 45,
                                      child: FlatButton(
                                        highlightColor:
                                            StateContainer.of(context)
                                                .curTheme
                                                .backgroundDark
                                                .withOpacity(0.75),
                                        splashColor: StateContainer.of(context)
                                            .curTheme
                                            .backgroundDark
                                            .withOpacity(0.75),
                                        padding: EdgeInsets.all(0.0),
                                        child: SizedBox(
                                          width: 60,
                                          height: 45,
                                        ),
                                        onPressed: () {
                                          AccountDetailsSheet(
                                                  StateContainer.of(context)
                                                      .selectedAccount)
                                              .mainBottomSheet(context);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      // A row for other accounts and account switcher
                      Row(
                        children: <Widget>[
                          // Second Account
                          StateContainer.of(context).recentLast != null
                              ? StateContainer.of(context).natriconOn
                                  ? Container(
                                      child: Stack(
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                              height: 52,
                                              width: 52,
                                              // natricon
                                              child: SvgPicture.network(
                                                UIUtil.getNatriconURL(
                                                    StateContainer.of(context)
                                                        .recentLast
                                                        .address,
                                                    StateContainer.of(context)
                                                        .getNatriconNonce(
                                                            StateContainer.of(
                                                                    context)
                                                                .recentLast
                                                                .address)),
                                                key: Key(UIUtil.getNatriconURL(
                                                    StateContainer.of(context)
                                                        .recentLast
                                                        .address,
                                                    StateContainer.of(context)
                                                        .getNatriconNonce(
                                                            StateContainer.of(
                                                                    context)
                                                                .recentLast
                                                                .address))),
                                                placeholderBuilder:
                                                    (BuildContext context) =>
                                                        Container(
                                                  child: FlareActor(
                                                    "assets/ntr_placeholder_animation.flr",
                                                    animation: "main",
                                                    fit: BoxFit.contain,
                                                    color: StateContainer.of(
                                                            context)
                                                        .curTheme
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.transparent,
                                              child: FlatButton(
                                                onPressed: () {
                                                  sl
                                                      .get<DBHelper>()
                                                      .changeAccount(
                                                          StateContainer.of(
                                                                  context)
                                                              .recentLast)
                                                      .then((_) {
                                                    EventTaxiImpl.singleton()
                                                        .fire(AccountChangedEvent(
                                                            account:
                                                                StateContainer.of(
                                                                        context)
                                                                    .recentLast,
                                                            delayPop: true));
                                                  });
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0)),
                                                highlightColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .text15,
                                                splashColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .text15,
                                                padding: EdgeInsets.all(0.0),
                                                child: Container(
                                                  width: 52,
                                                  height: 52,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 8.0),
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
                                              alignment:
                                                  AlignmentDirectional(0, 0.3),
                                              child: Text(
                                                  StateContainer.of(context)
                                                      .recentLast
                                                      .getShortName()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: StateContainer.of(
                                                            context)
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
                                                  sl
                                                      .get<DBHelper>()
                                                      .changeAccount(
                                                          StateContainer.of(
                                                                  context)
                                                              .recentLast)
                                                      .then((_) {
                                                    EventTaxiImpl.singleton()
                                                        .fire(AccountChangedEvent(
                                                            account:
                                                                StateContainer.of(
                                                                        context)
                                                                    .recentLast,
                                                            delayPop: true));
                                                  });
                                                },
                                                highlightColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .backgroundDark
                                                        .withOpacity(0.75),
                                                splashColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .backgroundDark
                                                        .withOpacity(0.75),
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
                                    )
                              : SizedBox(),
                          // Third Account
                          StateContainer.of(context).recentSecondLast != null
                              ? StateContainer.of(context).natriconOn
                                  ? Container(
                                      child: Stack(
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                              height: 52,
                                              width: 52,
                                              // natricon
                                              child: SvgPicture.network(
                                                UIUtil.getNatriconURL(
                                                    StateContainer.of(context)
                                                        .recentSecondLast
                                                        .address,
                                                    StateContainer.of(context)
                                                        .getNatriconNonce(
                                                            StateContainer.of(
                                                                    context)
                                                                .recentSecondLast
                                                                .address)),
                                                key: Key(UIUtil.getNatriconURL(
                                                    StateContainer.of(context)
                                                        .recentSecondLast
                                                        .address,
                                                    StateContainer.of(context)
                                                        .getNatriconNonce(
                                                            StateContainer.of(
                                                                    context)
                                                                .recentSecondLast
                                                                .address))),
                                                placeholderBuilder:
                                                    (BuildContext context) =>
                                                        Container(
                                                  child: FlareActor(
                                                    "assets/ntr_placeholder_animation.flr",
                                                    animation: "main",
                                                    fit: BoxFit.contain,
                                                    color: StateContainer.of(
                                                            context)
                                                        .curTheme
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.transparent,
                                              child: FlatButton(
                                                onPressed: () {
                                                  sl
                                                      .get<DBHelper>()
                                                      .changeAccount(
                                                          StateContainer.of(
                                                                  context)
                                                              .recentSecondLast)
                                                      .then((_) {
                                                    EventTaxiImpl.singleton()
                                                        .fire(AccountChangedEvent(
                                                            account: StateContainer
                                                                    .of(context)
                                                                .recentSecondLast,
                                                            delayPop: true));
                                                  });
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0)),
                                                highlightColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .text15,
                                                splashColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .text15,
                                                padding: EdgeInsets.all(0.0),
                                                child: Container(
                                                  width: 52,
                                                  height: 52,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 8.0),
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
                                              alignment:
                                                  AlignmentDirectional(0, 0.3),
                                              child: Text(
                                                  StateContainer.of(context)
                                                      .recentSecondLast
                                                      .getShortName()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: StateContainer.of(
                                                            context)
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
                                                  sl
                                                      .get<DBHelper>()
                                                      .changeAccount(
                                                          StateContainer.of(
                                                                  context)
                                                              .recentSecondLast)
                                                      .then((_) {
                                                    EventTaxiImpl.singleton()
                                                        .fire(AccountChangedEvent(
                                                            account: StateContainer
                                                                    .of(context)
                                                                .recentSecondLast,
                                                            delayPop: true));
                                                  });
                                                },
                                                highlightColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .backgroundDark
                                                        .withOpacity(0.75),
                                                splashColor:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .backgroundDark
                                                        .withOpacity(0.75),
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
                                    )
                              : SizedBox(),
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
                                if (!_loadingAccounts) {
                                  setState(() {
                                    _loadingAccounts = true;
                                  });
                                  StateContainer.of(context)
                                      .getSeed()
                                      .then((seed) {
                                    sl
                                        .get<DBHelper>()
                                        .getAccounts(seed)
                                        .then((accounts) {
                                      setState(() {
                                        _loadingAccounts = false;
                                      });
                                      AppAccountsSheet(accounts)
                                          .mainBottomSheet(context);
                                    });
                                  });
                                }
                              },
                              padding: EdgeInsets.all(0.0),
                              shape: CircleBorder(),
                              splashColor: _loadingAccounts
                                  ? Colors.transparent
                                  : StateContainer.of(context).curTheme.text30,
                              highlightColor: _loadingAccounts
                                  ? Colors.transparent
                                  : StateContainer.of(context).curTheme.text15,
                              child: Icon(AppIcons.accountswitcher,
                                  size: 36,
                                  color: _loadingAccounts
                                      ? StateContainer.of(context)
                                          .curTheme
                                          .primary60
                                      : StateContainer.of(context)
                                          .curTheme
                                          .primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    child: FlatButton(
                      padding: EdgeInsets.all(4.0),
                      highlightColor:
                          StateContainer.of(context).curTheme.text15,
                      splashColor: StateContainer.of(context).curTheme.text30,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      onPressed: () {
                        AccountDetailsSheet(
                                StateContainer.of(context).selectedAccount)
                            .mainBottomSheet(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Main account name
                          Container(
                            child: Text(
                              StateContainer.of(context).selectedAccount.name,
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
                              StateContainer.of(context).wallet != null &&
                                      StateContainer.of(context)
                                              .wallet
                                              .address !=
                                          null
                                  ? StateContainer.of(context)
                                      .wallet
                                      ?.address
                                      ?.substring(0, 12)
                                  : "",
                              style: TextStyle(
                                fontFamily: "OverpassMono",
                                fontWeight: FontWeight.w100,
                                fontSize: 14.0,
                                color:
                                    StateContainer.of(context).curTheme.text60,
                              ),
                            ),
                          ),
                        ],
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
                  padding: EdgeInsets.only(top: 15.0),
                  children: <Widget>[
                    // Active Alerts, Remote Message Card
                    StateContainer.of(context).settingsAlert != null
                        ? Container(
                            padding: EdgeInsetsDirectional.only(
                              start: 12,
                              end: 12,
                              bottom: 20,
                            ),
                            child: RemoteMessageCard(
                              alert: StateContainer.of(context).settingsAlert,
                              onPressed: () {
                                Sheets.showAppHeightEightSheet(
                                  context: context,
                                  widget: RemoteMessageSheet(
                                    alert: StateContainer.of(context)
                                        .settingsAlert,
                                    hasDismissButton: false,
                                  ),
                                );
                              },
                            ),
                          )
                        : null,
                    Container(
                      margin:
                          EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
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
                    AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context).blockExplorer,
                      StateContainer.of(context).curBlockExplorer,
                      AppIcons.search,
                      _explorerDialog,
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    // Natricon on-off
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).natricon,
                        _curNatriconSetting,
                        AppIcons.natricon,
                        _natriconDialog),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 30.0, top: 20.0, bottom: 10.0),
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
                        AppLocalization.of(context).backupSecretPhrase,
                        AppIcons.backupseed, onPressed: () async {
                      // Authenticate
                      AuthenticationMethod authMethod =
                          await sl.get<SharedPrefsUtil>().getAuthMethod();
                      bool hasBiometrics =
                          await sl.get<BiometricUtil>().hasBiometrics();
                      if (authMethod.method == AuthMethod.BIOMETRICS &&
                          hasBiometrics) {
                        try {
                          bool authenticated = await sl
                              .get<BiometricUtil>()
                              .authenticateWithBiometrics(
                                  context,
                                  AppLocalization.of(context)
                                      .fingerprintSeedBackup);
                          if (authenticated) {
                            sl.get<HapticUtil>().fingerprintSucess();
                            StateContainer.of(context).getSeed().then((seed) {
                              AppSeedBackupSheet(seed).mainBottomSheet(context);
                            });
                          }
                        } catch (e) {
                          AppDialogs.showConfirmDialog(
                              context,
                              "Error",
                              e.toString(),
                              "Copy to clipboard",
                              () {
                                Clipboard.setData(
                                    ClipboardData(text: e.toString()));
                              },
                              cancelText: "Close",
                              cancelAction: () {
                                Navigator.of(context).pop();
                              });
                          await authenticateWithPin();
                        }
                      } else {
                        await authenticateWithPin();
                      }
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
                      if (!StateContainer.of(context).nanoNinjaUpdated) {
                        NinjaAPI.getVerifiedNodes().then((result) {
                          if (result != null) {
                            StateContainer.of(context).updateNinjaNodes(result);
                          }
                        });
                      }
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
                          sl
                              .get<SharedPrefsUtil>()
                              .setNotificationsOn(false)
                              .then((_) async {
                            try {
                              String fcmToken =
                                  await FirebaseMessaging.instance.getToken();
                              EventTaxiImpl.singleton()
                                  .fire(FcmUpdateEvent(token: fcmToken));
                              EventTaxiImpl.singleton()
                                  .fire(FcmUpdateEvent(token: fcmToken));
                              // Delete all data
                              sl.get<Vault>().deleteAll().then((_) {
                                sl
                                    .get<SharedPrefsUtil>()
                                    .deleteAll()
                                    .then((result) {
                                  StateContainer.of(context).logOut();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/', (Route<dynamic> route) => false);
                                });
                              });
                            } catch (e) {}
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
                        begin: AlignmentDirectional(0.5, -1.0),
                        end: AlignmentDirectional(0.5, 1.0),
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

  Widget buildSecurityMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: [
          BoxShadow(
              color: StateContainer.of(context).curTheme.barrierWeakest,
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
                      margin:
                          EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
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
                    StateContainer.of(context).encryptedSecret == null
                        ? Column(children: <Widget>[
                            Divider(
                                height: 2,
                                color:
                                    StateContainer.of(context).curTheme.text15),
                            AppSettings.buildSettingsListItemDoubleLine(
                                context,
                                AppLocalization.of(context).lockAppSetting,
                                _curUnlockSetting,
                                AppIcons.lock,
                                _lockDialog),
                          ])
                        : SizedBox(),
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
                      disabled: _curUnlockSetting.setting == UnlockOption.NO &&
                          StateContainer.of(context).encryptedSecret == null,
                    ),
                    // Encrypt option
                    StateContainer.of(context).encryptedSecret == null
                        ? Column(children: <Widget>[
                            Divider(
                                height: 2,
                                color:
                                    StateContainer.of(context).curTheme.text15),
                            AppSettings.buildSettingsListItemSingleLine(
                                context,
                                AppLocalization.of(context).setWalletPassword,
                                AppIcons.walletpassword, onPressed: () {
                              Sheets.showAppHeightNineSheet(
                                  context: context, widget: SetPasswordSheet());
                            })
                          ])
                        : // Decrypt option
                        Column(children: <Widget>[
                            Divider(
                                height: 2,
                                color:
                                    StateContainer.of(context).curTheme.text15),
                            AppSettings.buildSettingsListItemSingleLine(
                                context,
                                AppLocalization.of(context)
                                    .disableWalletPassword,
                                AppIcons.walletpassworddisabled, onPressed: () {
                              Sheets.showAppHeightNineSheet(
                                  context: context,
                                  widget: DisablePasswordSheet());
                            }),
                          ]),
                    Divider(
                        height: 2,
                        color: StateContainer.of(context).curTheme.text15),
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
                        begin: AlignmentDirectional(0.5, -1.0),
                        end: AlignmentDirectional(0.5, 1.0),
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

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    String expectedPin = await sl.get<Vault>().getPin();
    bool auth = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        description: AppLocalization.of(context).pinSeedBackup,
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(Duration(milliseconds: 200));
      Navigator.of(context).pop();
      StateContainer.of(context).getSeed().then((seed) {
        AppSeedBackupSheet(seed).mainBottomSheet(context);
      });
    }
  }
}
