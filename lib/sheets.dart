import 'package:flutter/material.dart';
import 'colors.dart';
import 'buttons.dart';

Widget buildSettingsSheet() {
  return Container(
    color: greyDark,
    child: ListView(
      children: <Widget>[
        Container(
          margin: new EdgeInsets.only(left: 30.0, top: 30.0),
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
          margin: new EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(Icons.contacts, color: yellow, size: 22)),
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
          margin: new EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(Icons.backup, color: yellow, size: 22)),
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
          margin: new EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child:
                      new Icon(Icons.file_download, color: yellow, size: 22)),
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
          margin: new EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(Icons.swap_calls, color: yellow, size: 22)),
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
          margin: new EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new Icon(Icons.share, color: yellow, size: 22)),
              Text(
                "Share Kalium",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: white90),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    ),
  );
}

class Modal{
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
