import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/colors.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';

class IntroImportSeedPage extends StatefulWidget {
  @override
  _IntroImportSeedState createState() => _IntroImportSeedState();
}

class _IntroImportSeedState extends State<IntroImportSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  var _seedInputFocusNode = new FocusNode();
  var _seedInputController = new TextEditingController();
  // State constants
  static const _initialSeedTextStyle = AppStyles.TextStyleSeedGray;
  static const _validSeedTextStyle = AppStyles.TextStyleSeed;
  static const _initialErrorTextColor = Colors.transparent;
  static const _hasErrorTextColor = AppColors.primary;
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
        .copyWith(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent));

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
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) => Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.075),
                      child: Stack(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              // Clear focus of our fields when tapped in this empty space
                              _seedInputFocusNode.unfocus();
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: SizedBox.expand(),
                              constraints: BoxConstraints.expand(),
                            ),
                          ),
                          Column(
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
                                        child: Icon(AppIcons.back,
                                            color: AppColors.text, size: 24)),
                                  ),
                                ],
                              ),
                              // The header
                              Container(
                                margin: EdgeInsets.only(top: 15.0, left: 50),
                                alignment: Alignment(-1, 0),
                                child: Text(
                                  AppLocalization.of(context).importSeed,
                                  style: AppStyles.TextStyleHeaderColored,
                                ),
                              ),
                              // The paragraph
                              Container(
                                margin:
                                    EdgeInsets.only(left: 50, right: 50, top: 15.0),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    AppLocalization.of(context).importSeedHint,
                                    style: AppStyles.TextStyleParagraph,
                                    textAlign: TextAlign.left,),
                              ),
                              // The container for the seed
                              Container(
                                margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundDark,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                // Text Field for the seed
                                child: TextField(
                                  focusNode: _seedInputFocusNode,
                                  controller: _seedInputController,
                                  textAlign: TextAlign.center,
                                  cursorColor: AppColors.primary,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(65),
                                  ],
                                  textInputAction: TextInputAction.done,
                                  maxLines: null,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    // Emtpy SizedBox
                                    prefixIcon: SizedBox(
                                      width: 48,
                                      height: 48,
                                    ),
                                    // Paste Button
                                    suffixIcon: AnimatedCrossFade(
                                        duration: Duration(milliseconds: 100),
                                        firstChild: Container(
                                        width: 48,
                                        height: 48,
                                        child: FlatButton(
                                          child: Icon(AppIcons.paste,
                                              size: 20, color: AppColors.primary),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100.0)),
                                          padding: EdgeInsets.all(14.0),
                                          onPressed: () {
                                            if (NanoSeeds.isValidSeed(_seedInputController.text)) {
                                              return;
                                            }
                                            Clipboard.getData("text/plain").then((ClipboardData data) {
                                              if (data == null || data.text == null) {
                                                return;
                                              } else if (NanoSeeds.isValidSeed(data.text)) {
                                                _seedInputController.text = data.text;
                                                _seedTextStyle = _validSeedTextStyle;
                                              }
                                            });
                                          },
                                        ),  
                                      ),
                                      secondChild: SizedBox(),
                                      crossFadeState: NanoSeeds.isValidSeed(_seedInputController.text) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                              // "Invalid Seed" text that appears if the input is invalid
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(AppLocalization.of(context).seedInvalid,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: _errorTextColor,
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Next Screen Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 30, right: 30),
                        height: 50,
                        width: 50,
                        child: FlatButton(
                            splashColor: AppColors.primary30,
                            highlightColor: AppColors.primary15,
                            onPressed: () {
                              _seedInputFocusNode.unfocus();
                              // If seed valid, log them in
                              if (NanoSeeds.isValidSeed(_seedInputController.text)) {
                                SharedPrefsUtil.inst.setSeedBackedUp(true).then((result) {
                                  Vault.inst.setSeed(_seedInputController.text).then((result) {
                                    StateContainer.of(context).updateWallet(address:NanoUtil.seedToAddress(result));
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return new PinScreen(PinOverlayType.NEW_PIN, (_pinEnteredCallback));
                                    }));
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
                            child: Icon(AppIcons.forward,
                                color: AppColors.primary, size: 50)),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      )
    );
  }

  void _pinEnteredCallback(String pin) {
    Navigator.of(context).pop();
    Vault.inst.writePin(pin).then((result) {
      // Update wallet
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    });
  }
}