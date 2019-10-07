import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nanodart/nanodart.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';

class DisablePasswordSheet extends StatefulWidget {
  _DisablePasswordSheetState createState() => _DisablePasswordSheetState();
}

class _DisablePasswordSheetState extends State<DisablePasswordSheet> {
  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  String passwordError;

  @override
  void initState() {
    super.initState();
    this.passwordFocusNode = FocusNode();
    this.passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
      child: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
          minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035),
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
              // The main widget that holds the header, text fields, and submit button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // The header
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            CaseChange.toUpperCase(
                                AppLocalization.of(context).disablePasswordSheetHeader, context),
                            style: AppStyles.textStyleHeader(context),
                          ),
                        ],
                      ),
                    ),
                    // The paragraph
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 16.0),
                      child: AutoSizeText(
                        AppLocalization.of(context).passwordNoLongerRequiredToOpenParagraph,
                        style: AppStyles.textStyleParagraph(context),
                        maxLines: 5,
                        stepGranularity: 0.5,
                      ),
                    ),
                    // Enter Password Text Field
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105,
                        top: 30,
                      ),
                      padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)
                            .curTheme
                            .backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            focusNode: passwordFocusNode,
                            controller: passwordController,
                            cursorColor:
                                StateContainer.of(context).curTheme.primary,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) async {
                              await submitAndDecrypt();
                            },
                            maxLines: 1,
                            autocorrect: false,
                            onChanged: (String newText) {
                              if (passwordError != null) {
                                setState(() {
                                  passwordError = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalization.of(context).enterPasswordHint,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w100,
                                fontFamily: 'NunitoSans',
                                color:
                                    StateContainer.of(context).curTheme.text60,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color: StateContainer.of(context).curTheme.text,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Error Text
                    Container(
                      alignment: AlignmentDirectional(0, 0),
                      margin: EdgeInsets.only(top: 3),
                      child: Text(this.passwordError == null ? "" : passwordError,
                          style: TextStyle(
                            fontSize: 14.0,
                            color:
                                StateContainer.of(context)
                                    .curTheme
                                    .primary,
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ),

              // Set Password Button
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY,
                            AppLocalization.of(context).setPassword,
                            Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                          await submitAndDecrypt();
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> submitAndDecrypt() async {
    String encryptedSeed = await sl.get<Vault>().getSeed();
    if (passwordController.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = AppLocalization.of(context).passwordBlank;
        });
      }
    } else {
      try {
        String decryptedSeed = NanoHelpers.byteToHex(NanoCrypt.decrypt(encryptedSeed, passwordController.text));
        throwIf(!NanoSeeds.isValidSeed(decryptedSeed), FormatException());
        await sl.get<Vault>().setSeed(decryptedSeed);
        StateContainer.of(context).resetEncryptedSecret();
        UIUtil.showSnackbar(AppLocalization.of(context).disablePasswordSuccess, context);
        Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          setState(() {
            passwordError = AppLocalization.of(context).invalidPassword;
          });
        }
      }
    }
  }
}