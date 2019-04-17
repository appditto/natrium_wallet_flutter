import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:event_taxi/event_taxi.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/ui/util/routes.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/util/ninja/ninja_node.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/state_block.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';

import 'changerepresentativemanualentry_sheet.dart';

// TODO - add validations

class AppChangeRepresentativeSheet {
  FocusNode _repFocusNode;
  TextEditingController _repController;

  String _changeRepHint = "";
  TextStyle _repAddressStyle;
  bool _showPasteButton = true;
  bool _addressValidAndUnfocused = false;

  bool _animationOpen = false;

  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  AppChangeRepresentativeSheet() {
    _repFocusNode = new FocusNode();
    _repController = new TextEditingController();
  }

  StreamSubscription<RepChangedEvent> _repChangeSub;

  Future<bool> _onWillPop() async {
    if (_repChangeSub != null) {
      _repChangeSub.cancel();
    }
    return true;
  }

  _getRepresentativeWidgets(BuildContext context, List<NinjaNode> list) {
    if (list == null) return [];
    List<Widget> ret = [];
    list.forEach((node) {
      ret.add(_buildSingleRepresentative(
        node,
        context,
      ));
    });
    return ret;
  }

  _buildRepresenativeDialog(BuildContext context) {
    return AppSimpleDialog(
        title: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text(
            "Representatives",
            style: AppStyles.textStyleDialogHeader(context),
          ),
        ),
        children: _getRepresentativeWidgets(
            context, StateContainer.of(context).nanoNinjaNodes));
  }

  String _sanitizeAlias(String alias) {
    if (alias != null) {
      return alias.replaceAll(RegExp(r'[^a-zA-Z_.!?_;:-]'), '');
    }
    return '';
  }

  _buildSingleRepresentative(NinjaNode rep, BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Divider(
            height: 2,
            color: StateContainer.of(context).curTheme.text15,
          ),
          FlatButton(
            highlightColor: StateContainer.of(context).curTheme.text15,
            splashColor: StateContainer.of(context).curTheme.text15,
            onPressed: () {
              return null;
            },
            padding: EdgeInsets.all(0),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 24),
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _sanitizeAlias(rep.alias),
                          style: TextStyle(
                              color: StateContainer.of(context).curTheme.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.0,
                              fontFamily: 'Nunito Sans'),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 7),
                          child: RichText(
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: "Voting Weight: ",
                                  style: TextStyle(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .text,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito Sans',
                                  ),
                                ),
                                TextSpan(
                                  text: NumberUtil.getPercentOfTotalSupply(
                                      rep.votingWeight),
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                                TextSpan(
                                  text: "%",
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: "Uptime: ",
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text,
                                      fontWeight: FontWeight.w100,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                                TextSpan(
                                  text: (rep.uptime).toStringAsFixed(2),
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                                TextSpan(
                                  text: "%",
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 24),
                    child: Stack(
                      children: <Widget>[
                        Container(
                            child: Icon(
                              AppIcons.score,
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              size: 50,
                            )),
                        Container(
                          alignment: Alignment(-0.03, 0.03),
                          width: 50,
                          height: 50,
                          child: Text(
                            (rep.score).toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito Sans',
                            ),
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
    );
  }

  mainBottomSheet(BuildContext context) {
    _changeRepHint = AppLocalization.of(context).changeRepHint;
    _repAddressStyle = AppStyles.textStyleAddressText60(context);
    _repChangeSub =
        EventTaxiImpl.singleton().registerTo<RepChangedEvent>().listen((event) {
      if (event.previous != null) {
        StateContainer.of(context).wallet.representative =
            event.previous.representative;
        UIUtil.showSnackbar(
            AppLocalization.of(context).changeRepSucces, context);
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      }
    });

    AppSheets.showAppHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // On address focus change
            _repFocusNode.addListener(() {
              if (_repFocusNode.hasFocus) {
                setState(() {
                  _changeRepHint = "";
                  _addressValidAndUnfocused = false;
                });
                _repController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _repController.text.length));
              } else {
                setState(() {
                  _changeRepHint = AppLocalization.of(context).changeRepHint;
                  if (Address(_repController.text).isValid()) {
                    _addressValidAndUnfocused = true;
                  }
                });
              }
            });
            return WillPopScope(
                onWillPop: _onWillPop,
                child: SafeArea(
                    minimum: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.035,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          //A container for the header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 60, width: 60),
                              //Container for the header
                              Column(
                                children: <Widget>[
                                  // Sheet handle
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    height: 5,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text10,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
                                                140),
                                    child: AutoSizeText(
                                      CaseChange.toUpperCase(
                                          AppLocalization.of(context)
                                              .changeRepAuthenticate,
                                          context),
                                      style: AppStyles.textStyleHeader(context),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      stepGranularity: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 60, width: 60),
                            ],
                          ),

                          //A expanded section for current representative and new representative fields
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: smallScreen(context) ? 20 : 35,
                                  bottom: smallScreen(context) ? 20 : 35),
                              child: Stack(children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    // Clear focus of our fields when tapped in this empty space
                                    _repFocusNode.unfocus();
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: SizedBox.expand(),
                                    constraints: BoxConstraints.expand(),
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    // Currently represented by text
                                    Container(
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .currentlyRepresented,
                                          style: AppStyles.textStyleParagraph(
                                              context),
                                        )),
                                    // Current representative
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: StateContainer.of(context)
                                                .wallet
                                                .representative));
                                        setState(() {
                                          _addressCopied = true;
                                        });
                                        if (_addressCopiedTimer != null) {
                                          _addressCopiedTimer.cancel();
                                        }
                                        _addressCopiedTimer = new Timer(
                                            const Duration(milliseconds: 800),
                                            () {
                                          setState(() {
                                            _addressCopied = false;
                                          });
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105,
                                            top: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25.0, vertical: 15.0),
                                        decoration: BoxDecoration(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .backgroundDarkest,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: UIUtil.threeLineAddressText(
                                            context,
                                            StateContainer.of(context)
                                                .wallet
                                                .representative,
                                            type: _addressCopied
                                                ? ThreeLineAddressTextType
                                                    .SUCCESS_FULL
                                                : ThreeLineAddressTextType
                                                    .PRIMARY),
                                      ),
                                    ),
                                    // Address Copied text container
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 5, bottom: 5),
                                      child: Text(
                                          _addressCopied
                                              ? AppLocalization.of(context)
                                                  .addressCopied
                                              : "",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .success,
                                            fontFamily: 'NunitoSans',
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ),

                          //A row with change and close button
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  AppButton.buildAppButton(
                                    context,
                                    AppButtonType.PRIMARY,
                                    "Pick From a List",
                                    Dimens.BUTTON_TOP_DIMENS,
                                    disabled: StateContainer.of(context)
                                            .nanoNinjaNodes ==
                                        null,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _buildRepresenativeDialog(
                                                context);
                                          });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  AppButton.buildAppButton(
                                    context,
                                    AppButtonType.PRIMARY_OUTLINE,
                                    AppLocalization.of(context).manualEntry,
                                    Dimens.BUTTON_BOTTOM_DIMENS,
                                    onPressed: () {
                                      AppChangeRepresentativeManualEntrySheet()
                                          .mainBottomSheet(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    )));
          });
        });
  }
}
