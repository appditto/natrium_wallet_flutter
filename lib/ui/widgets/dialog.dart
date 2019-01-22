import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/ui/widgets/kalium_simpledialog.dart';
import 'package:kalium_wallet_flutter/util/hapticutil.dart';

class KaliumDialogs {
  static void showConfirmDialog(
      var context, var title, var content, var buttonText, Function onPressed, {String cancelText}) {
    if (cancelText == null) {
      cancelText = KaliumLocalization.of(context).cancel.toUpperCase();
    }
    showKaliumDialog(
      context: context,
      builder: (BuildContext context) {
        return KaliumAlertDialog(
          title: Text(
            title,
            style: KaliumStyles.TextStyleButtonPrimaryOutline,
          ),
          content: Text(content, style: KaliumStyles.TextStyleParagraph),
          actions: <Widget>[
            FlatButton(
              child: Text(
                cancelText,
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

  static void showInfoDialog(
      var context, var title, var content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return KaliumAlertDialog(
          title: Text(
            title,
            style: KaliumStyles.TextStyleButtonPrimaryOutline,
          ),
          content: Text(content, style: KaliumStyles.TextStyleParagraph),
          actions: <Widget>[
            FlatButton(
              child: Text(
                KaliumLocalization.of(context).cancel.toUpperCase(),
                style: KaliumStyles.TextStyleDialogButtonText,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

enum AnimationType { SEND, GENERIC }
class AnimationLoadingOverlay extends ModalRoute<void> {
  AnimationType type;

  AnimationLoadingOverlay(this.type);

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

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
  Widget _getAnimation(BuildContext context) {
    switch (type) {
      case AnimationType.SEND:
        return FlareActor("assets/send_animation.flr",
                animation: "long",
                fit: BoxFit.contain);
      case AnimationType.GENERIC:
      default:
        return  CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(KaliumColors.primary60));
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    HapticUtil.fingerprintSuccess();
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: type == AnimationType.GENERIC ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: type == AnimationType.SEND ? EdgeInsets.only(bottom: 10.0, left:90, right:90) : EdgeInsets.zero,
            //Widgth/Height ratio is needed because BoxFit is not working as expected
            width: type == AnimationType.GENERIC ? 100 : double.infinity,
            height: type == AnimationType.GENERIC ? 100 : MediaQuery.of(context).size.width,
            child: _getAnimation(context),
          ),
        ],
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}