import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/util/user_data_util.dart';

class TransferManualEntrySheet extends StatefulWidget {
  final Function validSeedCallback;

  TransferManualEntrySheet({this.validSeedCallback}) : super();

  _TransferManualEntrySheetState createState() => _TransferManualEntrySheetState();
}

class _TransferManualEntrySheetState extends State<TransferManualEntrySheet> {
  FocusNode _seedInputFocusNode;
  TextEditingController _seedInputController;

  // State constants
  bool seedIsValid;
  bool hasError;

  @override
  void initState() {
    super.initState();
    this._seedInputController = TextEditingController();
    this._seedInputFocusNode = FocusNode();
    this.seedIsValid = false;
    this.hasError = false;
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
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
            Container(
              margin: EdgeInsets.only(top: 30.0, left: 70, right: 70),
              child: AutoSizeText(
                CaseChange.toUpperCase(
                    AppLocalization.of(context).transferHeader,
                    context),
                style: AppStyles.textStyleHeader(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                stepGranularity: 0.1,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // The paragraph
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              smallScreen(context) ? 50 : 60,
                          vertical: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalization.of(context)
                            .transferManualHint,
                        style:
                            AppStyles.textStyleParagraph(context),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    // The container for the seed
                    Expanded(
                      child: KeyboardAvoider(
                        duration: Duration(milliseconds: 0),
                        autoScroll: true,
                        focusPadding: 40,
                        child: Column(
                          children: <Widget>[
                            AppTextField(
                              focusNode: _seedInputFocusNode,
                              controller: _seedInputController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(64),
                              ],
                              textInputAction: TextInputAction.done,
                              maxLines: null,
                              autocorrect: false,
                              suffixButton: TextFieldButton(
                                icon: AppIcons.paste,
                                onPressed: () async {
                                  String data = await UserDataUtil.getClipboardText(DataType.SEED);
                                  if (data != null) {
                                    if (mounted) {
                                      _seedInputController.text = data;
                                      setState(() {
                                        seedIsValid = true;
                                      });                                            
                                    }
                                  } else {
                                    if (mounted) {
                                      setState(() {
                                        seedIsValid = false;
                                      });
                                    }                               
                                  }
                                },
                              ),
                              fadeSuffixOnCondition: true,
                              suffixShowFirstCondition: !NanoSeeds.isValidSeed(_seedInputController.text),
                              keyboardType: TextInputType.text,
                              style: seedIsValid ? AppStyles.textStyleSeed(context) : AppStyles.textStyleSeedGray(context),
                              onChanged: (text) {
                                // Always reset the error message to be less annoying
                                setState(() {
                                  hasError = false;
                                });
                                // If valid seed, clear focus/close keyboard
                                if (NanoSeeds.isValidSeed(text) && mounted) {
                                  _seedInputFocusNode.unfocus();
                                  setState(() {
                                    seedIsValid = true;
                                  });
                                } else if (mounted) {
                                  setState(() {
                                    seedIsValid = false;
                                  });
                                }
                              },
                            ),
                            // "Invalid Seed" text that appears if the input is invalid
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                  AppLocalization.of(context).seedInvalid,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: hasError ? StateContainer.of(context).curTheme.primary : Colors.transparent,
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ]
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Row(
              children: <Widget>[
                AppButton.buildAppButton(
                  context,
                  AppButtonType.PRIMARY,
                  AppLocalization.of(context).transfer,
                  Dimens.BUTTON_TOP_DIMENS,
                  onPressed: () {
                    if (NanoSeeds.isValidSeed(_seedInputController.text) && widget.validSeedCallback != null) {
                      widget.validSeedCallback(_seedInputController.text);
                    } else if (mounted) {
                      setState(() {
                        hasError = true;
                      });
                    }
                  },
                ),
              ],
            ),

            Row(
              children: <Widget>[
                AppButton.buildAppButton(
                  context,
                  AppButtonType.PRIMARY_OUTLINE,
                  AppLocalization.of(context).cancel,
                  Dimens.BUTTON_BOTTOM_DIMENS,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
