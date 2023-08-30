import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/bus/fcm_update_event.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/ui/util/routes.dart';
import 'package:natrium_wallet_flutter/ui/widgets/flat_button.dart';

class AppLockScreen extends StatefulWidget {
  @override
  _AppLockScreenState createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _showUnlockButton = false;
  bool _showLock = false;
  bool _lockedOut = true;
  String _countDownTxt = "";

  Future<void> _goHome() async {
    if (StateContainer.of(context).wallet != null) {
      StateContainer.of(context).reconnect();
    } else {
      await NanoUtil()
          .loginAccount(await StateContainer.of(context).getSeed(), context);
    }
    StateContainer.of(context).requestUpdate();
    PriceConversion conversion =
        await sl.get<SharedPrefsUtil>().getPriceConversion();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_transition', (Route<dynamic> route) => false,
        arguments: conversion);
  }

  Widget _buildPinScreen(BuildContext context, String expectedPin) {
    return PinScreen(PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        description: AppLocalization.of(context).unlockPin,
        pinScreenBackgroundColor:
            StateContainer.of(context).curTheme.backgroundDark);
  }

  String _formatCountDisplay(int count) {
    if (count <= 60) {
      // Seconds only
      String secondsStr = count.toString();
      if (count < 10) {
        secondsStr = "0" + secondsStr;
      }
      return "00:" + secondsStr;
    } else if (count > 60 && count <= 3600) {
      // Minutes:Seconds
      String minutesStr = "";
      int minutes = count ~/ 60;
      if (minutes < 10) {
        minutesStr = "0" + minutes.toString();
      } else {
        minutesStr = minutes.toString();
      }
      String secondsStr = "";
      int seconds = count % 60;
      if (seconds < 10) {
        secondsStr = "0" + seconds.toString();
      } else {
        secondsStr = seconds.toString();
      }
      return minutesStr + ":" + secondsStr;
    } else {
      // Hours:Minutes:Seconds
      String hoursStr = "";
      int hours = count ~/ 3600;
      if (hours < 10) {
        hoursStr = "0" + hours.toString();
      } else {
        hoursStr = hours.toString();
      }
      count = count % 3600;
      String minutesStr = "";
      int minutes = count ~/ 60;
      if (minutes < 10) {
        minutesStr = "0" + minutes.toString();
      } else {
        minutesStr = minutes.toString();
      }
      String secondsStr = "";
      int seconds = count % 60;
      if (seconds < 10) {
        secondsStr = "0" + seconds.toString();
      } else {
        secondsStr = seconds.toString();
      }
      return hoursStr + ":" + minutesStr + ":" + secondsStr;
    }
  }

  Future<void> _runCountdown(int count) async {
    if (count >= 1) {
      if (mounted) {
        setState(() {
          _showUnlockButton = true;
          _showLock = true;
          _lockedOut = true;
          _countDownTxt = _formatCountDisplay(count);
        });
      }
      Future.delayed(Duration(seconds: 1), () {
        _runCountdown(count - 1);
      });
    } else {
      if (mounted) {
        setState(() {
          _lockedOut = false;
        });
      }
    }
  }

  Future<void> authenticateWithBiometrics() async {
    bool authenticated = await sl
        .get<BiometricUtil>()
        .authenticateWithBiometrics(
            context, AppLocalization.of(context).unlockBiometrics);
    if (authenticated) {
      _goHome();
    } else {
      setState(() {
        _showUnlockButton = true;
      });
    }
  }

  Future<void> authenticateWithPin({bool transitions = false}) async {
    String expectedPin = await sl.get<Vault>().getPin();
    bool auth = false;
    if (transitions) {
      auth = await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return _buildPinScreen(context, expectedPin);
        }),
      );
    } else {
      auth = await Navigator.of(context).push(
        NoPushTransitionRoute(builder: (BuildContext context) {
          return _buildPinScreen(context, expectedPin);
        }),
      );
    }
    await Future.delayed(Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _showUnlockButton = true;
        _showLock = true;
      });
    }
    if (auth) {
      _goHome();
    }
  }

  Future<void> _authenticate({bool transitions = false}) async {
    // Test if user is locked out
    // Get duration of lockout
    DateTime lockUntil = await sl.get<SharedPrefsUtil>().getLockDate();
    if (lockUntil == null) {
      await sl.get<SharedPrefsUtil>().resetLockAttempts();
    } else {
      int countDown = lockUntil.difference(DateTime.now().toUtc()).inSeconds;
      // They're not allowed to attempt
      if (countDown > 0) {
        _runCountdown(countDown);
        return;
      }
    }
    setState(() {
      _lockedOut = false;
    });
    AuthenticationMethod authMethod =
        await sl.get<SharedPrefsUtil>().getAuthMethod();
    bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
    if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
      setState(() {
        _showLock = true;
        _showUnlockButton = true;
      });
      try {
        await authenticateWithBiometrics();
      } catch (e) {
        await authenticateWithPin(transitions: transitions);
      }
    } else {
      await authenticateWithPin(transitions: transitions);
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: StateContainer.of(context).curTheme.backgroundDark,
            width: double.infinity,
            child: SafeArea(
                minimum: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.035,
                ),
                child: Column(
                  children: <Widget>[
                    // Logout button
                    Container(
                      margin: EdgeInsetsDirectional.only(start: 16, top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            onPressed: () {
                              AppDialogs.showConfirmDialog(
                                  context,
                                  CaseChange.toUpperCase(
                                      AppLocalization.of(context).warning,
                                      context),
                                  AppLocalization.of(context).logoutDetail,
                                  AppLocalization.of(context)
                                      .logoutAction
                                      .toUpperCase(), () {
                                // Show another confirm dialog
                                AppDialogs.showConfirmDialog(
                                    context,
                                    AppLocalization.of(context)
                                        .logoutAreYouSure,
                                    AppLocalization.of(context)
                                        .logoutReassurance,
                                    CaseChange.toUpperCase(
                                        AppLocalization.of(context).yes,
                                        context), () {
                                  // Unsubscribe from notifications
                                  sl
                                      .get<SharedPrefsUtil>()
                                      .setNotificationsOn(false)
                                      .then((_) {
                                    FirebaseMessaging.instance
                                        .getToken()
                                        .then((fcmToken) {
                                      EventTaxiImpl.singleton().fire(
                                          FcmUpdateEvent(token: fcmToken));
                                      // Delete all data
                                      sl.get<Vault>().deleteAll().then((_) {
                                        sl
                                            .get<SharedPrefsUtil>()
                                            .deleteAll()
                                            .then((result) {
                                          StateContainer.of(context).logOut();
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  '/',
                                                  (Route<dynamic> route) =>
                                                      false);
                                        });
                                      });
                                    });
                                  });
                                });
                              });
                            },
                            highlightColor:
                                StateContainer.of(context).curTheme.text15,
                            splashColor:
                                StateContainer.of(context).curTheme.text30,
                            padding:
                                EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(AppIcons.logout,
                                      size: 16,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text),
                                  Container(
                                    margin:
                                        EdgeInsetsDirectional.only(start: 4),
                                    child: Text(
                                        AppLocalization.of(context).logout,
                                        style: AppStyles.textStyleLogoutButton(
                                            context)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _showLock
                          ? Column(
                              children: <Widget>[
                                Container(
                                  child: Icon(
                                    AppIcons.lock,
                                    size: 80,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary,
                                  ),
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.1),
                                ),
                                Container(
                                  child: Text(
                                    CaseChange.toUpperCase(
                                        AppLocalization.of(context).locked,
                                        context),
                                    style: AppStyles.textStyleHeaderColored(
                                        context),
                                  ),
                                  margin: EdgeInsets.only(top: 10),
                                ),
                              ],
                            )
                          : SizedBox(),
                    ),
                    _lockedOut
                        ? Container(
                            width: MediaQuery.of(context).size.width - 100,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            child: Text(
                              AppLocalization.of(context).tooManyFailedAttempts,
                              style: AppStyles.textStyleErrorMedium(context),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : SizedBox(),
                    _showUnlockButton
                        ? Row(
                            children: <Widget>[
                              AppButton.buildAppButton(
                                  context,
                                  AppButtonType.PRIMARY,
                                  _lockedOut
                                      ? _countDownTxt
                                      : AppLocalization.of(context).unlock,
                                  Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                                if (!_lockedOut) {
                                  _authenticate(transitions: true);
                                }
                              }, disabled: _lockedOut),
                            ],
                          )
                        : SizedBox(),
                  ],
                ))));
  }
}
