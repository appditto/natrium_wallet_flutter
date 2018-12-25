import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'buttons.dart';
import 'cards.dart';
import 'sheets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaliumF',
      theme: ThemeData(
        primaryColor: yellow,
        accentColor: yellow60,
        fontFamily: 'NunitoSans',
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'KaliumF'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Modal modal = new Modal();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return Scaffold(
      drawer: new Drawer(
        child: buildSettingsSheet(),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: greyLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Main Card
            buildMainCard(),
            //Main Card End

            //Transactions Text
            Container(
              margin: new EdgeInsets.fromLTRB(26.0, 20.0, 26.0, 0.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "TRANSACTIONS",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w100,
                      color: white90,
                    ),
                  ),
                ],
              ),
            ), //Transactions Text End

            //List+Buttons
            Expanded(
              child: Stack(
                children: <Widget>[
                  //Transactions List
                  Container(
                    child: ListView(
                      padding: EdgeInsets.only(top: 5.0, bottom: 110.0),
                      children: <Widget>[
                        buildReceivedCard('1520', 'ban_1rigge1...bbedwa'),
                        buildReceivedCard('13020', 'ban_1yekta1...fuuyek'),
                        buildSentCard('100', '@fudcake'),
                        buildSentCard('1201', '@rene'),
                        buildReceivedCard('10', 'ban_1stfup1...smugge'),
                        buildReceivedCard('10', 'ban_1stfup1...smugge'),
                        buildSentCard('1201', '@rene'),
                        buildReceivedCard('10', 'ban_1stfup1...smugge'),
                        buildSentCard('1201', '@rene'),
                        buildReceivedCard('10', 'ban_1stfup1...smugge'),
                        buildReceivedCard('10', 'ban_1stfup1...smugge'),
                        buildReceivedCard('10', 'ban_1stfup1...smugge'),
                        buildSentCard('1201', '@rene'),
                        buildSentCard('1201', '@rene'),
                      ],
                    ),
                  ), //Transactions List End

                  //Thin Strip
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 10.0,
                      width: double.infinity,
                      decoration: new BoxDecoration(
                        gradient: new LinearGradient(
                          colors: [greyLight, greyLightZero],
                          begin: new Alignment(0.5, -1.0),
                          end: new Alignment(0.5, 1.0),
                        ),
                      ),
                    ),
                  ), //Thin Strip End

                  //Buttons Area
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: new BoxDecoration(
                        color: greyDark,
                        gradient: new LinearGradient(
                          colors: [greyLightZero, greyLight],
                          begin: new Alignment(0.5, -1.0),
                          end: new Alignment(0.5, -0.5),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: new EdgeInsets.fromLTRB(
                                  14.0, 40.0, 14.0, 22.0),
                              child: new FlatButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(100.0)),
                                color: yellow,
                                child: new Text('Receive',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w700,
                                        color: greyLight)),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 20),
                                onPressed: () => modal.mainBottomSheet(context),
                                highlightColor: greyLight40,
                                splashColor: greyLight40,
                              ),
                            ),
                          ),
                          buildKaliumButton("Send", 7.0, 40.0, 14.0, 22.0),
                        ],
                      ),
                    ),
                  ), //Buttons Area
                ],
              ),
            ), //List+Buttons End
          ],
        ),
      ),
    );
  }
}
