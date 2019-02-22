import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';

import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/ui/home_page.dart';
import 'package:natrium_wallet_flutter/ui/lock_screen.dart';
import 'package:natrium_wallet_flutter/ui/intro/intro_welcome.dart';
import 'package:natrium_wallet_flutter/ui/intro/intro_backup_seed.dart';
import 'package:natrium_wallet_flutter/ui/intro/intro_backup_confirm.dart';
import 'package:natrium_wallet_flutter/ui/intro/intro_import_seed.dart';
import 'package:natrium_wallet_flutter/ui/util/routes.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/legacyutil.dart';

void main() async {
  // Setup logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  // Run app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new StateContainer(child: new App()));
  });
}

class App extends StatefulWidget {
  @override
  _AppState createState() => new _AppState();
}


class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(StateContainer.of(context).curTheme.statusBar);
    return OKToast(
      textStyle: AppStyles.textStyleSnackbar(context),
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Natrium',
        theme: ThemeData(
          dialogBackgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          primaryColor: StateContainer.of(context).curTheme.primary,
          accentColor: StateContainer.of(context).curTheme.primary10,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          fontFamily: 'NunitoSans',
          brightness: Brightness.dark,
        ),
        localizationsDelegates: [
          AppLocalizationsDelegate(StateContainer.of(context).curLanguage),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('he', 'IL'), // Hebrew
          const Locale('de', 'DE'), // German
          const Locale('es'), // Spanish
          const Locale('hi'), // Hindi
          const Locale('hu'), // Hungarian
          const Locale('hi'), // Hindi
          const Locale('id'), // Indonesian
          const Locale('it'), // Italian
          const Locale('ko'), // Korean
          const Locale('ms'), // Malay
          const Locale('nl'), // Dutch
          const Locale('pl'), // Polish
          const Locale('pt'), // Portugese
          const Locale('ro'), // Romanian
          const Locale('ru'), // Russian
          const Locale('sv'), // Swedish
          const Locale('tl'), // Tagalog
          const Locale('tr'), // Turkish
          const Locale('vi'), // Vietnamese
          const Locale('zh-Hans'), // Chinese Simplified
          const Locale('zh-Hant'), // Chinese Traditional
          // Currency-default requires country included
          const Locale("es", "AR"),
          const Locale("en", "AU"),
          const Locale("pt", "BR"),
          const Locale("en", "CA"),
          const Locale("de", "CH"),
          const Locale("es", "CL"),
          const Locale("zh", "CN"),
          const Locale("cs", "CZ"),
          const Locale("da", "DK"),
          const Locale("fr", "FR"),
          const Locale("en", "GB"),
          const Locale("zh", "HK"),
          const Locale("hu", "HU"),
          const Locale("id", "ID"),
          const Locale("he", "IL"),
          const Locale("hi", "IN"),
          const Locale("ja", "JP"),
          const Locale("ko", "KR"),
          const Locale("es", "MX"),
          const Locale("ta", "MY"),
          const Locale("nn", "NO"),
          const Locale("en", "NZ"),
          const Locale("tl", "PH"),
          const Locale("ur", "PK"),
          const Locale("pl", "PL"),
          const Locale("ru", "RU"),
          const Locale("sv", "SE"),
          const Locale("zh", "SG"),
          const Locale("th", "TH"),
          const Locale("tr", "TR"),
          const Locale("en", "TW"),
          const Locale("es", "VE"),
          const Locale("en", "ZA"),
          const Locale("en", "US"),
          const Locale("es", "AR"),
          const Locale("de", "AT"),
          const Locale("fr", "BE"),
          const Locale("de", "BE"),
          const Locale("nl", "BE"),
          const Locale("tr", "CY"),
          const Locale("et", "EE"),
          const Locale("fi", "FI"),
          const Locale("fr", "FR"),
          const Locale("el", "GR"),
          const Locale("es", "AR"),
          const Locale("en", "IE"),
          const Locale("it", "IT"),
          const Locale("es", "AR"),
          const Locale("lv", "LV"),
          const Locale("lt", "LT"),
          const Locale("fr", "LU"),
          const Locale("en", "MT"),
          const Locale("nl", "NL"),
          const Locale("pt", "PT"),
          const Locale("sk", "SK"),
          const Locale("sl", "SI"),
          const Locale("es", "ES"),
        ],
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return NoTransitionRoute(
                builder: (_) => Splash(),
                settings: settings,
              ); 
            case '/home':
              return NoTransitionRoute(
                builder: (_) => AppHomePage(),
                settings: settings,
              );
            case '/home_transition':
              return NoPopTransitionRoute(
                builder: (_) => AppHomePage(),
                settings: settings,
              );
            case '/intro_welcome':
              return NoTransitionRoute(
                builder: (_) => IntroWelcomePage(),
                settings: settings,
              );
            case '/intro_backup':
              return MaterialPageRoute(
                builder: (_) => IntroBackupSeedPage(),
                settings: settings,
              );
            case '/intro_backup_confirm':
              return MaterialPageRoute(
                builder: (_) => IntroBackupConfirm(),
                settings: settings,
              );
            case '/intro_import':
              return MaterialPageRoute(
                builder: (_) => IntroImportSeedPage(),
                settings: settings,
              );
            case '/lock_screen':
              return NoTransitionRoute(
                builder: (_) => AppLockScreen(),
                settings: settings,
              );            
            case '/lock_screen_transition':
              return MaterialPageRoute(
                builder: (_) => AppLockScreen(),
                settings: settings,
              );          
            default:
              return null;
          }
        },
      ),
    );
  }
}

