import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/model/authentication_method.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/settings/backupseed_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/changerepresentative_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_list_item.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/widgets/security.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/biometrics.dart';

class SettingsSheet extends StatefulWidget {
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _hasBiometrics = false;
  AuthenticationMethod _curAuthMethod =
      AuthenticationMethod(AuthMethod.BIOMETRICS);

  void pinEnteredTest(String pin) {
    print("Pin Entered $pin");
  }

  @override
  void initState() {
    super.initState();
    // Determine if they have face or fingerprint enrolled, if not hide the setting
    BiometricUtil.hasBiometrics().then((bool hasBiometrics) {
      setState(() {
        _hasBiometrics = hasBiometrics;
      });
    });
    SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
      setState(() {
        _curAuthMethod = authMethod;
      });
    });
  }

  Future<void> _authMethodDialog() async {
    switch (await showDialog<AuthMethod>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(
              "Choose Authentication Method",
              style: KaliumStyles.TextStyleDialogHeader,
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.PIN);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const Text(
                    'PIN',
                    style: KaliumStyles.TextStyleDialogOptions,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.BIOMETRICS);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const Text(
                    'Biometrics',
                    style: KaliumStyles.TextStyleDialogOptions,
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

  bool notNull(Object o) => o != null;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: KaliumColors.backgroundDark,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 30.0, top: 60.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Text("Settings", style: KaliumStyles.TextStyleHeader),
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
                    child: Text("Preferences",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100,
                            color: KaliumColors.text60)),
                  ),
                  Divider(height: 2),
                  buildSettingsListItemDoubleLine('Change Currency',
                      'System Default', KaliumIcons.currency),
                  Divider(height: 2),
                  buildSettingsListItemDoubleLine(
                      'Language', 'System Default', KaliumIcons.language),
                  Divider(height: 2),
                  _hasBiometrics
                      ? KaliumSettings.buildSettingsListItemDoubleLine(
                          "Authentication Method",
                          _curAuthMethod,
                          KaliumIcons.fingerprint,
                          _authMethodDialog)
                      : null,
                  Divider(height: 2),
                  buildSettingsListItemDoubleLine(
                      'Notifications', 'On', KaliumIcons.notifications),
                  Divider(height: 2),
                  Container(
                    margin:
                        EdgeInsets.only(left: 30.0, top: 20.0, bottom: 10.0),
                    child: Text("Manage",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100,
                            color: KaliumColors.text60)),
                  ),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine(
                      'Contacts', KaliumIcons.contacts),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine(
                      'Backup Seed', KaliumIcons.backupseed, onPressed: () {
                    // Authenticate
                    SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
                      BiometricUtil.hasBiometrics().then((hasBiometrics) {
                        if (authMethod.method == AuthMethod.BIOMETRICS &&
                            hasBiometrics) {
                          BiometricUtil.authenticateWithBiometrics(
                                  "Backup Seed")
                              .then((authenticated) {
                            if (authenticated) {
                              new KaliumSeedBackupSheet()
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
                                (pin) => new KaliumSeedBackupSheet()
                                    .mainBottomSheet(context),
                                expectedPin: expectedPin,
                                description: "Enter PIN to backup seed",
                              );
                            }));
                          });
                        }
                      });
                    });
                  }),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine(
                      'Load from Paper Wallet', KaliumIcons.transferfunds,
                      onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return new PinScreen(
                          PinOverlayType.NEW_PIN, pinEnteredTest);
                    }));
                  }),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine(
                      'Change Representative', KaliumIcons.changerepresentative,
                      onPressed: () {
                    new KaliumChangeRepresentativeSheet()
                        .mainBottomSheet(context);
                  }),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine('Logout', KaliumIcons.logout,
                      onPressed: () {
                    KaliumDialogs.showConfirmDialog(
                        context,
                        "WARNING",
                        "Logging out will remove your seed and all Kalium-related data from this device. If your seed is not backed up, you will never be able to access your funds again",
                        "DELETE SEED AND LOGOUT", () {
                      // Show another confirm dialog
                      KaliumDialogs.showConfirmDialog(
                          context,
                          "Are you sure?",
                          "As long as you've backed up your seed you have nothing to worry about.",
                          "YES", () {
                        Vault.inst.deleteAll().then((Null) {
                          SharedPrefsUtil.inst.deleteAll().then((result) {
                            StateContainer.of(context).logOut();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/', (Route<dynamic> route) => false);
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
                        Text("KaliumF v0.1",
                            style: KaliumStyles.TextStyleVersion),
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
                        KaliumColors.backgroundDark,
                        KaliumColors.backgroundDark00
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
