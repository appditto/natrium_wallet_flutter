import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/ui/util/formatters.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';

class IntroImportSeedPage extends StatefulWidget {
  @override
  _IntroImportSeedState createState() => _IntroImportSeedState();
}

class _IntroImportSeedState extends State<IntroImportSeedPage> {
  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  // Plaintext seed
  FocusNode _seedInputFocusNode = FocusNode();
  TextEditingController _seedInputController = TextEditingController();
  // Mnemonic Phrase
  FocusNode _mnemonicFocusNode = FocusNode();
  TextEditingController _mnemonicController = TextEditingController();

  bool _seedMode = false; // False if restoring phrase, true if restoring seed

  bool _seedIsValid = false;
  bool _showSeedError = false;
  bool _mnemonicIsValid = false;
  String _mnemonicError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            _mnemonicFocusNode.unfocus();
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Back Button
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                      start: smallScreen(context) ? 15 : 20),
                                  height: 50,
                                  width: 50,
                                  child: FlatButton(
                                      highlightColor: StateContainer.of(context)
                                          .curTheme
                                          .text15,
                                      splashColor: StateContainer.of(context)
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
                                // Switch between Secret Phrase and Seed
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                      end: smallScreen(context) ? 15 : 20),
                                  height: 50,
                                  width: 50,
                                  child: FlatButton(
                                      highlightColor: StateContainer.of(context)
                                          .curTheme
                                          .text15,
                                      splashColor: StateContainer.of(context)
                                          .curTheme
                                          .text15,
                                      onPressed: () {
                                        setState(() {
                                          _seedMode = !_seedMode;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(_seedMode ? Icons.vpn_key : AppIcons.seed,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text,
                                          size: 24)),
                                ),
                              ],
                            ),
                            // The header
                            Container(
                              margin: EdgeInsetsDirectional.only(
                                start: smallScreen(context) ? 30 : 40,
                                end: smallScreen(context) ? 30 : 40,
                                top: 10,
                              ),
                              alignment: AlignmentDirectional(-1, 0),
                              child: AutoSizeText(
                                _seedMode
                                    ? AppLocalization.of(context).importSeed
                                    : AppLocalization.of(context).importSecretPhrase,
                                style:
                                    AppStyles.textStyleHeaderColored(context),
                                maxLines: 1,
                                minFontSize: 12,
                                stepGranularity: 0.1,
                              ),
                            ),
                            // The paragraph
                            Container(
                              margin: EdgeInsets.only(
                                  left: smallScreen(context) ? 30 : 40, right: smallScreen(context) ? 30 : 40, top: 15.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _seedMode ?
                                AppLocalization.of(context).importSeedHint
                                : AppLocalization.of(context).importSecretPhraseHint,
                                style:
                                    AppStyles.textStyleParagraph(context),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            // The container for the seed
                            Container(
                              margin: EdgeInsets.only(
                                  left: smallScreen(context) ? 30 : 40, right: smallScreen(context) ? 30 : 40, top: 20),
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
                                child: _seedMode ? TextField(
                                  focusNode: _seedInputFocusNode,
                                  controller: _seedInputController,
                                  textAlign: TextAlign.center,
                                  cursorColor: StateContainer.of(context)
                                      .curTheme
                                      .primary,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(64),
                                    UpperCaseTextFormatter()
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
                                            UIUtil.cancelLockEvent();
                                            BarcodeScanner.scan(StateContainer.of(context).curTheme.qrScanTheme).then((result) {
                                              if (result != null && NanoSeeds.isValidSeed(result)) {
                                                _seedInputController.text = result;
                                                setState(() {
                                                  _seedIsValid = true;
                                                });
                                              } else if (result != null && NanoMnemomics.validateMnemonic(result.split(' '))) {
                                                _mnemonicController.text = result;
                                                _mnemonicFocusNode.unfocus();
                                                _seedInputFocusNode.unfocus();
                                                setState(() {
                                                  _seedMode = false;
                                                  _mnemonicError = null;
                                                  _mnemonicIsValid = true;
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
                                              } else if (NanoMnemomics.validateMnemonic(data.text.split(' '))) {
                                                _mnemonicController.text = data.text;
                                                _mnemonicFocusNode.unfocus();
                                                _seedInputFocusNode.unfocus();
                                                setState(() {
                                                  _seedMode = false;
                                                  _mnemonicError = null;
                                                  _mnemonicIsValid = true;
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
                                ) :
                                // MNEMONIC TextField
                                TextField(
                                  focusNode: _mnemonicFocusNode,
                                  controller: _mnemonicController,
                                  textAlign: TextAlign.center,
                                  cursorColor: StateContainer.of(context)
                                      .curTheme
                                      .primary,
                                  inputFormatters: [
                                    SingleSpaceInputFormatter(),
                                    LowerCaseTextFormatter(),
                                    WhitelistingTextInputFormatter(RegExp("[a-zA-Z ]")),
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
                                            if (NanoMnemomics.validateMnemonic(
                                                _mnemonicController.text.split(' '))) {
                                              return;
                                            }
                                            // Scan QR for mnemonic
                                            UIUtil.cancelLockEvent();
                                            BarcodeScanner.scan(StateContainer.of(context).curTheme.qrScanTheme).then((result) {
                                              if (result != null && NanoMnemomics.validateMnemonic(result.split(' '))) {
                                                _mnemonicController.text = result;
                                                setState(() {
                                                  _mnemonicIsValid = true;
                                                });
                                              } else if (result != null && NanoSeeds.isValidSeed(result)) {
                                                _seedInputController.text = result;
                                                _mnemonicFocusNode.unfocus();
                                                _seedInputFocusNode.unfocus();
                                                setState(() {
                                                  _seedMode = true;
                                                  _seedIsValid = true;
                                                  _showSeedError = false;
                                                });
                                              } else {
                                                UIUtil.showSnackbar(AppLocalization.of(context).qrMnemonicError, context);
                                              }
                                            });

                                          },
                                        ),
                                      ),
                                      secondChild: SizedBox(),
                                      crossFadeState: NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))
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
                                            if (NanoMnemomics.validateMnemonic(
                                                _mnemonicController.text.split(' '))) {
                                              return;
                                            }
                                            Clipboard.getData("text/plain")
                                                .then((ClipboardData data) {
                                              if (data == null ||
                                                  data.text == null) {
                                                return;
                                              } else if (NanoMnemomics.validateMnemonic(data.text.split(' '))) {
                                                _mnemonicController.text =
                                                    data.text;
                                                setState(() {
                                                  _mnemonicIsValid = true;
                                                });
                                              } else if (NanoSeeds.isValidSeed(data.text)) {
                                                _seedInputController.text = data.text;
                                                _mnemonicFocusNode.unfocus();
                                                _seedInputFocusNode.unfocus();
                                                setState(() {
                                                  _seedMode = true;
                                                  _seedIsValid = true;
                                                  _showSeedError = false;
                                                });
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      secondChild: SizedBox(),
                                      crossFadeState: NanoMnemomics.validateMnemonic(
                                              _mnemonicController.text.split(' '))
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
                                  style: _mnemonicIsValid ? AppStyles.textStyleParagraphPrimary(context) : AppStyles.textStyleParagraph(context),
                                  onChanged: (text) {
                                    if (text.length < 3) {
                                      setState(() {
                                        _mnemonicError = null;
                                      });
                                    } else if (_mnemonicError != null) {
                                      if (!text.contains(_mnemonicError.split(' ')[0])) {
                                        setState(() {
                                          _mnemonicError = null;
                                        });
                                      }
                                    }
                                    // If valid mnemonic, clear focus/close keyboard
                                    if (NanoMnemomics.validateMnemonic(text.split(' '))) {
                                      _mnemonicFocusNode.unfocus();
                                      setState(() {
                                        _mnemonicIsValid = true;
                                        _mnemonicError = null;
                                      });
                                    } else {
                                      setState(() {
                                        _mnemonicIsValid = false;
                                      });
                                      // Validate each mnemonic word
                                      if (text.endsWith(" ") && text.length > 1) {
                                        int lastSpaceIndex = text.substring(0, text.length - 1).lastIndexOf(" ");
                                        if (lastSpaceIndex == -1) {
                                          lastSpaceIndex = 0;
                                        } else {
                                          lastSpaceIndex++;
                                        }
                                        String lastWord = text.substring(lastSpaceIndex, text.length - 1);
                                        if (!NanoMnemomics.isValidWord(lastWord)) {
                                          setState(() {
                                            _mnemonicIsValid = false;
                                            setState(() {
                                              _mnemonicError = AppLocalization.of(context).mnemonicInvalidWord.replaceAll("%1", lastWord);
                                            });
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            // "Invalid Seed" text that appears if the input is invalid
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                  !_seedMode ? _mnemonicError == null ? "" : _mnemonicError
                                  : _showSeedError ? AppLocalization.of(context).seedInvalid : "",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: _seedMode ? _showSeedError ? StateContainer.of(context).curTheme.primary : Colors.transparent : _mnemonicError != null ? StateContainer.of(context).curTheme.primary : Colors.transparent,
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
                        margin: EdgeInsetsDirectional.only(end: 30),
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
                              if (_seedMode) {
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
                                      sl.get<DBHelper>().dropAccounts().then((_) {
                                        NanoUtil().loginAccount(context).then((_) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return PinScreen(
                                                PinOverlayType.NEW_PIN,
                                                (_pinEnteredCallback));
                                          }));
                                        });
                                      });
                                    });
                                  });
                                } else {
                                  // Display error
                                  setState(() {
                                    _showSeedError = true;
                                  });
                                }
                              } else {
                                // mnemonic mode
                                _mnemonicFocusNode.unfocus();
                                if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                                  sl.get<SharedPrefsUtil>()
                                      .setSeedBackedUp(true)
                                      .then((result) {
                                    sl.get<Vault>()
                                        .setSeed(NanoMnemomics.mnemonicListToSeed(_mnemonicController.text.split(' ')))
                                        .then((result) {
                                      sl.get<DBHelper>().dropAccounts().then((_) {
                                        NanoUtil().loginAccount(context).then((_) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return PinScreen(
                                                PinOverlayType.NEW_PIN,
                                                (_pinEnteredCallback));
                                          }));
                                        });
                                      });
                                    });
                                  });                                  
                                } else {
                                  // Show mnemonic error
                                  if (_mnemonicController.text.split(' ').length != 24) {
                                    setState(() {
                                      _mnemonicIsValid = false;
                                      _mnemonicError = AppLocalization.of(context).mnemonicSizeError;
                                    });
                                  } else {
                                    _mnemonicController.text.split(' ').forEach((word) {
                                      if (!NanoMnemomics.isValidWord(word)) {
                                        setState(() {
                                          _mnemonicIsValid = false;
                                          _mnemonicError = AppLocalization.of(context).mnemonicInvalidWord.replaceAll("%1", word);
                                        });
                                      }
                                    });
                                  }
                                }
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
    );
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
