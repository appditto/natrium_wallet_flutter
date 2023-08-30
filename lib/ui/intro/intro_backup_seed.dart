import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/plainseed_display.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/ui/widgets/mnemonic_display.dart';
import 'package:natrium_wallet_flutter/ui/widgets/flat_button.dart';

class IntroBackupSeedPage extends StatefulWidget {
  final String encryptedSeed;

  IntroBackupSeedPage({this.encryptedSeed}) : super();

  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  String _seed;
  List<String> _mnemonic;
  bool _showMnemonic;

  @override
  void initState() {
    super.initState();
    if (widget.encryptedSeed == null) {
      sl.get<Vault>().getSeed().then((seed) {
        setState(() {
          _seed = seed;
          _mnemonic = NanoMnemomics.seedToMnemonic(seed);
        });
      });
    } else {
      sl.get<Vault>().getSessionKey().then((key) {
        setState(() {
          _seed = NanoHelpers.byteToHex(
              NanoCrypt.decrypt(widget.encryptedSeed, key));
          _mnemonic = NanoMnemomics.seedToMnemonic(_seed);
        });
      });
    }
    _showMnemonic = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
          minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035,
              top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Back Button
                        Container(
                          margin: EdgeInsetsDirectional.only(
                              start: smallScreen(context) ? 15 : 20),
                          height: 50,
                          width: 50,
                          child: FlatButton(
                              highlightColor:
                                  StateContainer.of(context).curTheme.text15,
                              splashColor:
                                  StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Icon(AppIcons.back,
                                  color:
                                      StateContainer.of(context).curTheme.text,
                                  size: 24)),
                        ),
                        // Switch between Secret Phrase and Seed
                        Container(
                          margin: EdgeInsetsDirectional.only(
                              end: smallScreen(context) ? 15 : 20),
                          child: FlatButton(
                            highlightColor:
                                StateContainer.of(context).curTheme.text15,
                            splashColor:
                                StateContainer.of(context).curTheme.text15,
                            onPressed: () {
                              setState(() {
                                _showMnemonic = !_showMnemonic;
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsetsDirectional.only(
                                top: 6, bottom: 6, start: 12, end: 12),
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsetsDirectional.only(end: 8),
                                  child: Text(
                                    !_showMnemonic
                                        ? AppLocalization.of(context)
                                            .secretPhrase
                                        : AppLocalization.of(context).seed,
                                    style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                ),
                                Icon(
                                    !_showMnemonic
                                        ? Icons.vpn_key
                                        : AppIcons.seed,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .text,
                                    size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // The header
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40,
                        end: smallScreen(context) ? 30 : 40,
                        top: 10,
                      ),
                      alignment: AlignmentDirectional(-1, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width -
                                    (smallScreen(context) ? 120 : 140)),
                            child: AutoSizeText(
                              _showMnemonic
                                  ? AppLocalization.of(context).secretPhrase
                                  : AppLocalization.of(context).seed,
                              style: AppStyles.textStyleHeaderColored(context),
                              stepGranularity: 0.1,
                              minFontSize: 12.0,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsetsDirectional.only(start: 10, end: 10),
                            child: Icon(
                              _showMnemonic ? Icons.vpn_key : AppIcons.seed,
                              size: _showMnemonic ? 36 : 24,
                              color:
                                  StateContainer.of(context).curTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mnemonic word list
                    _seed != null && _mnemonic != null
                        ? _showMnemonic
                            ? MnemonicDisplay(wordList: _mnemonic)
                            : PlainSeedDisplay(seed: _seed)
                        : Text('')
                  ],
                ),
              ),
              // Next Screen Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY,
                    AppLocalization.of(context).backupConfirmButton,
                    Dimens.BUTTON_BOTTOM_DIMENS,
                    onPressed: () {
                      // Update wallet
                      sl.get<DBHelper>().dropAccounts().then((_) {
                        StateContainer.of(context).getSeed().then((seed) {
                          NanoUtil().loginAccount(seed, context).then((_) {
                            StateContainer.of(context).requestUpdate();
                            Navigator.of(context)
                                .pushNamed('/intro_backup_confirm');
                          });
                        });
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
