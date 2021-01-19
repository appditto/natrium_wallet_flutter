import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:natrium_wallet_flutter/themes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/available_currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/util/formatters.dart';
import 'package:natrium_wallet_flutter/ui/receive/share_card.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';

class ReceiveSheet extends StatefulWidget {
  final AvailableCurrency localCurrency;
  final String address;
  final Widget qrWidget;

  ReceiveSheet(
      {@required this.localCurrency,
      this.address,
      this.qrWidget})
      : super();

  _ReceiveSheetStateState createState() => _ReceiveSheetStateState();
}

class _ReceiveSheetStateState extends State<ReceiveSheet> {
  GlobalKey shareCardKey;
  ByteData shareImageData;

  // Address copied items
  // Current state references
  bool _showShareCard;
  bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  FocusNode _receiveAmountFocusNode;
  TextEditingController _receiveAmountController;

  NumberFormat _localCurrencyFormat;
  bool _localCurrencyMode = false;
  String _amountHint = "";

  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";

  Widget qrWidget;

  Future<Uint8List> _capturePng() async {
    if (shareCardKey != null && shareCardKey.currentContext != null) {
      RenderRepaintBoundary boundary =
          shareCardKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData.buffer.asUint8List();
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial state of copy button
    _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    shareCardKey = GlobalKey();
    _showShareCard = false;

    // Set initial state of QR widget
    qrWidget = widget.qrWidget;

    // Set up amount input
    _receiveAmountFocusNode = FocusNode();
    _receiveAmountController = TextEditingController();

    // On amount focus change
    _receiveAmountFocusNode.addListener(() {
      if (_receiveAmountFocusNode.hasFocus) {
        setState(() {
          _amountHint = null;
        });
      } else {
        setState(() {
          _amountHint = "";
        });
      }
    });

    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(
        locale: widget.localCurrency.getLocale().toString(),
        symbol: widget.localCurrency.getCurrencySymbol());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),
                //Container for the address text and sheet handle
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text10,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      child: UIUtil.threeLineAddressText(
                          context, StateContainer.of(context).wallet.address,
                          type: ThreeLineAddressTextType.PRIMARY60),
                    ),
                  ],
                ),
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),
              ],
            ),

            // Column for Enter Amount container
            Column(
              children: <Widget>[
                getEnterAmountContainer(),
              ],
            ),

            // QR which takes all the available space left from the buttons & address text
            Expanded(
              child: Center(
                child: Stack(
                  children: <Widget>[
                    _showShareCard
                        ? Container(
                            child: AppShareCard(
                                shareCardKey,
                                SvgPicture.asset('assets/QR.svg'),
                                SvgPicture.asset('assets/sharecard_logo.svg')),
                            alignment: AlignmentDirectional(0.0, 0.0),
                          )
                        : SizedBox(),
                    // This is for hiding the share card
                    Center(
                      child: Container(
                        width: 260,
                        height: 150,
                        color:
                            StateContainer.of(context).curTheme.backgroundDark,
                      ),
                    ),
                    // Background/border part the QR
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.74,
                        child: SvgPicture.asset('assets/QR.svg'),
                      ),
                    ),
                    // Actual QR part of the QR
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.width / 2.65,
                        width: MediaQuery.of(context).size.width / 2.65,
                        child: this.qrWidget,
                      ),
                    ),
                    // Outer ring
                    Center(
                      child: Container(
                        width:
                            (StateContainer.of(context).curTheme is IndiumTheme)
                                ? MediaQuery.of(context).size.width / 1.68
                                : MediaQuery.of(context).size.width / 1.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              width: MediaQuery.of(context).size.width / 110),
                        ),
                      ),
                    ),
                    // Logo Background White
                    StateContainer.of(context).natriconOn
                        ? Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 6,
                              height: MediaQuery.of(context).size.width / 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  width: (StateContainer.of(context).curTheme
                                          is IndiumTheme)
                                      ? MediaQuery.of(context).size.width / 110
                                      : MediaQuery.of(context).size.width / 150,
                                  color: (StateContainer.of(context).curTheme
                                          is IndiumTheme)
                                      ? StateContainer.of(context)
                                          .curTheme
                                          .backgroundDark
                                      : StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: (StateContainer.of(context).curTheme
                                            is IndiumTheme)
                                        ? MediaQuery.of(context).size.width /
                                            150
                                        : MediaQuery.of(context).size.width /
                                            110,
                                    color: (StateContainer.of(context).curTheme
                                            is IndiumTheme)
                                        ? StateContainer.of(context)
                                            .curTheme
                                            .primary
                                        : StateContainer.of(context)
                                            .curTheme
                                            .backgroundDark,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 6.7,
                              height: MediaQuery.of(context).size.width / 6.7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    StateContainer.of(context).natriconOn
                        ? SizedBox()
                        : // Logo Background Primary
                        Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 8,
                              height: MediaQuery.of(context).size.width / 8,
                              decoration: BoxDecoration(
                                color:
                                    StateContainer.of(context).curTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                    // natricon
                    StateContainer.of(context).natriconOn
                        ? Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 6.25,
                              height: MediaQuery.of(context).size.width / 6.25,
                              margin: EdgeInsetsDirectional.only(
                                  top: MediaQuery.of(context).size.width / 110),
                              child: SvgPicture.network(
                                  UIUtil.getNatriconURL(StateContainer.of(context).selectedAccount.address, StateContainer.of(context).getNatriconNonce(StateContainer.of(context).selectedAccount.address)),
                                  key: Key(UIUtil.getNatriconURL(StateContainer.of(context).selectedAccount.address, StateContainer.of(context).getNatriconNonce(StateContainer.of(context).selectedAccount.address))),
                                  placeholderBuilder: (BuildContext context) =>
                                      Container(
                                        child: FlareActor(
                                          "assets/ntr_placeholder_animation.flr",
                                          animation: "main",
                                          fit: BoxFit.contain,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .primary,
                                        ),
                                      )),
                            ),
                          )
                        : Center(
                            child: Container(
                              height: MediaQuery.of(context).size.width / 30,
                              child: AutoSizeText(
                                "",
                                style: TextStyle(
                                    fontFamily: "AppIcons",
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .backgroundDark,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                minFontSize: 0.1,
                                stepGranularity: 0.1,
                                maxLines: 1,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),

            //A column with Copy Address and Share Address buttons
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        _addressCopied
                            ? AppButtonType.SUCCESS
                            : AppButtonType.PRIMARY,
                        _addressCopied
                            ? AppLocalization.of(context).addressCopied
                            : AppLocalization.of(context).copyAddress,
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                      Clipboard.setData(new ClipboardData(
                          text: StateContainer.of(context).wallet.address));
                      setState(() {
                        // Set copied style
                        _addressCopied = true;
                      });
                      if (_addressCopiedTimer != null) {
                        _addressCopiedTimer.cancel();
                      }
                      _addressCopiedTimer =
                          new Timer(const Duration(milliseconds: 800), () {
                        setState(() {
                          _addressCopied = false;
                        });
                      });
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        AppButtonType.PRIMARY_OUTLINE,
                        AppLocalization.of(context).addressShare,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        disabled: _showShareCard, onPressed: () {
                      String receiveCardFileName =
                          "share_${StateContainer.of(context).wallet.address}.png";
                      getApplicationDocumentsDirectory().then((directory) {
                        String filePath =
                            "${directory.path}/$receiveCardFileName";
                        File f = File(filePath);
                        setState(() {
                          _showShareCard = true;
                        });
                        Future.delayed(new Duration(milliseconds: 50), () {
                          if (_showShareCard) {
                            _capturePng().then((byteData) {
                              if (byteData != null) {
                                f.writeAsBytes(byteData).then((file) {
                                  UIUtil.cancelLockEvent();
                                  Share.shareFile(file,
                                      text: StateContainer.of(context)
                                          .wallet
                                          .address);
                                });
                              } else {
                                // TODO - show a something went wrong message
                              }
                              setState(() {
                                _showShareCard = false;
                              });
                            });
                          }
                        });
                      });
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  String _convertLocalCurrencyToCrypto() {
    String convertedAmt = _receiveAmountController.text.replaceAll(",", ".");
    convertedAmt = NumberUtil.sanitizeNumber(convertedAmt);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueLocal = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(
        StateContainer.of(context).wallet.localCurrencyConversion);
    return NumberUtil.truncateDecimal(valueLocal / conversion).toString();
  }

  String _convertCryptoToLocalCurrency() {
    String convertedAmt = NumberUtil.sanitizeNumber(_receiveAmountController.text,
        maxDecimalDigits: 2);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueCrypto = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(
        StateContainer.of(context).wallet.localCurrencyConversion);
    convertedAmt =
        NumberUtil.truncateDecimal(valueCrypto * conversion, digits: 2)
            .toString();
    convertedAmt =
        convertedAmt.replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
    convertedAmt = _localCurrencyFormat.currencySymbol + convertedAmt;
    return convertedAmt;
  }

  void toggleLocalCurrency() {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    if (_localCurrencyMode) {
      // Switching to crypto-mode
      String cryptoAmountStr;
      // Check out previous state
      if (_receiveAmountController.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _receiveAmountController.text;
        _lastCryptoAmount = _convertLocalCurrencyToCrypto();
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _receiveAmountController.text = cryptoAmountStr;
        _receiveAmountController.selection = TextSelection.fromPosition(
            TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_receiveAmountController.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
      } else {
        _lastCryptoAmount = _receiveAmountController.text;
        _lastLocalCurrencyAmount = _convertCryptoToLocalCurrency();
        localAmountStr = _lastLocalCurrencyAmount;
      }
      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _receiveAmountController.text = localAmountStr;
        _receiveAmountController.selection = TextSelection.fromPosition(
            TextPosition(offset: localAmountStr.length));
      });
    }
  }

  void redrawQr() {
    String raw;
    if (_localCurrencyMode) {
      _lastLocalCurrencyAmount = _receiveAmountController.text;
      _lastCryptoAmount = _convertLocalCurrencyToCrypto();
      raw = NumberUtil.getAmountAsRaw(_lastCryptoAmount);
    } else {
      raw = _receiveAmountController.text.length > 0 ? NumberUtil.getAmountAsRaw(_receiveAmountController.text) : '';
    }
    this.paintQrCode(address: widget.address, amount: raw);
  }

  void paintQrCode({String address, String amount}) {
    QrPainter painter = QrPainter(
      data: amount != '' ? 'nano:' + address + '?amount=' + amount : address,
      version: amount != '' ? 9 : 6,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    painter.toImageData(MediaQuery.of(context).size.width).then((byteData) {
      setState(() {
        this.qrWidget = Container(
              width: MediaQuery.of(context).size.width / 2.675,
              child: Image.memory(byteData.buffer.asUint8List())
        );
      });
    });
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  getEnterAmountContainer() {
    return AppTextField(
      focusNode: _receiveAmountFocusNode,
      controller: _receiveAmountController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'NunitoSans',
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(13),
        _localCurrencyMode
            ? CurrencyFormatter(
            decimalSeparator:
            _localCurrencyFormat.symbols.DECIMAL_SEP,
            commaSeparator: _localCurrencyFormat.symbols.GROUP_SEP,
            maxDecimalDigits: 2)
            : CurrencyFormatter(
            maxDecimalDigits: NumberUtil.maxDecimalDigits),
        LocalCurrencyFormatter(
            active: _localCurrencyMode,
            currencyFormat: _localCurrencyFormat)
      ],
      onChanged: (text) {
        this.redrawQr();
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText:
      _amountHint == null ? "" : AppLocalization.of(context).enterAmount + (_localCurrencyMode ?' (' + _localCurrencyFormat.currencySymbol +')' : ' (NANO)'),
      prefixButton: TextFieldButton(
        icon: AppIcons.swapcurrency,
        onPressed: () {
          toggleLocalCurrency();
        },
      ),
      fadeSuffixOnCondition: true,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
    );
  } //************ Enter Address Container Method End ************//
    //*************************************************************//
}
