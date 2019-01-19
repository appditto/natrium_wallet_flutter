import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

enum PinOverlayType { NEW_PIN, ENTER_PIN }

class PinScreen extends StatefulWidget {
  final PinOverlayType type;
  final String expectedPin;
  final String description;
  final Function pinSuccessCallback;

  PinScreen(this.type, this.pinSuccessCallback, {this.description = "", this.expectedPin = ""});

  @override
  _PinScreenState createState() => _PinScreenState(type, expectedPin, description, pinSuccessCallback);
}

class _PinScreenState extends State<PinScreen> {
  _PinScreenState(this.type, this.expectedPin, this.description, this.successCallback) {
    if (this.type == PinOverlayType.ENTER_PIN) {
      assert(this.expectedPin == null || this.expectedPin.length != 6,
            "In ENTER_PIN mode, but expectedPin is not a string of length 6");
    }
  }

  PinOverlayType type;
  String expectedPin;
  Function successCallback;
  String description;

  // Constants
  String _enterPin;
  String _confirmPin;
  String _noMatch;
  String _enterPinExisting;
  String _invalidPin;

  // Stateful data
  List<IconData> _dotStates;
  String _pin;
  String _pinConfirmed;
  bool _awaitingConfirmation; // true if pin has been entered once, false if not entered once
  String _header;

  @override
  void initState() {
    super.initState();
    // Initialize list all empty
    _dotStates = List.filled(6, KaliumIcons.dotemtpy);
    _awaitingConfirmation = false;
    _pin = "";
    _pinConfirmed = "";
  }

  /// Set next character in the pin set
  /// return true if all characters entered
  bool _setCharacter(String character) {
    if (_awaitingConfirmation) {
      setState(() {
        _pinConfirmed = _pinConfirmed + character;
      });
    } else {
      setState(() {
        _pin = _pin + character;
      });
    }
    for (int i = 0; i < _dotStates.length; i++) {
      if (_dotStates[i] == KaliumIcons.dotemtpy) {
        setState(() {
          _dotStates[i] = KaliumIcons.dotfilled;
        });
        break;
      }
    }
    if (_dotStates.last == KaliumIcons.dotfilled) {
      return true;
    }
    return false;
  }

  void _backSpace() {
    if (_dotStates[0] != KaliumIcons.dotemtpy) {
      int lastFilledIndex;
      for (int i = 0; i < _dotStates.length; i++) {
        if (_dotStates[i] == KaliumIcons.dotfilled) {
          if (i == _dotStates.length || _dotStates[i+1] == KaliumIcons.dotemtpy) {
            lastFilledIndex = i;
            break;
          }
        }
      }
      setState(() {
        _dotStates[lastFilledIndex] = KaliumIcons.dotemtpy;
        if (_awaitingConfirmation) {
          _pinConfirmed = _pinConfirmed.substring(0, _pinConfirmed.length - 1);
        } else {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      });
    }
  }

  Widget _buildPinScreenButton(String buttonText) {
    return Container(
      height: 80,
      width: 80,
      child: FlatButton(
        highlightColor: KaliumColors.primary15,
        splashColor: KaliumColors.primary30,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200.0)),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            color: KaliumColors.primary,
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () {
          if (_setCharacter(buttonText)) {
            if (type == PinOverlayType.ENTER_PIN) {
              // Pin is not what was expected
              if (_pin != expectedPin) {
                setState(() {
                  _pin = "";
                  _header = _invalidPin;
                  _dotStates = List.filled(6, KaliumIcons.dotemtpy);
                });
              } else {
                successCallback(_pin);
              }
            } else {
              if (!_awaitingConfirmation) {
                // Switch to confirm pin
                setState(() {
                  _awaitingConfirmation = true;
                  _dotStates = List.filled(6, KaliumIcons.dotemtpy);
                  _header = _confirmPin;
                });
              } else {
                // First and second pins match
                if (_pin == _pinConfirmed) {
                  successCallback(_pin);
                } else {
                  // Start over
                  setState(() {
                    _awaitingConfirmation = false;
                    _dotStates = List.filled(6, KaliumIcons.dotemtpy);
                    _pin = "";
                    _pinConfirmed = "";
                    _header = _noMatch;
                  });
                }
              }
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set strings
    _enterPin = KaliumLocalization.of(context).pinCreateTitle;
    _confirmPin =  KaliumLocalization.of(context).pinConfirmTitle;
    _noMatch = KaliumLocalization.of(context).pinConfirmError;
    _enterPinExisting = KaliumLocalization.of(context).pinEnterTitle;
    _invalidPin =  KaliumLocalization.of(context).pinInvalid;

    if (type == PinOverlayType.ENTER_PIN) {
      _header = _enterPinExisting;
    } else {
      _header = _enterPin;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));

    return Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(),
          color: KaliumColors.backgroundDark,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _header,
                        style: KaliumStyles.TextStylePinScreenHeaderColored,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Wrap(
                        children: <Widget>[
                          Text(
                          description,
                          style: KaliumStyles.TextStyleParagraph,
                          textAlign: TextAlign.center,
                        ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.25,
                          vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            _dotStates[0],
                            color: KaliumColors.primary,
                            size: 20.0,
                          ),
                          Icon(
                            _dotStates[1],
                            color: KaliumColors.primary,
                            size: 20.0,
                          ),
                          Icon(
                            _dotStates[2],
                            color: KaliumColors.primary,
                            size: 20.0,
                          ),
                          Icon(
                            _dotStates[3],
                            color: KaliumColors.primary,
                            size: 20.0,
                          ),
                          Icon(
                            _dotStates[4],
                            color: KaliumColors.primary,
                            size: 20.0,
                          ),
                          Icon(
                            _dotStates[5],
                            color: KaliumColors.primary,
                            size: 20.0,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.07,
                      vertical: MediaQuery.of(context).size.height * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _buildPinScreenButton("1"),
                            _buildPinScreenButton("2"),
                            _buildPinScreenButton("3"),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _buildPinScreenButton("4"),
                            _buildPinScreenButton("5"),
                            _buildPinScreenButton("6"),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _buildPinScreenButton("7"),
                            _buildPinScreenButton("8"),
                            _buildPinScreenButton("9"),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.009),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              height: 80,
                              width: 80,
                            ),
                            _buildPinScreenButton("0"),
                            Container(
                              height: 80,
                              width: 80,
                              child: FlatButton(
                                highlightColor: KaliumColors.primary15,
                                splashColor: KaliumColors.primary30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200.0)),
                                child: Icon(Icons.backspace,
                                    color: KaliumColors.primary, size:20.0),
                                onPressed: () {
                                  _backSpace();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}