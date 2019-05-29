import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';

import 'package:natrium_wallet_flutter/util/clipboardutil.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/styles.dart';

/// A widget for displaying a mnemonic phrase
class PlainSeedDisplay extends StatefulWidget {
  final String seed;
  final bool obscureSeed;

  PlainSeedDisplay({@required this.seed, this.obscureSeed});

  _PlainSeedDisplayState createState() => _PlainSeedDisplayState();
}

class _PlainSeedDisplayState extends State<PlainSeedDisplay> {
  static final String OBSCURED_SEED = '●' * 64;

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
              left:
                  smallScreen(context) ? 30 : 40,
              right:
                  smallScreen(context) ? 30 : 40,
              top: 15.0),
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            "A seed is just a different way your secret phrase can be represented. As long as you have one backed up, you'll always have access to your funds.",
            style: AppStyles.textStyleParagraph(
                context),
            maxLines: 5,
            stepGranularity: 0.5,
          ),
        ),
        // Container for the seed
        GestureDetector(
          onTap: () {
            if (widget.obscureSeed) {
              setState(() {
                _seedObscured = !_seedObscured;
              });
            }
          },
          child: 
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 25.0, vertical: 15),
              margin: EdgeInsets.only(top: 25),
              decoration: BoxDecoration(
                color: StateContainer.of(context)
                    .curTheme
                    .backgroundDarkest,
                borderRadius:
                    BorderRadius.circular(25),
              ),
              child: UIUtil.threeLineSeedText(
                  context,
                  widget.obscureSeed && _seedObscured ? OBSCURED_SEED : widget.seed,
                  textStyle: _seedCopied
                      ? AppStyles.textStyleSeedGreen(
                          context)
                      : AppStyles.textStyleSeed(
                          context)),
            )
        ),
        // Container for the copy button
        Container(
          margin:
              EdgeInsetsDirectional.only(top: 5),
          padding: EdgeInsets.all(0.0),
          child: OutlineButton(
            onPressed: () {
              Clipboard.setData(
                  new ClipboardData(text: widget.seed));
              ClipboardUtil
                  .setClipboardClearEvent();
              setState(() {
                _seedCopied = true;
              });
              if (_seedCopiedTimer != null) {
                _seedCopiedTimer.cancel();
              }
              _seedCopiedTimer = new Timer(
                  const Duration(
                      milliseconds: 1500), () {
                setState(() {
                  _seedCopied = false;
                });
              });
            },
            splashColor: _seedCopied
                ? Colors.transparent
                : StateContainer.of(context)
                    .curTheme
                    .primary30,
            highlightColor: _seedCopied
                ? Colors.transparent
                : StateContainer.of(context)
                    .curTheme
                    .primary15,
            highlightedBorderColor: _seedCopied
                ? StateContainer.of(context)
                    .curTheme
                    .success
                : StateContainer.of(context)
                    .curTheme
                    .primary,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(100.0)),
            borderSide: BorderSide(
                color: _seedCopied
                    ? StateContainer.of(context)
                        .curTheme
                        .success
                    : StateContainer.of(context)
                        .curTheme
                        .primary,
                width: 1.0),
            child: AutoSizeText(
              _seedCopied ? "Copied" : "Copy",
              textAlign: TextAlign.center,
              style: _seedCopied
                  ? AppStyles
                      .textStyleButtonSuccessSmallOutline(
                          context)
                  : AppStyles
                      .textStyleButtonPrimarySmallOutline(
                          context),
              maxLines: 1,
              stepGranularity: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
