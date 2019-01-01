import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/styles.dart';

// TODO add Text Styles
void showConfirmDialog(var context, var title, var content, var buttonText, Function onPressed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text(buttonText),
            onPressed: () {
              Navigator.of(context).pop();
              onPressed();
            },
          ),
        ],
      );
    },
  );
}