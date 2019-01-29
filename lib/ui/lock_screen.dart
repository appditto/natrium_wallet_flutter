import 'package:flutter/material.dart';
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

  Future<void> _authenticate({bool transitions = false}) async {
    SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
      BiometricUtil.hasBiometrics().then((hasBiometrics) {
        if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
          setState(() {
            _showLock = true;
            _showUnlockButton = false;
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
                          "LOCKED",
                          style: KaliumStyles.TextStyleHeaderColored,
                        ),
                        margin: EdgeInsets.only(top:10),
                      ),
                    ],
                  ) : SizedBox(),
                ),
                _showUnlockButton ? Row(
                  children: <Widget>[
                    KaliumButton.buildKaliumButton(
                      KaliumButtonType.PRIMARY,
                      "Unlock",
                      Dimens.BUTTON_BOTTOM_DIMENS,
                      onPressed: () {
                        _authenticate(transitions: true);
                      },
                    ),
                  ],
                ) : SizedBox(),
              ],
            )));
  }
}
