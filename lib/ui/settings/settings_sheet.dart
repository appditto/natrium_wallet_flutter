import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/settings/backup_seed.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_list_item.dart';

class SettingsSheet extends StatefulWidget {
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  KaliumSeedBackupSheet seedbackup = new KaliumSeedBackupSheet();
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
                Text("Settings",
                    style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w800,
                        color: KaliumColors.text))
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
                  buildSettingsListItemDoubleLine('Authentication Method',
                      'Fingerprint', KaliumIcons.fingerprint),
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
                      'Backup Seed', KaliumIcons.backupseed),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine(
                      'Load from Paper Wallet', KaliumIcons.transferfunds),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine('Change Representative',
                      KaliumIcons.changerepresentative),
                  Divider(height: 2),
                  buildSettingsListItemSingleLine('Logout', KaliumIcons.logout),
                  Divider(height: 2),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "KaliumF v0.1",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w100,
                              color: KaliumColors.text60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //List Top Gradient End
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 20.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [KaliumColors.backgroundDark, KaliumColors.backgroundDark00],
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