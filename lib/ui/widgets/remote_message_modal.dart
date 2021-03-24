import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/styles.dart';

class RemoteMessageModal extends StatefulWidget {
  final String title;
  final String paragraph;
  final String callToActionButtonText;
  final Function onCallToActionPressed;
  final Function onClosePressed;

  RemoteMessageModal({
    this.title,
    this.paragraph,
    this.callToActionButtonText,
    @required this.onCallToActionPressed,
    @required this.onClosePressed,
  });

  _RemoteMessageModalState createState() => _RemoteMessageModalState();
}

class _RemoteMessageModalState extends State<RemoteMessageModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2,
          color: StateContainer.of(context).curTheme.success,
        ),
        boxShadow: [
          BoxShadow(
            color: StateContainer.of(context).curTheme.success.withOpacity(0.3),
            blurRadius: 36,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 12, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.title != null
                          ? Container(
                              child: Text(
                                widget.title,
                                style:
                                    AppStyles.remoteMessageModalTitle(context),
                              ),
                            )
                          : SizedBox(),
                      widget.paragraph != null
                          ? Container(
                              margin: EdgeInsetsDirectional.only(
                                top: 4,
                              ),
                              child: Text(
                                widget.paragraph,
                                style: AppStyles.remoteMessageModalParagraph(
                                    context),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
              Container(
                child: ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: widget.onClosePressed,
                      splashColor: StateContainer.of(context).curTheme.text15,
                      highlightColor:
                          StateContainer.of(context).curTheme.text10,
                      icon: Icon(
                        AppIcons.close,
                        color: StateContainer.of(context).curTheme.text30,
                      ),
                      iconSize: 16,
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          widget.callToActionButtonText != null
              ? Container(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 18),
                  width: double.infinity,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(400)),
                    ),
                    color: StateContainer.of(context).curTheme.success,
                    splashColor: StateContainer.of(context)
                        .curTheme
                        .background
                        .withOpacity(0.3),
                    highlightColor: StateContainer.of(context)
                        .curTheme
                        .background
                        .withOpacity(0.3),
                    onPressed: widget.onCallToActionPressed,
                    minWidth: double.infinity,
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
                      child: Text(
                        widget.callToActionButtonText,
                        style: AppStyles.buttonTextBg(context),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 18,
                )
        ],
      ),
    );
  }
}
