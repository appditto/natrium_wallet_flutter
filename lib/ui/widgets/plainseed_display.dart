import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/outline_button.dart';
import 'package:natrium_wallet_flutter/util/user_data_util.dart';

/// A widget for displaying a mnemonic phrase
class PlainSeedDisplay extends StatefulWidget {
  final String seed;
  final bool obscureSeed;
  final bool showButton;

  PlainSeedDisplay(
      {@required this.seed, this.obscureSeed = false, this.showButton = true});

  _PlainSeedDisplayState createState() => _PlainSeedDisplayState();
}

class _PlainSeedDisplayState extends State<PlainSeedDisplay> {
  static final String _obscuredSeed = '•' * 64;

  bool _seedCopied;
  bool _seedObscured;
  Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seedCopied = false;
    _seedObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // The paragraph
        Container(
          margin: EdgeInsets.only(
              left: smallScreen(context) ? 30 : 40,
              right: smallScreen(context) ? 30 : 40,
              top: 15.0),
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            AppLocalization.of(context).seedDescription,
            style: AppStyles.textStyleParagraph(context),
            maxLines: 5,
            stepGranularity: 0.5,
          ),
        ),
        // Container for the seed
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (widget.obscureSeed) {
                setState(() {
                  _seedObscured = !_seedObscured;
                });
              }
            },
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    color:
                        StateContainer.of(context).curTheme.backgroundDarkest,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: UIUtil.threeLineSeedText(
                      context,
                      widget.obscureSeed && _seedObscured
                          ? _obscuredSeed
                          : widget.seed,
                      textStyle: _seedCopied
                          ? AppStyles.textStyleSeedGreen(context)
                          : AppStyles.textStyleSeed(context)),
                ),
                // Tap to reveal or hide
                widget.obscureSeed
                    ? Container(
                        margin: EdgeInsetsDirectional.only(top: 8),
                        child: _seedObscured
                            ? AutoSizeText(
                                AppLocalization.of(context).tapToReveal,
                                style: AppStyles.textStyleParagraphThinPrimary(
                                    context),
                              )
                            : Text(
                                AppLocalization.of(context).tapToHide,
                                style: AppStyles.textStyleParagraphThinPrimary(
                                    context),
                              ),
                      )
                    : SizedBox(),
              ],
            )),
        // Container for the copy button
        widget.showButton
            ? Container(
                margin: EdgeInsetsDirectional.only(top: 5),
                padding: EdgeInsets.all(0.0),
                child: OutlineButton(
                  onPressed: () {
                    UserDataUtil.setSecureClipboardItem(widget.seed);
                    setState(() {
                      _seedCopied = true;
                    });
                    if (_seedCopiedTimer != null) {
                      _seedCopiedTimer.cancel();
                    }
                    _seedCopiedTimer =
                        new Timer(const Duration(milliseconds: 1500), () {
                      setState(() {
                        _seedCopied = false;
                      });
                    });
                  },
                  splashColor: _seedCopied
                      ? Colors.transparent
                      : StateContainer.of(context).curTheme.primary30,
                  highlightColor: _seedCopied
                      ? Colors.transparent
                      : StateContainer.of(context).curTheme.primary15,
                  highlightedBorderColor: _seedCopied
                      ? StateContainer.of(context).curTheme.success
                      : StateContainer.of(context).curTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0)),
                  borderSide: BorderSide(
                      color: _seedCopied
                          ? StateContainer.of(context).curTheme.success
                          : StateContainer.of(context).curTheme.primary,
                      width: 1.0),
                  child: AutoSizeText(
                    _seedCopied
                        ? AppLocalization.of(context).copied
                        : AppLocalization.of(context).copy,
                    textAlign: TextAlign.center,
                    style: _seedCopied
                        ? AppStyles.textStyleButtonSuccessSmallOutline(context)
                        : AppStyles.textStyleButtonPrimarySmallOutline(context),
                    maxLines: 1,
                    stepGranularity: 0.5,
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
