import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';

class IntroBackupSeedPage extends StatefulWidget {
  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _seed;
  var _seedTapColor;
  var _seedCopiedColor;

  @override
  void initState() {
    super.initState();
    /* TODO - actually save the seed, for testing we don't care 
    Vault v = new Vault();
    v.writeSeed(NanoSeeds.generateSeed()).then((result) {
        setState(() {
            _seed = result;
        });
    });
    */
    setState(() {
      _seed = NanoSeeds.generateSeed();
      _seedTapColor = white60;
      _seedCopiedColor = Colors.transparent;
    });
  }

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
                        //Container for the text
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          child: Text(
                            "Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'NunitoSans',
                                color: white90),
                          ),
                        ),
                        Container(
                          child: new GestureDetector(
                            onTap: () {
                              Clipboard.setData(new ClipboardData(text: _seed));
                              setState(() {
                                _seedTapColor = blue;
                                _seedCopiedColor = blue;
                              });
                              // TODO - figure out how to cancel this task on subsequent clicks if it exists
                              Future.delayed(const Duration(milliseconds: 700), () {
                                setState(() {
                                  _seedTapColor = white60;
                                  _seedCopiedColor = Colors.transparent;
                                });
                              });
                            },
                            child: new Container(
                              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
                              margin: EdgeInsets.only(left: 60, right: 60, top: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: greyDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child:  Text(
                                _seed,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _seedTapColor,
                                  fontSize: 17.0,
                                  height: 1.2,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'OverpassMono',
                                ),
                              ),
                            )
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            'Seed Copied To Clipboard',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: _seedCopiedColor,
                              fontFamily: 'NunitoSansSemiBold'
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with next screen button
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
                            KaliumButtonType.PRIMARY,
                            'New Wallet',
                            Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                          Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => new IntroBackupSeedPage()));
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
