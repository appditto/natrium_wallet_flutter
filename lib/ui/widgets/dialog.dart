import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumDialogs {
  static void showConfirmDialog(
      var context, var title, var content, var buttonText, Function onPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: KaliumStyles.TextStyleButtonPrimaryOutline,
          ),
          content: Text(content, style: KaliumStyles.TextStyleParagraph),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "CANCEL",
                style: KaliumStyles.TextStyleDialogButtonText,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(buttonText,
              style: KaliumStyles.TextStyleDialogButtonText),
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
}