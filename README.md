\# Kalium - BANANO Mobile Wallet

## What is Kalium?

Kalium is a cross-platform mobile wallet for the Banano cryptocurrency. It is written in Dart using [Flutter](https://flutter.io).

| Link | Description |
| :----- | :------ |
[banano.cc](https://banano.cc) | Banano Homepage
[chat.banano.cc](https://chat.banano.cc) | Banano Discord
[@bananocoin](https://twitter.com/bananocoin) | Follow Banano on Twitter to stay up to date
[banano.how](https://banano.how) | Getting started with Banano and more Information

## Contributing

* Fork the repository and clone it to your local machine
* Follow the instructions [here](https://flutter.io/docs/get-started/install) to install the Flutter SDK
* Setup [Android Studio](https://flutter.io/docs/development/tools/android-studio) or [Visual Studio Code](https://flutter.io/docs/development/tools/vs-code).

## Building

Android: `flutter build apk`
iOS: `flutter build ios`

If you have a connected device or emulator you can run and deploy the app with `flutter run`

## Have a question?

If you need any help, please visit our (GITHUB_LINK_TBD) or the [Banano discord](https://chat.banano.cc). Feel free to file an issue if you do not manage to find any solution.

## License

To be determined

### Update translations:

```
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localization.dart
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n \
   --no-use-deferred-loading lib/localization.dart lib/l10n/intl_*.arb
```

# TODO

Use `isStrongboxBacked` for android keystore
