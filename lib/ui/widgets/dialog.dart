import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/ui/widgets/kalium_simpledialog.dart';

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

enum AnimationType { SEND, GENERIC, TRANSFER_SEARCHING, TRANSFER_TRANSFERRING }
class AnimationLoadingOverlay extends ModalRoute<void> {
  AnimationType type;
  Function onPoppedCallback;

  AnimationLoadingOverlay(this.type, {this.onPoppedCallback});

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
  void didComplete(void result) {
    if (this.onPoppedCallback != null) {
      this.onPoppedCallback();
    }
    super.didComplete(result);
  }

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
                animation: "main",
                fit: BoxFit.contain);
      case AnimationType.TRANSFER_SEARCHING:
        return FlareActor("assets/searchseed_animation.flr",
                animation: "main",
                fit: BoxFit.contain);
      case AnimationType.TRANSFER_TRANSFERRING:
        return FlareActor("assets/transfer_animation.flr",
                animation: "main",
                fit: BoxFit.contain);
      case AnimationType.GENERIC:
      default:
        return  CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(KaliumColors.primary60));
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    switch (type) {
      case AnimationType.TRANSFER_SEARCHING:
      case AnimationType.TRANSFER_TRANSFERRING:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: _getAnimation(context),
            ),
          ],
        );
      default:
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: type == AnimationType.SEND ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: type == AnimationType.SEND ? EdgeInsets.only(bottom: 10.0, left:90, right:90) : EdgeInsets.zero,
                //Widgth/Height ratio is needed because BoxFit is not working as expected
                width: type == AnimationType.SEND ? double.infinity : 100,
                height: type == AnimationType.SEND ? MediaQuery.of(context).size.width : 100,
                child: _getAnimation(context),
              ),
            ],
        );
    }
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}