import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';

class IntroImportSeedPage extends StatefulWidget {
  @override
  _IntroImportSeedState createState() => _IntroImportSeedState();
}

class _IntroImportSeedState extends State<IntroImportSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  var _seedInputFocusNode = new FocusNode();
  var _seedInputController = new TextEditingController();
  // State constants
  static const _initialSeedTextStyle = KaliumStyles.TextStyleSeedGray;
  static const _validSeedTextStyle = KaliumStyles.TextStyleSeed;
  static const _initialErrorTextColor = Colors.transparent;
  static const _hasErrorTextColor = KaliumColors.primary;
  // State variables
  var _seedTextStyle;
  var _errorTextColor;

  @override
  void initState() {
    super.initState();
    setState(() {
      _seedTextStyle = _initialSeedTextStyle;
      _errorTextColor = _initialErrorTextColor;      
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));

    // Back button pressed
    Future<bool> _onWillPop() async {
      // Delete seed
      await Vault.inst.deleteAll();
      // Delete any shared prefs
      await Vault.inst.deleteAll();
      return true;
    }

    return new WillPopScope(
      onWillPop:_onWillPop,
      child: new Scaffold(
        key: _scaffoldKey,
        backgroundColor: KaliumColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) => Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.075),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                height: 50,
                                width: 50,
                                child: FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(KaliumIcons.back,
                                        color: KaliumColors.text, size: 24)),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15.0, left: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Import seed",
                                  style: KaliumStyles.TextStyleHeaderColored,
                                ),
                              ],
                            ),
                          ),
                          //Container for the text
                          Container(
                            margin:
                                EdgeInsets.only(left: 50, right: 50, top: 15.0),
                            child: Text(
                                "Please enter your seed below.",
                                style: KaliumStyles.TextStyleParagraph),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                            padding: EdgeInsets.only(left:20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: KaliumColors.backgroundDarkest,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              focusNode: _seedInputFocusNode,
                              controller: _seedInputController,
                              textAlign: TextAlign.center,
                              cursorColor: KaliumColors.primary,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(64),
                              ],
                              textInputAction: TextInputAction.done,
                              maxLines: null,
                              autocorrect: false,
                              decoration: InputDecoration(
                                suffixIcon: Container(
                                  width: 20,
                                  height: 20,
                                  child: FlatButton(
                                    onPressed: () {
                                      Clipboard.getData("text/plain").then((ClipboardData data) {
                                        if (data == null || data.text == null) {
                                          return;
                                        } else if (NanoSeeds.isValidSeed(data.text)) {
                                          _seedInputController.text = data.text;
                                          _seedTextStyle = _validSeedTextStyle;
                                        }
                                      });
                                    },
                                    child: Icon(KaliumIcons.paste,
                                        size: 20, color: KaliumColors.primary),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0)),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                  ),
                                ),
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100),
                              ),
                              keyboardType: TextInputType.text,
                              style: _seedTextStyle,
                              onChanged: (text) {
                                // Always reset the error message to be less annoying
                                setState(() {
                                  _errorTextColor = _initialErrorTextColor;
                                });
                                // If valid seed, clear focus/close keyboard
                                if (NanoSeeds.isValidSeed(text)) {
                                  _seedInputFocusNode.unfocus();
                                  setState(() {
                                    _seedTextStyle = _validSeedTextStyle;
                                  });
                                } else {
                                  setState(() {
                                    _seedTextStyle = _initialSeedTextStyle;
                                  });
                                }
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text('Invalid Seed',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: _errorTextColor,
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //A column with next screen button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 30, right: 30),
                        height: 50,
                        width: 50,
                        child: FlatButton(
                            splashColor: KaliumColors.primary30,
                            highlightColor: KaliumColors.primary15,
                            onPressed: () {
                              _seedInputFocusNode.unfocus();
                              // If seed valid, log them in
                              if (NanoSeeds.isValidSeed(_seedInputController.text)) {
                                SharedPrefsUtil.inst.setSeedBackedUp(true).then((result) {
                                  Vault.inst.setSeed(_seedInputController.text).then((result) {
                                    // Update wallet
                                    StateContainer.of(context).updateWallet(address:NanoUtil.seedToAddress(result));
                                    StateContainer.of(context).requestUpdate();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                                  });
                                });
                              } else {
                                // Display error
                                setState(() {
                                  _errorTextColor = _hasErrorTextColor;
                                });
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Icon(KaliumIcons.forward,
                                color: KaliumColors.primary, size: 50)),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      )
    );
  }
}