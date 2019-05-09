import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
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

  bool _seedIsValid = false;
  bool _showSeedError = false;

  @override
  Widget build(BuildContext context) {
    // Back button pressed
    Future<bool> _onWillPop() async {
      // Delete seed
      await sl.get<Vault>().deleteAll();
      // Delete any shared prefs
      await sl.get<Vault>().deleteAll();
      return true;
    }

    return new WillPopScope(
        onWillPop: _onWillPop,
        child: new Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          body: LayoutBuilder(
            builder: (context, constraints) => SafeArea(
                  minimum: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.035,
                      top: MediaQuery.of(context).size.height * 0.075),
                  child: Column(
                    children: <Widget>[
                      Expanded(
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
                                          highlightColor:
                                              StateContainer.of(context)
                                                  .curTheme
                                                  .text15,
                                          splashColor:
                                              StateContainer.of(context)
                                                  .curTheme
                                                  .text15,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0)),
                                          padding: EdgeInsets.all(0.0),
                                          child: Icon(AppIcons.back,
                                              color: StateContainer.of(context)
                                                  .curTheme
                                                  .text,
                                              size: 24)),
                                    ),
                                  ],
                                ),
                                // The header
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 15.0, left: 50, right: 50),
                                  alignment: Alignment(-1, 0),
                                  child: Text(
                                    AppLocalization.of(context).importSeed,
                                    style: AppStyles.textStyleHeaderColored(
                                        context),
                                  ),
                                ),
                                // The paragraph
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 50, right: 50, top: 15.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppLocalization.of(context).importSeedHint,
                                    style:
                                        AppStyles.textStyleParagraph(context),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                // The container for the seed
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 50, right: 50, top: 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .backgroundDarkest,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  // Text Field for the seed
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent),
                                    child: TextField(
                                      focusNode: _seedInputFocusNode,
                                      controller: _seedInputController,
                                      textAlign: TextAlign.center,
                                      cursorColor: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(64),
                                      ],
                                      textInputAction: TextInputAction.done,
                                      maxLines: null,
                                      autocorrect: false,
                                      decoration: InputDecoration(
                                        // Emtpy SizedBox
                                        prefixIcon: AnimatedCrossFade(
                                          duration: Duration(milliseconds: 100),
                                          firstChild: Container(
                                            width: 48,
                                            height: 48,
                                            child: FlatButton(
                                              highlightColor:
                                                  StateContainer.of(context)
                                                      .curTheme
                                                      .primary15,
                                              splashColor:
                                                  StateContainer.of(context)
                                                      .curTheme
                                                      .primary30,
                                              child: Icon(AppIcons.scan,
                                                  size: 20,
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .primary),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0)),
                                              padding: EdgeInsets.all(14.0),
                                              onPressed: () {
                                                if (NanoSeeds.isValidSeed(
                                                    _seedInputController
                                                        .text)) {
                                                  return;
                                                }
                                                // Scan QR for seed
                                                BarcodeScanner.scan(StateContainer.of(context).curTheme.qrScanTheme).then((result) {
                                                  if (result != null && NanoSeeds.isValidSeed(result)) {
                                                    _seedInputController.text = result;
                                                    setState(() {
                                                      _seedIsValid = true;
                                                    });
                                                  } else {
                                                    UIUtil.showSnackbar(AppLocalization.of(context).qrInvalidSeed, context);
                                                  }
                                                });

                                              },
                                            ),
                                          ),
                                          secondChild: SizedBox(),
                                          crossFadeState: NanoSeeds.isValidSeed(
                                                  _seedInputController.text)
                                              ? CrossFadeState.showSecond
                                              : CrossFadeState.showFirst,
                                        ),
                                        // Paste Button
                                        suffixIcon: AnimatedCrossFade(
                                          duration: Duration(milliseconds: 100),
                                          firstChild: Container(
                                            width: 48,
                                            height: 48,
                                            child: FlatButton(
                                              highlightColor:
                                                  StateContainer.of(context)
                                                      .curTheme
                                                      .primary15,
                                              splashColor:
                                                  StateContainer.of(context)
                                                      .curTheme
                                                      .primary30,
                                              child: Icon(AppIcons.paste,
                                                  size: 20,
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .primary),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0)),
                                              padding: EdgeInsets.all(14.0),
                                              onPressed: () {
                                                if (NanoSeeds.isValidSeed(
                                                    _seedInputController
                                                        .text)) {
                                                  return;
                                                }
                                                Clipboard.getData("text/plain")
                                                    .then((ClipboardData data) {
                                                  if (data == null ||
                                                      data.text == null) {
                                                    return;
                                                  } else if (NanoSeeds
                                                      .isValidSeed(data.text)) {
                                                    _seedInputController.text =
                                                        data.text;
                                                    setState(() {
                                                      _seedIsValid = true;
                                                    });
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          secondChild: SizedBox(),
                                          crossFadeState: NanoSeeds.isValidSeed(
                                                  _seedInputController.text)
                                              ? CrossFadeState.showSecond
                                              : CrossFadeState.showFirst,
                                        ),
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          fontFamily: 'NunitoSans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w100,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text60,
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                      style: _seedIsValid ?AppStyles.textStyleSeed(context) : AppStyles.textStyleSeedGray(context),
                                      onChanged: (text) {
                                        // Always reset the error message to be less annoying
                                        setState(() {
                                          _showSeedError = false;
                                        });
                                        // If valid seed, clear focus/close keyboard
                                        if (NanoSeeds.isValidSeed(text)) {
                                          _seedInputFocusNode.unfocus();
                                          setState(() {
                                            _seedIsValid = true;
                                          });
                                        } else {
                                          setState(() {
                                            _seedIsValid = false;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                // "Invalid Seed" text that appears if the input is invalid
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text(
                                      AppLocalization.of(context).seedInvalid,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: _showSeedError ? StateContainer.of(context).curTheme.primary : Colors.transparent,
                                        fontFamily: 'NunitoSans',
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Next Screen Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 30),
                            height: 50,
                            width: 50,
                            child: FlatButton(
                                highlightColor: StateContainer.of(context)
                                    .curTheme
                                    .primary15,
                                splashColor: StateContainer.of(context)
                                    .curTheme
                                    .primary30,
                                onPressed: () {
                                  _seedInputFocusNode.unfocus();
                                  // If seed valid, log them in
                                  if (NanoSeeds.isValidSeed(
                                      _seedInputController.text)) {
                                    sl.get<SharedPrefsUtil>()
                                        .setSeedBackedUp(true)
                                        .then((result) {
                                      sl.get<Vault>()
                                          .setSeed(_seedInputController.text)
                                          .then((result) {
                                        NanoUtil().loginAccount(context).then((_) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return new PinScreen(
                                                PinOverlayType.NEW_PIN,
                                                (_pinEnteredCallback));
                                          }));
                                        });
                                      });
                                    });
                                  } else {
                                    // Display error
                                    setState(() {
                                      _showSeedError = true;
                                    });
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                padding: EdgeInsets.all(0.0),
                                child: Icon(AppIcons.forward,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary,
                                    size: 50)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
        ));
  }

  void _pinEnteredCallback(String pin) {
    Navigator.of(context).pop();
    sl.get<Vault>().writePin(pin).then((result) {
      // Update wallet
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    });
  }
}
