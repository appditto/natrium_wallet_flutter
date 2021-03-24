import 'package:auto_size_text/auto_size_text.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';

class RemoteMessageSheet extends StatefulWidget {
  final String title;
  final String shortDescription;
  final String longDescription;
  final String link;
  final String timestamp;

  RemoteMessageSheet(
      {this.title,
      this.shortDescription,
      this.longDescription,
      this.link,
      this.timestamp})
      : super();

  _RemoteMessageSheetStateState createState() =>
      _RemoteMessageSheetStateState();
}

class _RemoteMessageSheetStateState extends State<RemoteMessageSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),
                //Container for the address text and sheet handle
                Column(
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
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          // Header
                          AutoSizeText(
                            CaseChange.toUpperCase(
                                AppLocalization.of(context).messageHeader,
                                context),
                            style: AppStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
                child: Stack(
                  children: [
                    // List Top Gradient End
                    SingleChildScrollView(
                      padding: EdgeInsetsDirectional.only(top: 12, bottom: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppStyles.remoteMessageCardTitle(context),
                          ),
                          Container(
                            margin: EdgeInsetsDirectional.only(top: 4),
                            child: Text(
                              widget.longDescription != null
                                  ? widget.longDescription
                                  : widget.shortDescription,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //List Top Gradient End
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 12.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark00,
                              StateContainer.of(context).curTheme.backgroundDark
                            ],
                            begin: AlignmentDirectional(0.5, 1.0),
                            end: AlignmentDirectional(0.5, -1.0),
                          ),
                        ),
                      ),
                    ),
                    //List Bottom Gradient
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 36.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark00,
                              StateContainer.of(context).curTheme.backgroundDark
                            ],
                            begin: AlignmentDirectional(0.5, -1),
                            end: AlignmentDirectional(0.5, 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //A column with Copy Address and Share Address buttons
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        AppLocalization.of(context).readMore,
                        Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () {}),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        AppButtonType.PRIMARY_OUTLINE,
                        AppLocalization.of(context).ignore,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {}),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
