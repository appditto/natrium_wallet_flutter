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

class KaliumLockScreen extends StatefulWidget {
  @override
  _KaliumLockScreenState createState() => _KaliumLockScreenState();
}

class _KaliumLockScreenState extends State<KaliumLockScreen> {
  Future<void> _goHome() async {
    if (StateContainer.of(context).wallet != null) {
      StateContainer.of(context).reconnect();
    } else {
      StateContainer.of(context).updateWallet(
          address: NanoUtil.seedToAddress(await Vault.inst.getSeed()));
    }
    Navigator.of(context).pushReplacementNamed('/home_transition');
  }

  Future<void> _authenticate() async {
    SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
      BiometricUtil.hasBiometrics().then((hasBiometrics) {
        if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
          BiometricUtil.authenticateWithBiometrics(
                  KaliumLocalization.of(context).unlockBiometrics)
              .then((authenticated) {
            if (authenticated) {
              _goHome();
            }
          });
        } else {
          // PIN Authentication
          Vault.inst.getPin().then((expectedPin) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return new PinScreen(PinOverlayType.ENTER_PIN, (pin) {
                _goHome();
              },
                  expectedPin: expectedPin,
                  description: KaliumLocalization.of(context).unlockPin,
                  pinScreenBackgroundColor: KaliumColors.background,);
            }));
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
                  child: Column(
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
                  ),
                ),
                Row(
                  children: <Widget>[
                    KaliumButton.buildKaliumButton(
                      KaliumButtonType.PRIMARY,
                      "Unlock",
                      Dimens.BUTTON_BOTTOM_DIMENS,
                      onPressed: () {
                        _authenticate();
                      },
                    ),
                  ],
                ),
              ],
            )));
  }
}
