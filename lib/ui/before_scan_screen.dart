import 'dart:async';

import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';

class BeforeScanScreen extends StatefulWidget {
  @override
  _BeforeScanScreenState createState() => _BeforeScanScreenState();
}

class _BeforeScanScreenState extends State<BeforeScanScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Hero(
        tag: 'scanButton',
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: StateContainer.of(context).curTheme.success,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Icon(
            AppIcons.scan,
            size: 50,
            color: StateContainer.of(context).curTheme.background,
          ),
        ),
      ),
    );
  }
}
