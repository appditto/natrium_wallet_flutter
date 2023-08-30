import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/flat_button.dart';

class RemoteMessageCard extends StatefulWidget {
  final AlertResponseItem alert;
  final Function onPressed;
  final bool showDesc;
  final bool showTimestamp;
  final bool hasBg;

  RemoteMessageCard({
    this.alert,
    this.onPressed,
    this.showDesc = true,
    this.showTimestamp = true,
    this.hasBg = true,
  });

  _RemoteMessageCardState createState() => _RemoteMessageCardState();
}

class _RemoteMessageCardState extends State<RemoteMessageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.hasBg
            ? StateContainer.of(context).curTheme.success.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2,
          color: StateContainer.of(context).curTheme.success,
        ),
      ),
      child: FlatButton(
        padding: EdgeInsets.all(0),
        highlightColor:
            StateContainer.of(context).curTheme.success.withOpacity(0.15),
        splashColor:
            StateContainer.of(context).curTheme.success.withOpacity(0.15),
        onPressed: widget.onPressed,
        child: Container(
          width: double.infinity,
          padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.alert.title != null
                  ? Container(
                      margin: EdgeInsetsDirectional.only(
                        bottom: widget.alert.shortDescription != null &&
                                (widget.showDesc || widget.alert.title == null)
                            ? 4
                            : 0,
                      ),
                      child: Text(
                        widget.alert.title,
                        style: AppStyles.remoteMessageCardTitle(context),
                      ),
                    )
                  : SizedBox(),
              widget.alert.shortDescription != null &&
                      (widget.showDesc || widget.alert.title == null)
                  ? Container(
                      margin: EdgeInsetsDirectional.only(
                        bottom: 4,
                      ),
                      child: Text(
                        widget.alert.shortDescription,
                        style: AppStyles.remoteMessageCardShortDescription(
                            context),
                      ),
                    )
                  : SizedBox(),
              widget.alert.timestamp != null && widget.showTimestamp
                  ? Container(
                      margin: EdgeInsetsDirectional.only(
                        top: 6,
                        bottom: 2,
                      ),
                      padding: EdgeInsetsDirectional.only(
                          start: 10, end: 10, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text05,
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                        border: Border.all(
                          color: StateContainer.of(context).curTheme.text10,
                        ),
                      ),
                      child: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                                    widget.alert.timestamp)
                                .toUtc()
                                .toString()
                                .substring(0, 16) +
                            " UTC",
                        style: AppStyles.remoteMessageCardTimestamp(context),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
