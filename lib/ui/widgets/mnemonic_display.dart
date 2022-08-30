import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/outline_button.dart';
import 'package:natrium_wallet_flutter/util/user_data_util.dart';

/// A widget for displaying a mnemonic phrase
class MnemonicDisplay extends StatefulWidget {
  final List<String> wordList;
  final bool obscureSeed;
  final bool showButton;

  MnemonicDisplay(
      {@required this.wordList,
      this.obscureSeed = false,
      this.showButton = true});

  _MnemonicDisplayState createState() => _MnemonicDisplayState();
}

class _MnemonicDisplayState extends State<MnemonicDisplay> {
  static final List<String> _obscuredSeed = List.filled(24, '•' * 6);
  bool _seedCopied;
  bool _seedObscured;
  Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seedCopied = false;
    _seedObscured = true;
  }

  List<Widget> _buildMnemonicRows() {
    int nRows = 8;
    int itemsPerRow = 24 ~/ nRows;
    int curWord = 0;
    List<Widget> ret = [];
    for (int i = 0; i < nRows; i++) {
      ret.add(Container(
        width: (MediaQuery.of(context).size.width),
        height: 1,
        color: StateContainer.of(context).curTheme.text05,
      ));
      // Build individual items
      List<Widget> items = [];
      for (int j = 0; j < itemsPerRow; j++) {
        items.add(
          Container(
            width: (MediaQuery.of(context).size.width -
                    (smallScreen(context) ? 15 : 30)) /
                itemsPerRow,
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: [
                TextSpan(
                  text: curWord < 9 ? " " : "",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: " ${curWord + 1}) ",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: _seedObscured && widget.obscureSeed
                      ? _obscuredSeed[curWord]
                      : widget.wordList[curWord],
                  style: _seedCopied
                      ? AppStyles.textStyleMnemonicSuccess(context)
                      : AppStyles.textStyleMnemonic(context),
                )
              ]),
            ),
          ),
        );
        curWord++;
      }
      ret.add(
        Padding(
            padding: EdgeInsets.symmetric(
                vertical: smallScreen(context) ? 6.0 : 9.0),
            child: Container(
              margin: EdgeInsetsDirectional.only(start: 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, children: items),
            )),
      );
      if (curWord == itemsPerRow * nRows) {
        ret.add(Container(
          width: (MediaQuery.of(context).size.width),
          height: 1,
          color: StateContainer.of(context).curTheme.text05,
        ));
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
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
              margin: EdgeInsets.only(top: 15),
              child: Column(
                children: _buildMnemonicRows(),
              ),
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
        ),
      ),
      widget.showButton
          ? Container(
              margin: EdgeInsetsDirectional.only(top: 5),
              padding: EdgeInsets.all(0.0),
              child: OutlineButton(
                onPressed: () {
                  UserDataUtil.setSecureClipboardItem(
                      widget.wordList.join(' '));
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
    ]);
  }
}
