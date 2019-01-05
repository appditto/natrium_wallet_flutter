import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Widget buildPinScreenButton(String buttonText) {
  return Container(
    height: 70,
    width: 70,
    child: FlatButton(
      highlightColor: Color(0x26FBDD11),
      splashColor: Color(0x4DFBDD11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200.0)),
      color: Color(0xFF2A2A2E),
      child: Text(
        buttonText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20.0,
          color: Color(0xFFFBDD11),
        ),
      ),
      onPressed: () {
        return null;
      },
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Color(0xFF2A2A2E),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              child: Column(
                children: <Widget>[
                  Text(
                    "Header",
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 15),
                    child: Text(
                      "Bunch of numbers and words chilling together in a sunny day.",
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2, vertical: MediaQuery.of(context).size.height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Icon(
                          Icons.fiber_manual_record,
                          color: Color(0xFFFBDD11),
                        ),
                        Icon(
                          Icons.fiber_manual_record,
                          color: Color(0xFFFBDD11),
                        ),
                        Icon(
                          Icons.fiber_manual_record,
                          color: Color(0xFFFBDD11),
                        ),
                        Icon(
                          Icons.fiber_manual_record,
                          color: Color(0xFFFBDD11),
                        ),
                        Icon(
                          Icons.fiber_manual_record,
                          color: Color(0xFFFBDD11),
                        ),
                        Icon(
                          Icons.fiber_manual_record,
                          color: Color(0xFFFBDD11),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.07,
                    vertical: MediaQuery.of(context).size.height * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          buildPinScreenButton("1"),
                          buildPinScreenButton("2"),
                          buildPinScreenButton("3"),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          buildPinScreenButton("4"),
                          buildPinScreenButton("5"),
                          buildPinScreenButton("6"),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          buildPinScreenButton("7"),
                          buildPinScreenButton("8"),
                          buildPinScreenButton("9"),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            height: 70,
                            width: 70,
                          ),
                          buildPinScreenButton("0"),
                          Container(
                            height: 70,
                            width: 70,
                            child: FlatButton(
                              highlightColor: Color(0x26FBDD11),
                              splashColor: Color(0x4DFBDD11),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(200.0)),
                              color: Color(0xFF2A2A2E),
                              child: Icon(Icons.backspace,
                                  color: Color(0xFFFBDD11)),
                              onPressed: () {
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
