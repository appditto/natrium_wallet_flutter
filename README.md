# Natrium - Fast, Robust & Secure NANO Wallet

[![GitHub release (latest)](https://img.shields.io/github/v/release/appditto/natrium_wallet_flutter)](https://github.com/appditto/natrium_wallet_flutter/releases) [![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/appditto/natrium_wallet_flutter/blob/master/LICENSE) [![Asset License](https://img.shields.io/badge/asset%20license-proprietary-orange)](https://github.com/appditto/natrium_wallet_flutter/blob/master/LICENSE) [![CI](https://github.com/appditto/natrium_wallet_flutter/workflows/CI/badge.svg)](https://github.com/appditto/natrium_wallet_flutter/actions?query=workflow%3ACI) [![Twitter Follow](https://img.shields.io/twitter/follow/NatriumIO?style=social)](https://twitter.com/intent/follow?screen_name=NatriumIO)


## What is Natrium?

Natrium is a cross-platform mobile wallet for the NANO cryptocurrency. It is written in Dart using [Flutter](https://flutter.io).

| Link | Description |
| :----- | :------ |
[natrium.io](https://natrium.io) | Natrium Homepage
[nano.org](https://nano.org) | NANO Cryptocurrency Homepage

![Natrium Themes](https://natrium.io/assets/natrium-themes.jpg)

![Natrium Quick Send](https://natrium.io/assets/natrium-qt-1.gif) ![Natrium Add to Contacts](https://natrium.io/assets/natrium-qt-2.gif) ![Natrium Change Representative](https://natrium.io/assets/natrium-qt-4.gif)

## Server

Natrium's backend server can be found [here](https://github.com/appditto/natrium-wallet-server)

## Contributing

* Fork the repository and clone it to your local machine
* Follow the instructions [here](https://flutter.io/docs/get-started/install) to install the Flutter SDK
* Setup [Android Studio](https://flutter.io/docs/development/tools/android-studio) or [Visual Studio Code](https://flutter.io/docs/development/tools/vs-code).

## Building

Android (armeabi-v7a): `flutter build apk`
Android (arm64-v8a): `flutter build apk --target=android-arm64`
iOS: `flutter build ios`

If you have a connected device or emulator you can run and deploy the app with `flutter run`

## Have a question?

If you need any help, feel free to file an issue if you do not manage to find a solution.

## License

Natrium is released under the MIT License

### Update translations:

```
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localization.dart
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n \
   --no-use-deferred-loading lib/localization.dart lib/l10n/intl_*.arb
```

