import 'package:flutter/material.dart';
import 'colors.dart';
import 'buttons.dart';
import 'kalium_icons.dart';
import 'main.dart';

Widget buildSettingsSheet() {
  return Container(
    color: greyDark,
    child: Column(
      children: <Widget>[
        Container(
          margin: new EdgeInsets.only(left: 30.0, top: 50.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Text("Settings",
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                      color: white90))
            ],
          ),
        ),
        Expanded(
            child: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.only(bottom: 10.0, top: 15.0),
              children: <Widget>[
                Container(
                  margin: new EdgeInsets.only(left: 30.0),
                  child: Text("Preferences",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w100,
                          color: white60)),
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
                          child: new Icon(KaliumIcons.currency,
                              color: yellow, size: 24)),
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
                                fontSize: 12.0,
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
                          child: new Icon(KaliumIcons.language,
                              color: yellow, size: 24)),
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
                                fontSize: 12.0,
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
                              color: yellow, size: 24)),
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
                                fontSize: 12.0,
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
                              color: yellow, size: 24)),
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
                                fontSize: 12.0,
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
                          fontSize: 16.0,
                          fontWeight: FontWeight.w100,
                          color: white60)),
                ),
                Divider(),
                Container(
                  height: 50.0,
                  margin: new EdgeInsets.only(left: 30.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                          margin: new EdgeInsets.only(right: 16.0),
                          child: new Icon(KaliumIcons.contacts,
                              color: yellow, size: 24)),
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
                              color: yellow, size: 24)),
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
                              color: yellow, size: 24)),
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
                              color: yellow, size: 24)),
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
                          child: new Icon(KaliumIcons.logout,
                              color: yellow, size: 24)),
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
                          fontSize: 16.0,
                          fontWeight: FontWeight.w100,
                          color: white60),
                    ),
                  ],
                ),
              ],
            ),
            //List Top Gradient End
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 20.0,
                width: double.infinity,
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    colors: [greyDark, greyDarkZero],
                    begin: new Alignment(0.5, -1.0),
                    end: new Alignment(0.5, 1.0),
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

class KaliumBottomSheet {
  receiveAddressBuilder(String address) {
    String stringPartOne = address.substring(0, 11);
    String stringPartTwo = address.substring(11, 22);
    String stringPartThree = address.substring(22, 44);
    String stringPartFour = address.substring(44, 58);
    String stringPartFive = address.substring(58, 64);
    return Column(
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
            text: '',
            children: [
              new TextSpan(
                text: stringPartOne,
                style: new TextStyle(
                  color: yellow60,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
              new TextSpan(
                text: stringPartTwo,
                style: new TextStyle(
                  color: white60,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top:2.0, bottom: 2.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: new TextSpan(
              text: '',
              children: [
                new TextSpan(
                  text: stringPartThree,
                  style: new TextStyle(
                    color: white60,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w100,
                    fontFamily: 'OverpassMono',
                  ),
                ),
              ],
            ),
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
            text: '',
            children: [
              new TextSpan(
                text: stringPartFour,
                style: new TextStyle(
                  color: white60,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
              new TextSpan(
                text: stringPartFive,
                style: new TextStyle(
                  color: yellow60,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
  mainBottomSheet(BuildContext context) {
    showRoundedModalBottomSheet(
        radius: 30.0,
        color: greyDark,
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 26.0, left: 26.0),
                    child: Icon(KaliumIcons.exit, size: 16, color:white90),
                  ),
                ),
                receiveAddressBuilder('ban_1yekta1xn94qdnbmmj1tqg76zk3apcfd31pjmuy6d879e3mr469a4o4sdhd4'),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top:35, bottom:35),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new AssetImage('assets/monkeyQR.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumOutlineButton(
                            'Share Address', 30.0, 8.0, 30.0, 8.0),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
                            'Copy Address', 30.0, 8.0, 30.0, 25.0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

/// Below is the usage for this function, you'll only have to import this file
/// [radius] takes a double and will be the radius to the rounded corners of this modal
/// [color] will color the modal itself, the default being `Colors.white`
/// [builder] takes the content of the modal, if you're using [Column]
/// or a similar widget, remember to set `mainAxisSize: MainAxisSize.min`
/// so it will only take the needed space.
///
/// ```dart
/// showRoundedModalBottomSheet(
///    context: context,
///    radius: 10.0,  // This is the default
///    color: Colors.white,  // Also default
///    builder: (context) => ???,
/// );
/// ```
Future<T> showRoundedModalBottomSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  Color color = Colors.white,
  double radius = 10.0,
}) {
  assert(context != null);
  assert(builder != null);
  assert(radius != null && radius > 0.0);
  assert(color != null && color != Colors.transparent);
  return Navigator.push<T>(
      context,
      _RoundedCornerModalRoute<T>(
        builder: builder,
        color: color,
        radius: radius,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ));
}

class _RoundedModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _RoundedModalBottomSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: constraints.maxHeight * 0.85);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return new Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_RoundedModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _RoundedCornerModalRoute<T> extends PopupRoute<T> {
  _RoundedCornerModalRoute({
    this.builder,
    this.barrierLabel,
    this.color,
    this.radius,
    RouteSettings settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final double radius;
  final Color color;

  @override
  Color get barrierColor => black70;

  @override
  bool get barrierDismissible => true;

  @override
  String barrierLabel;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) => CustomSingleChildLayout(
                delegate: _RoundedModalBottomSheetLayout(animation.value),
                child: BottomSheet(
                  animationController: _animationController,
                  onClosing: () => Navigator.pop(context),
                  builder: (context) => Container(
                        decoration: BoxDecoration(
                          color: this.color,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(this.radius),
                            topRight: Radius.circular(this.radius),
                          ),
                        ),
                        child: SafeArea(child: Builder(builder: this.builder)),
                      ),
                ),
              ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);
}
