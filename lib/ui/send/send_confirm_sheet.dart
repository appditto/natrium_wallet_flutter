import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';
import 'package:natrium_wallet_flutter/model/db/payment.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_channels.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_response.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_spec.dart';
import 'package:natrium_wallet_flutter/network/account_service.dart';
import 'package:natrium_wallet_flutter/network/model/response/process_response.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:natrium_wallet_flutter/ui/util/routes.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';

class SendConfirmSheet extends StatefulWidget {
  final String amountRaw;
  final String destination;
  final String contactName;
  final String localCurrency;
  final bool maxSend;
  final MantaWallet manta;
  final PaymentRequestMessage paymentRequest;
  final HandoffPaymentSpec handoffPaymentSpec;
  final HandoffChannel handoffChannel;
  final int natriconNonce;

  SendConfirmSheet(
      {this.amountRaw,
      this.destination,
      this.contactName,
      this.localCurrency,
      this.manta,
      this.paymentRequest,
      this.handoffPaymentSpec,
      this.handoffChannel,
      this.natriconNonce,
      this.maxSend = false})
      : super();

  _SendConfirmSheetState createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  String amount;
  String destinationAltered;
  bool animationOpen;
  bool isMantaTransaction;
  bool isHandoff;

  StreamSubscription<AuthenticatedEvent> _authSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton()
        .registerTo<AuthenticatedEvent>()
        .listen((event) {
      if (event.authType == AUTH_EVENT_TYPE.SEND) {
        _doSend();
      }
    });
  }

  void _destroyBus() {
    if (_authSub != null) {
      _authSub.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    this.animationOpen = false;
    this.isMantaTransaction = widget.manta != null && widget.paymentRequest != null;
    this.isHandoff = widget.handoffPaymentSpec != null && widget.handoffChannel != null;
    // Derive amount from raw amount
    if (NumberUtil.getRawAsUsableString(widget.amountRaw).replaceAll(",", "") ==
        NumberUtil.getRawAsUsableDecimal(widget.amountRaw).toString()) {
      amount = NumberUtil.getRawAsUsableString(widget.amountRaw);
    } else {
      amount = NumberUtil.truncateDecimal(
                  NumberUtil.getRawAsUsableDecimal(widget.amountRaw),
                  digits: 6)
              .toStringAsFixed(6) +
          "~";
    }
    // Ensure nano_ prefix on destination
    destinationAltered = widget.destination.replaceAll("xrb_", "nano_");
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _showSendingAnimation(BuildContext context) {
    animationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.SEND,
        StateContainer.of(context).curTheme.animationOverlayStrong,
        StateContainer.of(context).curTheme.animationOverlayMedium,
        onPoppedCallback: () => animationOpen = false));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
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
            //The main widget that holds the text fields, "SENDING" and "TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // "SENDING" TEXT
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).sending, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Container for the amount text
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Amount text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: "$amount",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                          TextSpan(
                            text: " NANO",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                          TextSpan(
                            text: widget.localCurrency != null
                                ? " (${widget.localCurrency})"
                                : "",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // "TO" text
                  Container(
                    margin: EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).to, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Address text
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)
                            .curTheme
                            .backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: isMantaTransaction
                          ? Column(
                              children: <Widget>[
                                AutoSizeText(
                                  widget.paymentRequest.merchant.name,
                                  minFontSize: 12,
                                  stepGranularity: 0.1,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.headerPrimary(context),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                AutoSizeText(
                                  widget.paymentRequest.merchant.address,
                                  minFontSize: 10,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  stepGranularity: 0.1,
                                  style: AppStyles.addressText(context),
                                ),
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsetsDirectional.only(
                                            start: 10, end: 20),
                                        child: Icon(
                                          AppIcons.appia,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                smallScreen(context)
                                    ? UIUtil.oneLineAddressText(
                                        context, destinationAltered)
                                    : UIUtil.threeLineAddressText(
                                        context, destinationAltered)
                              ],
                            )
                          : UIUtil.threeLineAddressText(
                              context, destinationAltered,
                              contactName: widget.contactName)),
                  // "via handoff" text
                  if (isHandoff)
                    Container(
                      margin: EdgeInsets.only(top: 20.0, bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            CaseChange.toUpperCase(
                                AppLocalization.of(context).usingHandoff,
                                context),
                            style: AppStyles.textStyleParagraphThinPrimary(context),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            //A container for CONFIRM and CANCEL buttons
            Container(
              child: Column(
                children: <Widget>[
                  // A row for CONFIRM Button
                  Row(
                    children: <Widget>[
                      // CONFIRM Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).confirm, context),
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        // Authenticate
                        AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                        bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                        if (authMethod.method == AuthMethod.BIOMETRICS &&
                            hasBiometrics) {
                              try {
                                bool authenticated = await sl
                                                  .get<BiometricUtil>()
                                                  .authenticateWithBiometrics(
                                                      context,
                                                      AppLocalization.of(context)
                                                          .sendAmountConfirm
                                                          .replaceAll("%1", amount));
                                if (authenticated) {
                                  sl.get<HapticUtil>().fingerprintSucess();
                                  EventTaxiImpl.singleton()
                                            .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));   
                                }
                              } catch (e) {
                                await authenticateWithPin();
                              }
                            } else {
                              await authenticateWithPin();
                            }
                          }
                      )
                    ],
                  ),
                  // A row for CANCEL Button
                  Row(
                    children: <Widget>[
                      // CANCEL Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).cancel, context),
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Future<void> _doSend() async {
    _showSendingAnimation(context);
    try {
      if (isHandoff) {
        await _doSendHandoff();
      } else {
        await _doSendStandard();
      }
    } catch (e) {
      sl.get<Logger>().e("Error sending funds", e);
      _showError(AppLocalization.of(context).sendError);
    }
  }

  /// Send as standard nano transaction
  Future<void> _doSendStandard() async {
    ProcessResponse resp = await sl.get<AccountService>().requestSend(
      StateContainer.of(context).wallet.representative,
      StateContainer.of(context).wallet.frontier,
      widget.amountRaw,
      destinationAltered,
      StateContainer.of(context).wallet.address,
      NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index),
      max: widget.maxSend
    );
    if (isMantaTransaction) {
      widget.manta.sendPayment(
          transactionHash: resp.hash, cryptoCurrency: "NANO");
    }
    // Update state
    StateContainer.of(context).wallet.frontier = resp.hash;
    StateContainer.of(context).wallet.accountBalance += BigInt.parse(widget.amountRaw);
    // Save in database
    sl.get<DBHelper>().savePayment(PaymentTxn(
        resp.hash, null,
        isMantaTransaction ? PaymentProtocol.MANTA : PaymentProtocol.NONE));
    await _showSuccess();
  }

  /// Send using handoff
  Future<void> _doSendHandoff() async {
    // Construct block
    var block = await sl.get<AccountService>().constructSendBlock(
        StateContainer.of(context).wallet.representative,
        StateContainer.of(context).wallet.frontier,
        widget.amountRaw,
        destinationAltered,
        StateContainer.of(context).wallet.address,
        NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(),
            StateContainer.of(context).selectedAccount.index),
        max: widget.maxSend
    );

    // Process handoff
    sl.get<Logger>().i("Processing handoff of block ${block.hash} using "
        "channel ${widget.handoffChannel.type.name}...");
    var result = await widget.handoffChannel.handoffBlock(
        widget.handoffPaymentSpec.paymentId, block.toJson());
    sl.get<Logger>().i("Handoff processed, returned status: ${result.status}, "
        "message: ${result.message}");

    if (result.status.isSuccessful()) {
      // Update state
      StateContainer.of(context).wallet.frontier = block.hash;
      StateContainer.of(context).wallet.accountBalance = BigInt.parse(block.balance);
      // Save in database
      sl.get<DBHelper>().savePayment(PaymentTxn(
          block.hash, result.reference, PaymentProtocol.HANDOFF,
          protocolData:
              widget.handoffPaymentSpec.reusable
                  ? json.encode(widget.handoffPaymentSpec.toJson())
                  : null
      ));
      await _showSuccess(message: result.message);
    } else {
      //todo: if incorrect_state, force-refresh account state/frontier?
      _showError(result.formatMessage(AppLocalization.of(context)));
    }
  }

  Future<void> _showSuccess({String message}) async {
    // Show complete
    Contact contact = await sl.get<DBHelper>()
        .getContactWithAddress(widget.destination);
    String contactName = contact == null ? null : contact.name;
    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
    StateContainer.of(context).requestUpdate();
    if (widget.natriconNonce != null) {
      setState(() {
        StateContainer.of(context).updateNatriconNonce(
            StateContainer.of(context).selectedAccount.address,
            widget.natriconNonce);
      });
    }
    Sheets.showAppHeightNineSheet(
        context: context,
        closeOnTap: true,
        removeUntilHome: true,
        widget: SendCompleteSheet(
            amountRaw: widget.amountRaw,
            destination: destinationAltered,
            contactName: contactName,
            localAmount: widget.localCurrency,
            paymentRequest: widget.paymentRequest,
            natriconNonce: widget.natriconNonce,
            message: message
        )
    );
  }

  void _showError(String message) {
    if (animationOpen) {
      Navigator.of(context).pop();
    }
    UIUtil.showSnackbar(message, context);
    Navigator.of(context).pop();
  }


  Future<void> authenticateWithPin() async {
    // PIN Authentication
    String expectedPin = await sl.get<Vault>().getPin();
    bool auth = await Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
        return new PinScreen(
          PinOverlayType.ENTER_PIN,
          expectedPin: expectedPin,
          description: AppLocalization.of(context)
              .sendAmountConfirmPin
              .replaceAll("%1", amount),
        );
      }));
    if (auth != null && auth) {
      await Future.delayed(Duration(milliseconds: 200));
       EventTaxiImpl.singleton()
          .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));    
    }
  }
}
