import 'dart:math';
import 'dart:io';

import 'package:vibrate/vibrate.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

enum PinOverlayType { NEW_PIN, ENTER_PIN }

class ShakeCurve extends Curve {
  @override
  double transform(double t) {
    //t from 0.0 to 1.0
    return sin(t * 3 * pi);
  }
}

class PinScreen extends StatefulWidget {
  final PinOverlayType type;
  final String expectedPin;
  final String description;
  final Function pinSuccessCallback;

  PinScreen(this.type, this.pinSuccessCallback,
      {this.description = "", this.expectedPin = ""});

  @override
  _PinScreenState createState() =>
      _PinScreenState(type, expectedPin, description, pinSuccessCallback);
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  _PinScreenState(
      this.type, this.expectedPin, this.description, this.successCallback);

  PinOverlayType type;
  String expectedPin;
  Function successCallback;
  String description;

  String pinEnterTitle = "";
  String pinCreateTitle = "";

  // Stateful data
  List<IconData> _dotStates;
  String _pin;
  String _pinConfirmed;
  bool
      _awaitingConfirmation; // true if pin has been entered once, false if not entered once
  String _header;

  // Invalid animation
  AnimationController _controller;
  Animation<double> _animation;

  Future<void> _errorHaptic() async {
    if (Platform.isIOS) {
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.error);
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize list all empty
    _dotStates = List.filled(6, KaliumIcons.dotemtpy);
    _awaitingConfirmation = false;
    _pin = "";
    _pinConfirmed = "";
    if (type == PinOverlayType.ENTER_PIN) {
      _header = pinEnterTitle;
    } else {
      _header = pinCreateTitle;
    }
    // Set animation
    _controller = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: _controller, curve: ShakeCurve());
    _animation = Tween(begin: 0.0, end: 15.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (type == PinOverlayType.ENTER_PIN) {
            setState(() {
              _pin = "";
              _header = KaliumLocalization.of(context).pinInvalid;
              _dotStates = List.filled(6, KaliumIcons.dotemtpy);
              _controller.value = 0;
            });
          } else {
            setState(() {
              _awaitingConfirmation = false;
              _dotStates = List.filled(6, KaliumIcons.dotemtpy);
              _pin = "";
              _pinConfirmed = "";
              _header = KaliumLocalization.of(context).pinConfirmError;
              _controller.value = 0;
            });
          }
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          if (i == _dotStates.length ||
              _dotStates[i + 1] == KaliumIcons.dotemtpy) {
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(200.0)),
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
          if (_controller.status == AnimationStatus.forward ||
              _controller.status == AnimationStatus.reverse) {
            return;
          }
          if (_setCharacter(buttonText)) {
            // Mild delay so they can actually see the last dot get filled
            Future.delayed(Duration(milliseconds: 50), () {
              if (type == PinOverlayType.ENTER_PIN) {
                // Pin is not what was expected
                if (_pin != expectedPin) {
                  _errorHaptic();
                  _controller.forward();
                } else {
                  successCallback(_pin);
                }
              } else {
                if (!_awaitingConfirmation) {
                  // Switch to confirm pin
                  setState(() {
                    _awaitingConfirmation = true;
                    _dotStates = List.filled(6, KaliumIcons.dotemtpy);
                    _header = KaliumLocalization.of(context).pinConfirmTitle;
                  });
                } else {
                  // First and second pins match
                  if (_pin == _pinConfirmed) {
                    successCallback(_pin);
                  } else {
                    _errorHaptic();
                    _controller.forward();
                  }
                }
              }
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pinEnterTitle.isEmpty) {
      setState(() {
        pinEnterTitle = KaliumLocalization.of(context).pinEnterTitle;
        if (type == PinOverlayType.ENTER_PIN) {
          _header = pinEnterTitle;
        }
      });
    }
    if (pinCreateTitle.isEmpty) {
      setState(() {
        pinCreateTitle = KaliumLocalization.of(context).pinCreateTitle;
        if (type == PinOverlayType.NEW_PIN) {
          _header = pinCreateTitle;
        }
      });
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent));

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
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _header,
                      style: KaliumStyles.TextStylePinScreenHeaderColored,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.25 + _animation.value,
                      right: MediaQuery.of(context).size.width * 0.25 - _animation.value,
                      top: MediaQuery.of(context).size.height * 0.02,
                      bottom: MediaQuery.of(context).size.height * 0.02,
                    ),
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
                  ),
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
                                  color: KaliumColors.primary, size: 20.0),
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
