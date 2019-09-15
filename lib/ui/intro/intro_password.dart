import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';

class IntroPassword extends StatefulWidget {
  final bool comingFromImport;
  IntroPassword({this.comingFromImport = false});
  @override
  _IntroPasswordState createState() => _IntroPasswordState();
}

class _IntroPasswordState extends State<IntroPassword> {
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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
          minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035,
              top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              //A widget that holds the header, the paragraph and Back Button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Back Button
                        Container(
                          margin: EdgeInsetsDirectional.only(
                              start: smallScreen(context) ? 15 : 20),
                          height: 50,
                          width: 50,
                          child: FlatButton(
                              highlightColor:
                                  StateContainer.of(context).curTheme.text15,
                              splashColor:
                                  StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Icon(AppIcons.back,
                                  color:
                                      StateContainer.of(context).curTheme.text,
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
                        AppLocalization.of(context).createAPasswordHeader,
                        maxLines: 3,
                        stepGranularity: 0.5,
                        style: AppStyles.textStyleHeaderColored(context),
                      ),
                    ),
                    // The paragraph
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 16.0),
                      child: AutoSizeText(
                        AppLocalization.of(context).passwordWillBeRequiredToOpenParagraph,
                        style: AppStyles.textStyleParagraph(context),
                        maxLines: 5,
                        stepGranularity: 0.5,
                      ),
                    ),
                    // Create a Password Text Field
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
                            focusNode: createPasswordFocusNode,
                            controller: createPasswordController,
                            cursorColor:
                                StateContainer.of(context).curTheme.primary,
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
                            decoration: InputDecoration(
                              hintText: AppLocalization.of(context).createPasswordHint,
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
                              color:
                                this.passwordsMatch ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.text,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Confirm Password Text Field
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105,
                        top: 20,
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
                            focusNode: confirmPasswordFocusNode,
                            controller: confirmPasswordController,
                            cursorColor:
                                StateContainer.of(context).curTheme.primary,
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
                            decoration: InputDecoration(
                              hintText: AppLocalization.of(context).confirmPasswordHint,
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
                              color:
                                  this.passwordsMatch ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.text,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //A column with "Next" and "Go Back" buttons
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Next Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY,
                          AppLocalization.of(context).nextButton, Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        widget.comingFromImport
                            ? Navigator.of(context)
                                .pushNamed('/intro_import')
                            : Navigator.of(context)
                                .pushNamed('/intro_backup_safety');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Go Back Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).goBackButton,
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
