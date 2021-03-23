import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignIn> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035,
            top: MediaQuery.of(context).size.height * 0.20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              Container(
                margin: EdgeInsetsDirectional.only(
                    start: smallScreen(context) ? 30 : 40,
                    end: smallScreen(context) ? 30 : 40,
                    bottom:smallScreen(context) ? 50 : 10
                    ),
                child: Text(
                  'LOGIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 30
                  ),
                ),
              ),
              //A widget that holds welcome animation + paragraph
              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Container for the animation

                    Container(

                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 16.0),

                      child: TextField(
                        onChanged: (text) {
                          print("First text field: $text");
                        },

                        decoration: InputDecoration(
                          labelText: 'Enter your Email',
                          labelStyle: TextStyle(color: Colors.black54,fontSize: 18),

                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 10.0),

                      child: TextField(
                        onChanged: (text) {
                          print("First text field: $text");
                        },

                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlue,// set border color
                                width: 1.0),   // set border width
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)), // set rounded corner radius
                          ),

                          labelText: 'Enter your Password',
                          labelStyle: TextStyle(color: Colors.black54,fontSize: 18),
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            // New Wallet Button
                            AppButton.buildAppButton(
                                context,
                                AppButtonType.PRIMARY,
                                AppLocalization.of(context).signIn,
                                Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                              Navigator.of(context)
                                  .pushNamed('/home');
                            }),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            // New Wallet Button
                             Text(
                              "Vous n'avais pas encore de compte?",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            AppButton.buildAppButton(
                                context,
                                AppButtonType.PRIMARY_OUTLINE,
                                AppLocalization.of(context).signUp,
                                Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                              Navigator.of(context).pushNamed('/');
                            }),
                          ],
                        ),
                      ],
                    ),

                  ],

                ),
              ),

              //A column with "New Wallet" and "Import Wallet" buttons
            ],
          ),
        ),
      ),
    );
  }
}