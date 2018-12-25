import 'package:flutter/material.dart';
import 'colors.dart';
import 'buttons.dart';
import 'kalium_icons.dart';

Widget buildSettingsSheet() {
  return Container(
    color: greyDark,
    child: ListView(
      padding: EdgeInsets.only(bottom: 10.0),
      children: <Widget>[
        Container(
          margin: new EdgeInsets.only(left: 30.0, top: 40.0),
          child: Text("Settings",
              style: TextStyle(
                  fontSize: 30.0, fontWeight: FontWeight.w800, color: white90)),
        ),
        Container(
          margin: new EdgeInsets.only(left: 30.0, top: 20.0),
          child: Text("Preferences",
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w100, color: white60)),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child:
                      new Icon(KaliumIcons.currency, color: yellow, size: 22)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Change Currency",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: white90),
                  ),
                  Text(
                    "\$ US Dollar",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w100,
                        color: white60),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child:
                      new Icon(KaliumIcons.language, color: yellow, size: 22)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Language",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: white90),
                  ),
                  Text(
                    "System Default",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w100,
                        color: white60),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(KaliumIcons.fingerprint,
                      color: yellow, size: 22)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Authentication Method",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: white90),
                  ),
                  Text(
                    "Fingerprint",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w100,
                        color: white60),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(KaliumIcons.notifications,
                      color: yellow, size: 22)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Notifications",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: white90),
                  ),
                  Text(
                    "On",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w100,
                        color: white60),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          margin: new EdgeInsets.only(left: 30.0, top: 20.0),
          child: Text("Manage",
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w100, color: white60)),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child:
                      new Icon(KaliumIcons.contacts, color: yellow, size: 22)),
              Text(
                "Contacts",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: white90),
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(KaliumIcons.backupseed,
                      color: yellow, size: 22)),
              Text(
                "Backup Seed",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: white90),
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(KaliumIcons.transferfunds,
                      color: yellow, size: 22)),
              Text(
                "Load from Paper Wallet",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: white90),
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(KaliumIcons.changerepresentative,
                      color: yellow, size: 22)),
              Text(
                "Change Representative",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: white90),
              ),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 50.0,
          margin: new EdgeInsets.only(left: 30.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(KaliumIcons.logout, color: yellow, size: 22)),
              Text(
                "Logout",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: white90),
              ),
            ],
          ),
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "KaliumF v0.1",
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w100, color: white60),
            ),
          ],
        ),
      ],
    ),
  );
}

class Modal {
  mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            color: greyDark,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                    margin: new EdgeInsets.only(left: 90.0, right: 90, top: 30),
                    child: Text(
                      "ban_1yekta1u3ymis5tji4jxpr4iz8a9bp4bjoz5qdw3wstbub3wgxwi3nfuuyek",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontFamily: 'OverpassMono',
                        fontWeight: FontWeight.w100,
                        color: white60,
                      ),
                    )),
                Expanded(
                  child: Container(
                    width: 300.0,
                    height: 300.0,
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new AssetImage('assets/monkeyQR.png'),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    buildKaliumButton('Copy Address', 14.0, 14.0, 14.0, 22.0),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