/// Splash
/// Default page route that determines if user is logged in and routes them appropriately.
class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> with WidgetsBindingObserver {
 Future<bool> _doAndroidMigration() async {
    bool migrated = false;
    // Migrate seed
    String legacySeed = await LegacyMigration.getLegacySeed();
    if (legacySeed != null && NanoSeeds.isValidSeed(legacySeed)) {
      migrated = true;
      await Vault.inst.setSeed(legacySeed);
      await SharedPrefsUtil.inst.setSeedBackedUp(true);
    }
    if (migrated) {
      // Migrate PIN
      String legacyPin = await LegacyMigration.getLegacyPin();
      if (legacyPin != null && legacyPin.length == 4) {
        await Vault.inst.writePin(legacyPin);
      }
      // Migrate Contacts
      String legacyContacts = await LegacyMigration.getLegacyContacts();
      if (legacyContacts != null) {
        Iterable contactsJson = json.decode(legacyContacts);
        List<Contact> contacts = List();
        List<Contact> contactsToAdd = List();
        contactsJson.forEach((contact) {
          contacts.add(Contact.fromJson(contact));
        });
        DBHelper dbHelper = DBHelper();
        for (Contact contact in contacts) {
          if (!await dbHelper.contactExistsWithName(contact.name) &&
              !await dbHelper.contactExistsWithAddress(contact.address)) {
            // Contact doesnt exist, make sure name and address are valid
            if (Address(contact.address).isValid()) {
              if (contact.name.startsWith("@") && contact.name.length <= 20) {
                contactsToAdd.add(contact);
              }
            }
          }
        }
        await dbHelper.saveContacts(contactsToAdd);
      }
    }
    return migrated;
  }

  Future checkLoggedIn() async {
    // iOS key store is persistent, so if this is first launch then we will clear the keystore
    bool firstLaunch = await SharedPrefsUtil.inst.getFirstLaunch();
    if (firstLaunch) {
      bool migrated = false;
      if (Platform.isAndroid) {
        migrated = await _doAndroidMigration();
      }
      if (!migrated) {
        await Vault.inst.deleteAll();
      }
    }
    await SharedPrefsUtil.inst.setFirstLaunch();
    // See if logged in already
    bool isLoggedIn = false;
    var seed = await Vault.inst.getSeed();
    var pin = await Vault.inst.getPin();
    // If we have a seed set, but not a pin - or vice versa
    // Then delete the seed and pin from device and start over.
    // This would mean user did not complete the intro screen completely.
    if (seed != null && pin != null) {
      isLoggedIn = true;
    } else if (seed != null && pin == null) {
      await Vault.inst.deleteSeed();
    } else if (pin != null && seed == null) {
      await Vault.inst.deletePin();
    }

    if (isLoggedIn) {
      if (await SharedPrefsUtil.inst.getLock() || await SharedPrefsUtil.inst.shouldLock()) {
        Navigator.of(context).pushReplacementNamed('/lock_screen');
      } else {
        StateContainer.of(context).updateWallet(address: NanoUtil.seedToAddress(seed));
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/intro_welcome');
    }
  }


  @override
  void initState() {
    super.initState();
    checkLoggedIn();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Account for user changing locale when leaving the app
    switch (state) {
      case AppLifecycleState.paused:
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        setLanguage();
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  void setLanguage() {
    setState(() {
      StateContainer.of(context).deviceLocale = Localizations.localeOf(context);
    });
    SharedPrefsUtil.inst.getLanguage().then((setting) {
      setState(() {
        StateContainer.of(context).updateLanguage(setting);
      });
    });    
  }

  @override
  Widget build(BuildContext context) {
    // This seems to be the earliest place we can retrieve the device Locale
    setLanguage();
    SharedPrefsUtil.inst.getCurrency(StateContainer.of(context).deviceLocale).then((currency) {
      StateContainer.of(context).curCurrency = currency;
    });
    return new Scaffold(
      backgroundColor: StateContainer.of(context).curTheme.background,
    );
  }
}