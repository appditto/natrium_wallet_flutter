import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/colors.dart';

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

class SendAnimationOverlay extends ModalRoute<void> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 100);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => KaliumColors.overlay70;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10.0, left:90, right:90),
            //Widgth/Height ratio is needed because BoxFit is not working as expected
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            child: FlareActor("assets/send_animation.flr",
                animation: "main",
                fit: BoxFit.contain),
          ),
        ],
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}