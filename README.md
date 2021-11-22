<hr />
<div align="center">
    <img src="assets/biotalogo.png" alt="Logo" width='150px' height='auto'/>
</div>
<hr />

# Biota - Fast, Robust & Secure PAW Wallet

[![Twitter Follow](https://img.shields.io/twitter/follow/PAW_digital?style=social)](https://twitter.com/intent/follow?screen_name=PAW_digital)
[![Discord](https://img.shields.io/badge/discord-join%20chat-orange.svg?logo=discord&color=7289DA)](https://discord.gg/DjXn6bb3aE)


## What is Biota?

Biota is a cross-platform mobile wallet for the PAW digital currency. It is written in Dart using [Flutter](https://flutter.io).

| Link | Description |
| :----- | :------ |
[PAW.digital](https://paw.digital) | PAW digital currency Homepage

## Server

Biota's backend server can be found [here](https://github.com/paw-digital/paw-wallet-server)

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

Biota is released under the MIT License

### Update translations:

```
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localization.dart
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n \
   --no-use-deferred-loading lib/localization.dart lib/l10n/intl_*.arb
```

## Tools

Tools that can be used for appicons generation:
http://svg2vector.com/  for drawable android vector assets
http://easyappicon.com/ for app icons generation

For font assets:
https://fontforge.org/ Font conversion to SVG
https://mathew-kurian.github.io/CharacterMap/ Individual mapping of font entries
https://www.fluttericon.com/ Generation of fonts with SVGs

## Acknowledgements

Special thanks to the following!
- [Natrium](https://github.com/appditto/natrium_wallet_flutter) - The original one
- [Kalium](https://github.com/BananoCoin/kalium_wallet_flutter) - The second fork of Natrium
