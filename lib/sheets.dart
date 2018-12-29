import 'package:flutter/material.dart';
import 'colors.dart';
import 'buttons.dart';
import 'kalium_icons.dart';
import 'settings_list_item.dart';
import 'package:flutter/services.dart';

class SettingsSheet extends StatefulWidget {
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  KaliumSeedBackupSheet seedbackup = new KaliumSeedBackupSheet();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: greyDark,
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
                    margin: EdgeInsets.only(left: 30.0, bottom: 10),
                    child: Text("Preferences",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100,
                            color: white60)),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [greyDark, greyDarkZero],
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

class KaliumReceiveSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightEightSheet(
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
                      child: threeLineAddressBuilder(
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
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/monkeyQR.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),

                //A column with "Scan QR Code" and "Send" buttons
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
}

class KaliumSendSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightNineSheet(
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

                    //Container for the header and address text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "SEND FROM",
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: threeLineAddressBuilder(
                                'ban_1yekta1xn94qdnbmmj1tqg76zk3apcfd31pjmuy6d879e3mr469a4o4sdhd4'),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 6.0),
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: '',
                                children: [
                                  TextSpan(
                                    text: "(",
                                    style: TextStyle(
                                      color: yellow60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: "412,580",
                                    style: TextStyle(
                                      color: yellow60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: " BAN",
                                    style: TextStyle(
                                      color: yellow60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: ")",
                                    style: TextStyle(
                                      color: yellow60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //This container is a temporary solution for the alignment problem
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                    ),
                  ],
                ),

                //A main container that holds "Enter Amount" and "Enter Address" text fields
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 70, right: 70),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: greyDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            cursorColor: yellow,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter Amount",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.w100),
                            ),
                            keyboardType: TextInputType.numberWithOptions(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color: yellow,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          margin: EdgeInsets.only(left: 70, right: 70, top: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: greyDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            cursorColor: yellow,
                            keyboardAppearance: Brightness.dark,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(64),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter Address",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans'),
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16.0,
                              color: white90,
                              fontFamily: 'OverpassMono',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with "Scan QR Code" and "Send" buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumOutlineButton(
                            'Scan QR Code', 30.0, 8.0, 30.0, 8.0),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton('Send', 30.0, 8.0, 30.0, 24.0),
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

class KaliumSeedBackupSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightNineSheet(
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

                    //Container for the header and address text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "SEED",
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 6.0),
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: '',
                                children: [
                                  TextSpan(
                                    text: "(",
                                    style: TextStyle(
                                      color: yellow60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: "412,580",
                                    style: TextStyle(
                                      color: yellow60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: " BAN",
                                    style: TextStyle(
                                      color: yellow60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //This container is a temporary solution for the alignment problem
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                    ),
                  ],
                ),

                //A main container that holds "Enter Amount" and "Enter Address" text fields
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 70, right: 70),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: greyDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            cursorColor: yellow,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter Amount",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.w100),
                            ),
                            keyboardType: TextInputType.numberWithOptions(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color: yellow,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          margin: EdgeInsets.only(left: 70, right: 70, top: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: greyDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            cursorColor: yellow,
                            keyboardAppearance: Brightness.dark,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(64),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter Address",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans'),
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16.0,
                              color: white90,
                              fontFamily: 'OverpassMono',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with "Scan QR Code" and "Send" buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumOutlineButton(
                            'Scan QR Code', 30.0, 8.0, 30.0, 8.0),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton('Send', 30.0, 8.0, 30.0, 24.0),
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

threeLineAddressBuilder(String address) {
  String stringPartOne = address.substring(0, 11);
  String stringPartTwo = address.substring(11, 22);
  String stringPartThree = address.substring(22, 44);
  String stringPartFour = address.substring(44, 58);
  String stringPartFive = address.substring(58, 64);
  return Column(
    children: <Widget>[
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '',
          children: [
            TextSpan(
              text: stringPartOne,
              style: TextStyle(
                color: yellow60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
            ),
            TextSpan(
              text: stringPartTwo,
              style: TextStyle(
                color: white60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
            ),
          ],
        ),
      ),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '',
          children: [
            TextSpan(
              text: stringPartThree,
              style: TextStyle(
                color: white60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
            ),
          ],
        ),
      ),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '',
          children: [
            TextSpan(
              text: stringPartFour,
              style: TextStyle(
                color: white60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
            ),
            TextSpan(
              text: stringPartFive,
              style: TextStyle(
                color: yellow60,
                fontSize: 14.0,
                height: 1.2,
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

class KaliumSmallBottomSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightEightSheet(
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
                            'View Details', 30.0, 26.0, 30.0, 8.0),
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

//Kalium Ninty Height Sheet
Future<T> showKaliumHeightNineSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  Color color = greyDark,
  double radius = 30.0,
}) {
  assert(context != null);
  assert(builder != null);
  assert(radius != null && radius > 0.0);
  assert(color != null && color != Colors.transparent);
  return Navigator.push<T>(
      context,
      _KaliumHeightNineModalRoute<T>(
        builder: builder,
        color: color,
        radius: radius,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ));
}

class _KaliumHeightNineSheetLayout extends SingleChildLayoutDelegate {
  _KaliumHeightNineSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: constraints.maxHeight * 0.9);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_KaliumHeightNineSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _KaliumHeightNineModalRoute<T> extends PopupRoute<T> {
  _KaliumHeightNineModalRoute({
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
                delegate: _KaliumHeightNineSheetLayout(animation.value),
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
//Kalium Height Nine Sheet End

//Kalium Height Eigth Sheet
Future<T> showKaliumHeightEightSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  Color color = greyDark,
  double radius = 30.0,
}) {
  assert(context != null);
  assert(builder != null);
  assert(radius != null && radius > 0.0);
  assert(color != null && color != Colors.transparent);
  return Navigator.push<T>(
      context,
      _KaliumHeightEightModalRoute<T>(
        builder: builder,
        color: color,
        radius: radius,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ));
}

class _KaliumHeightEightSheetLayout extends SingleChildLayoutDelegate {
  _KaliumHeightEightSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: constraints.maxHeight * 0.8);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_KaliumHeightEightSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _KaliumHeightEightModalRoute<T> extends PopupRoute<T> {
  _KaliumHeightEightModalRoute({
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
                delegate: _KaliumHeightEightSheetLayout(animation.value),
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
//Kalium HeightEight Sheet End
