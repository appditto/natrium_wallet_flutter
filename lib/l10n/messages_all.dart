// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_ar.dart' as messages_ar;
import 'messages_bg.dart' as messages_bg;
import 'messages_de.dart' as messages_de;
import 'messages_en.dart' as messages_en;
import 'messages_es.dart' as messages_es;
import 'messages_fr.dart' as messages_fr;
import 'messages_he.dart' as messages_he;
import 'messages_hi.dart' as messages_hi;
import 'messages_hu.dart' as messages_hu;
import 'messages_id.dart' as messages_id;
import 'messages_it.dart' as messages_it;
import 'messages_ja.dart' as messages_ja;
import 'messages_ko.dart' as messages_ko;
import 'messages_lv.dart' as messages_lv;
import 'messages_messages.dart' as messages_messages;
import 'messages_ms.dart' as messages_ms;
import 'messages_nl.dart' as messages_nl;
import 'messages_pl.dart' as messages_pl;
import 'messages_pt.dart' as messages_pt;
import 'messages_ro.dart' as messages_ro;
import 'messages_ru.dart' as messages_ru;
import 'messages_sl.dart' as messages_sl;
import 'messages_sv.dart' as messages_sv;
import 'messages_tl.dart' as messages_tl;
import 'messages_tr.dart' as messages_tr;
import 'messages_vi.dart' as messages_vi;
import 'messages_zh-Hans.dart' as messages_zh_hans;
import 'messages_zh-Hant.dart' as messages_zh_hant;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'ar': () => new Future<dynamic>.value(null),
  'bg': () => new Future<dynamic>.value(null),
  'de': () => new Future<dynamic>.value(null),
  'en': () => new Future<dynamic>.value(null),
  'es': () => new Future<dynamic>.value(null),
  'fr': () => new Future<dynamic>.value(null),
  'he': () => new Future<dynamic>.value(null),
  'hi': () => new Future<dynamic>.value(null),
  'hu': () => new Future<dynamic>.value(null),
  'id': () => new Future<dynamic>.value(null),
  'it': () => new Future<dynamic>.value(null),
  'ja': () => new Future<dynamic>.value(null),
  'ko': () => new Future<dynamic>.value(null),
  'lv': () => new Future<dynamic>.value(null),
  'messages': () => new Future<dynamic>.value(null),
  'ms': () => new Future<dynamic>.value(null),
  'nl': () => new Future<dynamic>.value(null),
  'pl': () => new Future<dynamic>.value(null),
  'pt': () => new Future<dynamic>.value(null),
  'ro': () => new Future<dynamic>.value(null),
  'ru': () => new Future<dynamic>.value(null),
  'sl': () => new Future<dynamic>.value(null),
  'sv': () => new Future<dynamic>.value(null),
  'tl': () => new Future<dynamic>.value(null),
  'tr': () => new Future<dynamic>.value(null),
  'vi': () => new Future<dynamic>.value(null),
  'zh_Hans': () => new Future<dynamic>.value(null),
  'zh_Hant': () => new Future<dynamic>.value(null),
};

MessageLookupByLibrary _findExact(String localeName) {
  switch (localeName) {
    case 'ar':
      return messages_ar.messages;
    case 'bg':
      return messages_bg.messages;
    case 'de':
      return messages_de.messages;
    case 'en':
      return messages_en.messages;
    case 'es':
      return messages_es.messages;
    case 'fr':
      return messages_fr.messages;
    case 'he':
      return messages_he.messages;
    case 'hi':
      return messages_hi.messages;
    case 'hu':
      return messages_hu.messages;
    case 'id':
      return messages_id.messages;
    case 'it':
      return messages_it.messages;
    case 'ja':
      return messages_ja.messages;
    case 'ko':
      return messages_ko.messages;
    case 'lv':
      return messages_lv.messages;
    case 'messages':
      return messages_messages.messages;
    case 'ms':
      return messages_ms.messages;
    case 'nl':
      return messages_nl.messages;
    case 'pl':
      return messages_pl.messages;
    case 'pt':
      return messages_pt.messages;
    case 'ro':
      return messages_ro.messages;
    case 'ru':
      return messages_ru.messages;
    case 'sl':
      return messages_sl.messages;
    case 'sv':
      return messages_sv.messages;
    case 'tl':
      return messages_tl.messages;
    case 'tr':
      return messages_tr.messages;
    case 'vi':
      return messages_vi.messages;
    case 'zh_Hans':
      return messages_zh_hans.messages;
    case 'zh_Hant':
      return messages_zh_hant.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  var availableLocale = Intl.verifiedLocale(
    localeName,
    (locale) => _deferredLibraries[locale] != null,
    onFailure: (_) => null);
  if (availableLocale == null) {
    return new Future.value(false);
  }
  var lib = _deferredLibraries[availableLocale];
  await (lib == null ? new Future.value(false) : lib());
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary _findGeneratedMessagesFor(String locale) {
  var actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
