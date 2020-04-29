import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';

class SetPasswordSheet extends StatefulWidget {
  _SetPasswordSheetState createState() => _SetPasswordSheetState();
}

class _SetPasswordSheetState extends State<SetPasswordSheet> {
  FocusNode createPasswordFocusNode;
  TextEditingController createPasswordController;
  FocusNode confirmPasswordFocusNode;
  TextEditingController confirmPasswordController;

  String passwordError;

  bool passwordsMatch;

  @override
  void initState() {
    super.initState();
    this.passwordsMatch = false;
    this.createPasswordFocusNode = FocusNode();
    this.confirmPasswordFocusNode = FocusNode();
    this.createPasswordController = TextEditingController();
    this.confirmPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
        child: LayoutBuilder(
      builder: (context, constraints) => SafeArea(
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
            // The main widget that holds the header, text fields, and submit button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // The header
                  Container(
                    margin:
                        EdgeInsetsDirectional.only(top: 10, start: 60, end: 60),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          CaseChange.toUpperCase(
                              AppLocalization.of(context)
                                  .createPasswordSheetHeader,
                              context),
                          style: AppStyles.textStyleHeader(context),
                          minFontSize: 12,
                          stepGranularity: 0.1,
                          textAlign: TextAlign.center,
                          maxLines: 1,
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
                      AppLocalization.of(context)
                          .passwordWillBeRequiredToOpenParagraph,
                      style: AppStyles.textStyleParagraph(context),
                      maxLines: 5,
                      stepGranularity: 0.5,
                    ),
                  ),
                  Expanded(
                    child: KeyboardAvoider(
                      duration: Duration(milliseconds: 0),
                      autoScroll: true,
                      focusPadding: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Create a Password Text Field
                          AppTextField(
                            topMargin: 30,
                            padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                            focusNode: createPasswordFocusNode,
                            controller: createPasswordController,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            autocorrect: false,
                            onChanged: (String newText) {
                              if (passwordError != null) {
                                setState(() {
                                  passwordError = null;
                                });
                              }
                              if (confirmPasswordController.text == createPasswordController.text) {
                                if (mounted) {
                                  setState(() {
                                    passwordsMatch = true;
                                  });
                                }
                              } else {
                                if (mounted) {
                                  setState(() {
                                    passwordsMatch = false;
                                  });
                                }
                              }
                            },
                            hintText: AppLocalization.of(context).createPasswordHint,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color:
                                this.passwordsMatch ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.text,
                              fontFamily: 'NunitoSans',
                            ),
                            onSubmitted: (text) {
                              confirmPasswordFocusNode.requestFocus();
                            },
                          ),
                          // Confirm Password Text Field
                          AppTextField(
                            topMargin: 20,
                            padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                            focusNode: confirmPasswordFocusNode,
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            autocorrect: false,
                            onChanged: (String newText) {
                              if (passwordError != null) {
                                setState(() {
                                  passwordError = null;
                                });
                              }
                              if (confirmPasswordController.text == createPasswordController.text) {
                                if (mounted) {
                                  setState(() {
                                    passwordsMatch = true;
                                  });
                                }
                              } else {
                                if (mounted) {
                                  setState(() {
                                    passwordsMatch = false;
                                  });
                                }
                              }                              
                            },
                            hintText: AppLocalization.of(context).confirmPasswordHint,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color:
                                  this.passwordsMatch ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.text,
                              fontFamily: 'NunitoSans',
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
                        ]
                      )
                    )
                  )
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
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        await submitAndEncrypt();
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).close,
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> submitAndEncrypt() async {
    String seed = await sl.get<Vault>().getSeed();
    if (createPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = AppLocalization.of(context).passwordBlank;
        });
      }
    } else if (createPasswordController.text !=
        confirmPasswordController.text) {
      if (mounted) {
        setState(() {
          passwordError = AppLocalization.of(context).passwordsDontMatch;
        });
      }
    } else if (seed == null || !NanoSeeds.isValidSeed(seed)) {
      Navigator.pop(context);
      UIUtil.showSnackbar(
          AppLocalization.of(context).encryptionFailedError, context);
    } else {
      String encryptedSeed = NanoHelpers.byteToHex(
          NanoCrypt.encrypt(seed, confirmPasswordController.text));
      await sl.get<Vault>().setSeed(encryptedSeed);
      StateContainer.of(context).setEncryptedSecret(NanoHelpers.byteToHex(
          NanoCrypt.encrypt(seed, await sl.get<Vault>().getSessionKey())));
      UIUtil.showSnackbar(
          AppLocalization.of(context).setPasswordSuccess, context);
      Navigator.pop(context);
    }
  }
}
