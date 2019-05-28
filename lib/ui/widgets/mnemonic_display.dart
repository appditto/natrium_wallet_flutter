import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:natrium_wallet_flutter/util/clipboardutil.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/styles.dart';

/// A widget for displaying a mnemonic phrase
class MnemonicDisplay extends StatefulWidget {
  final List<String> wordList;

  MnemonicDisplay(this.wordList);

  _MnemonicDisplayState createState() => _MnemonicDisplayState();
}

class _MnemonicDisplayState extends State<MnemonicDisplay> {
  bool _seedCopied;
  Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seedCopied = false;
  }

  List<Widget> _buildMnemonicRows() {
    int nRows = 8;
    int itemsPerRow = 24 ~/ nRows;
    int curWord = 0;
    List<Widget> ret = [];
    for (int i = 0; i < nRows; i++) {
      ret.add(Container(
        width: (MediaQuery.of(context).size.width -
            (smallScreen(context) ? 0 : 60)),
        height: 1,
        color: StateContainer.of(context).curTheme.text05,
      ));
      // Build individual items
      List<Widget> items = [];
      for (int j = 0; j < itemsPerRow; j++) {
        items.add(
          Container(
            width: (MediaQuery.of(context).size.width -
                    (smallScreen(context) ? 15 : 60)) /
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
                  text: widget.wordList[curWord],
                  style: AppStyles.textStyleMnemonic(context),
                )
              ]),
            ),
          ),
        );
        curWord++;
      }
      ret.add(
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center, children: items)),
      );
      if (curWord == itemsPerRow * nRows) {
        ret.add(Container(
          width: (MediaQuery.of(context).size.width -
              (smallScreen(context) ? 0 : 60)),
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
      Container(
        // A gesture detector to decide if the is tapped or not
        child: new GestureDetector(
          onTap: () {
            Clipboard.setData(
                new ClipboardData(text: widget.wordList.join(' ')));
            ClipboardUtil.setClipboardClearEvent();
            setState(() {
              _seedCopied = true;
            });
            if (_seedCopiedTimer != null) {
              _seedCopiedTimer.cancel();
            }
            _seedCopiedTimer =
                new Timer(const Duration(milliseconds: 1200), () {
              setState(() {
                _seedCopied = false;
              });
            });
          },
          // The seed
          child: Container(
            margin: EdgeInsets.only(top: 15),
            child: Column(
              children: _buildMnemonicRows(),
            ),
          ),
        ),
      ),
      // "Seed copied to Clipboard" text that appaears when seed is tapped
      Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(AppLocalization.of(context).seedCopied,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: _seedCopied
                  ? StateContainer.of(context).curTheme.success
                  : Colors.transparent,
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.w600,
            )),
      ),
    ]);
  }
}
