import 'package:flutter/material.dart';
import 'colors.dart';
import 'buttons.dart';
import 'kalium_icons.dart';
import 'settings_list_item.dart';

Widget buildSettingsSheet() {
  return Container(
    color: greyDark,
    child: Column(
      children: <Widget>[
        Container(
          margin: new EdgeInsets.only(left: 30.0, top: 60.0, bottom: 10.0),
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
              padding: EdgeInsets.only(top: 15.0),
              children: <Widget>[
                Container(
                  margin: new EdgeInsets.only(left: 30.0, bottom: 10),
                  child: Text("Preferences",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w100,
                          color: white60)),
                ),
                Divider(height: 2),
                buildSettingsListItemDoubleLine(
                    'Change Currency', 'System Default', KaliumIcons.currency),
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
                      new EdgeInsets.only(left: 30.0, top: 20.0, bottom: 10.0),
                  child: Text("Manage",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w100,
                          color: white60)),
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
                buildSettingsListItemSingleLine('Change Representative', KaliumIcons.changerepresentative),
                Divider(height: 2),
                buildSettingsListItemSingleLine('Logout', KaliumIcons.logout),
                Divider(height: 2),
                Padding(
                  padding: EdgeInsets.only(top:10.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "KaliumF v0.1",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w100,
                            color: white60),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, left: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:
                            Icon(KaliumIcons.close, size: 16, color: white90),
                        padding: EdgeInsets.all(17.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),

                    //Container for the address text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: receiveAddressBuilder(
                          'ban_1yekta1xn94qdnbmmj1tqg76zk3apcfd31pjmuy6d879e3mr469a4o4sdhd4'),
                    ),

                    //This container is a temporary solution for the alignment problem
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                    ),
                  ],
                ),

                //MonkeyQR which takes all the available space left from the buttons & address text
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
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
                            'Copy Address', 30.0, 8.0, 30.0, 24.0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

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
                  height: 1.1,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
              new TextSpan(
                text: stringPartTwo,
                style: new TextStyle(
                  color: white60,
                  fontSize: 15.0,
                  height: 1.1,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
            ],
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
            text: '',
            children: [
              new TextSpan(
                text: stringPartThree,
                style: new TextStyle(
                  color: white60,
                  fontSize: 15.0,
                  height: 1.1,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
            ],
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
                  height: 1.1,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'OverpassMono',
                ),
              ),
              new TextSpan(
                text: stringPartFive,
                style: new TextStyle(
                  color: yellow60,
                  fontSize: 15.0,
                  height: 1.1,
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

class KaliumSmallBottomSheet {
  mainBottomSheet(BuildContext context) {
    showRoundedModalBottomSheet(
        radius: 30.0,
        color: greyDark,
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumOutlineButton(
                            'View Details', 30.0, 24.0, 30.0, 8.0),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
                            'Copy Address', 30.0, 8.0, 30.0, 24.0),
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
