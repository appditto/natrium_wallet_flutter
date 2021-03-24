import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:natrium_wallet_flutter/styles.dart';

class RemoteMessageCard extends StatefulWidget {
  final AlertResponseItem alert;
  final Function onPressed;
  final bool showDesc;

  RemoteMessageCard({
    this.alert,
    this.onPressed,
    this.showDesc = true,
  });

  _RemoteMessageCardState createState() => _RemoteMessageCardState();
}

class _RemoteMessageCardState extends State<RemoteMessageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.success.withOpacity(0.1),
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
              widget.alert.timestamp != null
                  ? Container(
                      margin: EdgeInsetsDirectional.only(
                        bottom: 4,
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
              widget.alert.title != null
                  ? Container(
                      margin: EdgeInsetsDirectional.only(
                        bottom: 4,
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
            ],
          ),
        ),
      ),
    );
  }
}
