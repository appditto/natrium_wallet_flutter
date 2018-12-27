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
        accentColor: yellow,
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
  KaliumBottomSheet receive = new KaliumBottomSheet();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return Scaffold(
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: new Drawer(
          child: buildSettingsSheet(),
        ),
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
              margin: new EdgeInsets.fromLTRB(30.0, 20.0, 26.0, 0.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "TRANSACTIONS",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w100,
                      color: white90,
                    ),
                  ),
                ],
              ),
            ), //Transactions Text End

            //Transactions List
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: ListView(
                      padding: EdgeInsets.only(top: 5.0, bottom: 15.0),
                      children: <Widget>[
                        buildReceivedCard('1520', 'ban_1rigge1...bbedwa', context),
                        buildReceivedCard('13020', 'ban_1yekta1...fuuyek', context),
                        buildSentCard('100', '@fudcake', context),
                        buildSentCard('1201', '@rene', context),
                        buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                        buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                        buildSentCard('1201', '@rene', context),
                        buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                        buildSentCard('1201', '@rene', context),
                        buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                        buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                        buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                        buildSentCard('1201', '@rene', context),
                        buildSentCard('1201', '@rene', context),
                      ],
                    ),
                  ),

                  //List Top Gradient End
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
                  ), //List Top Gradient End

                  //List Bottom Gradient
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 30.0,
                      width: double.infinity,
                      decoration: new BoxDecoration(
                        gradient: new LinearGradient(
                          colors: [greyLightZero, greyLight],
                          begin: new Alignment(0.5, -1),
                          end: new Alignment(0.5, 0.5),
                        ),
                      ),
                    ),
                  ), //List Bottom Gradient End
                ],
              ),
            ), //Transactions List End

            //Buttons Area
            Container(
              color: greyLight,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: new EdgeInsets.fromLTRB(14.0, 0.0, 7.0, 24.0),
                      child: new FlatButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(100.0)),
                        color: yellow,
                        child: new Text('Receive',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                color: greyLight)),
                        padding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 20),
                        onPressed: () => receive.mainBottomSheet(context),
                        highlightColor: greyLight40,
                        splashColor: greyLight40,
                      ),
                    ),
                  ),
                  buildKaliumButton("Send", 7.0, 0.0, 14.0, 24.0),
                ],
              ),
            ), //Buttons Area End
          ],
        ),
      ),
    );
  }
}
