import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/home_page.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_backup_seed.dart';
import 'package:flare_flutter/flare_actor.dart';

class IntroWelcomePage extends StatefulWidget {
  @override
  _IntroWelcomePageState createState() => _IntroWelcomePageState();
}

class _IntroWelcomePageState extends State<IntroWelcomePage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: KaliumColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
              children: <Widget>[
                //A widget that holds welcome animation + paragraph
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //Container for the animation
                        Container(
                          //Width/Height ratio for the animation is needed because BoxFit is not working as expected
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 5/8,
                          child: FlareActor("assets/welcome_animation.flr",
                              animation: "main",
                              fit: BoxFit.contain),
                        ),
                        //Container for the paragraph
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          child: Text(
                            "Welcome to Kalium. To begin you may create a new wallet or import an existing one.",
                            style: KaliumStyles.TextStyleParagraph,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with "New Wallet" and "Import Wallet" buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // New Wallet Button
                        KaliumButton.buildKaliumButton(
                            KaliumButtonType.PRIMARY,
                            'New Wallet',
                            Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                              Navigator.of(context).pushNamed('/intro_backup');
                        }),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        // Import Wallet Button
                        KaliumButton.buildKaliumButton(
                            KaliumButtonType.PRIMARY_OUTLINE,
                            'Import Wallet',
                            Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                          Navigator.of(context).pushNamed('/intro_import');
                        }),
                      ],
                    ), 
                  ],
                ),
              ],
            ),
      ),
    );
  }
}
