import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';

class AvatarPage extends StatefulWidget {
  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage>
    with SingleTickerProviderStateMixin {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController _controller;
  Animation<Color> bgColorAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bgColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: StateContainer.of(context).curTheme.overlay70,
    ).animate(_controller);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: bgColorAnimation.value,
          key: _scaffoldKey,
          body: LayoutBuilder(
            builder: (context, constraints) => SafeArea(
              minimum: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.035,
                top: MediaQuery.of(context).size.height * 0.10,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Gesture Detector
                        Container(
                          child: GestureDetector(onTapDown: (details) {
                            _controller.reverse();
                            Navigator.pop(context);
                          }),
                        ),
                        // Avatar
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8,
                          margin: EdgeInsetsDirectional.only(
                              bottom: MediaQuery.of(context).size.height * 0.1),
                          child: ClipOval(
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Hero(
                                  tag: "avatar",
                                  child: SvgPicture.network(
                                    'https://natricon.com/api/v1/nano?svc=natrium&outline=true&outlineColor=white&address=' +
                                        StateContainer.of(context)
                                            .selectedAccount
                                            .address,
                                    placeholderBuilder:
                                        (BuildContext context) => Container(
                                      child: FlareActor(
                                        "assets/ntr_placeholder_animation.flr",
                                        animation: "main",
                                        fit: BoxFit.contain,
                                        color: StateContainer.of(context)
                                            .curTheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                                /* // Button for the interaction
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2000.0)),
                                  highlightColor:
                                      StateContainer.of(context).curTheme.text15,
                                  splashColor:
                                      StateContainer.of(context).curTheme.text15,
                                  padding: EdgeInsets.all(0.0),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ) */
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
