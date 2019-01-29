import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/model/authentication_method.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/util/biometrics.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/security.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/ui/util/routes.dart';

class KaliumLockScreen extends StatefulWidget {
  @override
  _KaliumLockScreenState createState() => _KaliumLockScreenState();
}

class _KaliumLockScreenState extends State<KaliumLockScreen> {

  bool _showUnlockButton = false;
  bool _showLock = false;
  bool _lockedOut = true;
  String _countDownTxt = "";

  Future<void> _goHome() async {
    if (StateContainer.of(context).wallet != null) {
      StateContainer.of(context).reconnect();
    } else {
      StateContainer.of(context).updateWallet(
          address: NanoUtil.seedToAddress(await Vault.inst.getSeed()));
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home_transition', (Route<dynamic> route) => false);
  }

  Widget _buildPinScreen(BuildContext context, String expectedPin) {
    return PinScreen(PinOverlayType.ENTER_PIN, 
              (pin) {
                _goHome();
              },
              expectedPin:expectedPin,
              description: KaliumLocalization.of(context).unlockPin,
              pinScreenBackgroundColor: KaliumColors.background);
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

  Future<void> _authenticate({bool transitions = false}) async {
    // Test if user is locked out
    // Get duration of lockout
    DateTime lockUntil = await SharedPrefsUtil.inst.getLockDate();
    if (lockUntil == null) {
      await SharedPrefsUtil.inst.resetLockAttempts();
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
    SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
      BiometricUtil.hasBiometrics().then((hasBiometrics) {
        if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
          setState(() {
            _showLock = true;
            _showUnlockButton = true;
          });
          BiometricUtil.authenticateWithBiometrics(
            KaliumLocalization.of(context).unlockBiometrics).then((authenticated) {
            if (authenticated) {
              _goHome();
            } else {
              setState(() {
                _showUnlockButton = true;
              });              
            }
          });
        } else {
          // PIN Authentication
          Vault.inst.getPin().then((expectedPin) {
            if (transitions) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) {
                    return _buildPinScreen(context, expectedPin);
                  }),
              );
            } else {
              Navigator.of(context).push(NoPushTransitionRoute(
                  builder: (BuildContext context) {
                    return _buildPinScreen(context, expectedPin);
                  }),
              );
            }
            Future.delayed(Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  _showUnlockButton = true;
                  _showLock = true;
                });
              }
            });
          });
        }
      });
    });
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
            color: KaliumColors.background,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _showLock ? Column(
                    children: <Widget>[
                      Container(
                        child: Icon(
                          KaliumIcons.lock,
                          size: 80,
                          color: KaliumColors.primary,
                        ),
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.1),
                      ),
                      Container(
                        child: Text(
                          KaliumLocalization.of(context).locked.toUpperCase(),
                          style: KaliumStyles.TextStyleHeaderColored,
                        ),
                        margin: EdgeInsets.only(top:10),
                      ),
                    ],
                  ) : SizedBox(),
                ),
                _lockedOut ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(KaliumLocalization.of(context).tooManyFailedAttempts,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: KaliumColors.primary,
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ) : SizedBox(),
                _showUnlockButton ? Row(
                  children: <Widget>[
                    KaliumButton.buildKaliumButton(
                       KaliumButtonType.PRIMARY,
                      _lockedOut ? _countDownTxt : KaliumLocalization.of(context).unlock,
                      Dimens.BUTTON_BOTTOM_DIMENS,
                      onPressed: () {
                        if (!_lockedOut) {
                          _authenticate(transitions: true);
                        }
                      },
                      disabled: _lockedOut
                    ),
                  ],
                ) : SizedBox(),
              ],
            )));
  }
}
