import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/home_page.dart';

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
      backgroundColor: greyLight,
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
              children: <Widget>[
                //A widget that holds welcome animation + text and expands to the rest of the available area
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //Stuff inside this container except width won't be needed since it'll wrap the animation perfectly.
                        Container(
                          color: greyDark,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: Center(child: Text("ANIMATION")),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          child: Text(
                            "Welcome to Kalium. To begin you may create a new wallet or import an existing one.",
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'NunitoSans',
                                color: white90),
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
                        buildKaliumButton(KaliumButtonType.PRIMARY,
                            'New Wallet', Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                              Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(builder: (context) => new KaliumHomePage()));
                            }),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE,
                            'Import Wallet', Dimens.BUTTOM_BOTTOM_DIMENS, onPressed: () {
                              Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(builder: (context) => new KaliumHomePage()));
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
