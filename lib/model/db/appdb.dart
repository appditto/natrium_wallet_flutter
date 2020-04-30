import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';

class DBHelper {
  static const int DB_VERSION = 3;
  static const String CONTACTS_SQL = """CREATE TABLE Contacts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        address TEXT, 
        monkey_path TEXT)""";
  static const String ACCOUNTS_SQL = """CREATE TABLE Accounts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        acct_index INTEGER, 
        selected INTEGER, 
        last_accessed INTEGER,
        private_key TEXT,
        balance TEXT)""";
  static const String ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL = """
    ALTER TABLE Accounts ADD address TEXT
    """;
  static Database _db;

  NanoUtil _nanoUtil;

  DBHelper() {
    _nanoUtil = NanoUtil();
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "kalium.db");
    var theDb = await openDatabase(path,
        version: DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(CONTACTS_SQL);
    await db.execute(ACCOUNTS_SQL);
    await db.execute(ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      // Add accounts table
      await db.execute(ACCOUNTS_SQL);
      await db.execute(ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL);
    } else if (oldVersion == 2) {
      await db.execute(ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL);
    }
  }

  // Contacts
  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Contacts ORDER BY name');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(
          id: list[i]["id"],
          name: list[i]["name"],
          address: list[i]["address"].replaceAll("xrb_", "nano_"),
          monkeyPath: list[i]["monkey_path"]));
    }
    return contacts;
  }

  Future<List<Contact>> getContactsWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Contacts WHERE name LIKE \'%$pattern%\' ORDER BY LOWER(name)');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(
          id: list[i]["id"],
          name: list[i]["name"],
          address: list[i]["address"],
          monkeyPath: list[i]["monkey_path"]));
    }
    return contacts;
  }

  Future<Contact> getContactWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Contacts WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    if (list.length > 0) {
      return Contact(
          id: list[0]["id"],
          name: list[0]["name"],
          address: list[0]["address"],
          monkeyPath: list[0]["monkey_path"]);
    }
    return null;
  }

  Future<Contact> getContactWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Contacts WHERE name = ?', [name]);
    if (list.length > 0) {
      return Contact(
          id: list[0]["id"],
          name: list[0]["name"],
          address: list[0]["address"],
          monkeyPath: list[0]["monkey_path"]);
    }
    return null;
  }

  Future<bool> contactExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Contacts WHERE lower(name) = ?',
        [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> contactExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Contacts WHERE lower(address) like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\''));
    return count > 0;
  }

  Future<int> saveContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.rawInsert(
        'INSERT INTO Contacts (name, address) values(?, ?)',
        [contact.name, contact.address.replaceAll("xrb_", "nano_")]);
  }

  Future<int> saveContacts(List<Contact> contacts) async {
    int count = 0;
    for (Contact c in contacts) {
      if (await saveContact(c) > 0) {
        count++;
      }
    }
    return count;
  }

  Future<bool> deleteContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.rawDelete(
            "DELETE FROM Contacts WHERE lower(address) like \'%${contact.address.toLowerCase().replaceAll("xrb_", "").replaceAll("nano_", "")}\'") >
        0;
  }

  Future<bool> setMonkeyForContact(Contact contact, String monkeyPath) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
            "UPDATE contacts SET monkey_path = ? WHERE address = ?",
            [monkeyPath, contact.address]) >
        0;
  }

  // Accounts
  Future<List<Account>> getAccounts(String seed) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Accounts ORDER BY acct_index');
    List<Account> accounts = new List();
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]["id"],
          name: list[i]["name"],
          index: list[i]["acct_index"],
          lastAccess: list[i]["last_accessed"],
          selected: list[i]["selected"] == 1 ? true : false,
          balance: list[i]["balance"]));
    }
    accounts.forEach((a) {
      a.address = NanoUtil.seedToAddress(seed, a.index);
    });
    return accounts;
  }

  Future<List<Account>> getRecentlyUsedAccounts(String seed,
      {int limit = 2}) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Accounts WHERE selected != 1 ORDER BY last_accessed DESC, acct_index ASC LIMIT ?',
        [limit]);
    List<Account> accounts = new List();
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]["id"],
          name: list[i]["name"],
          index: list[i]["acct_index"],
          lastAccess: list[i]["last_accessed"],
          selected: list[i]["selected"] == 1 ? true : false,
          balance: list[i]["balance"]));
    }
    accounts.forEach((a) {
      a.address = NanoUtil.seedToAddress(seed, a.index);
    });
    return accounts;
  }

  Future<Account> addAccount(String seed, {String nameBuilder}) async {
    var dbClient = await db;
    Account account;
    await dbClient.transaction((Transaction txn) async {
      int nextIndex = 1;
      int curIndex;
      List<Map> accounts = await txn.rawQuery(
          'SELECT * from Accounts WHERE acct_index > 0 ORDER BY acct_index ASC');
      for (int i = 0; i < accounts.length; i++) {
        curIndex = accounts[i]["acct_index"];
        if (curIndex != nextIndex) {
          break;
        }
        nextIndex++;
      }
      int nextID = nextIndex + 1;
      String nextName = nameBuilder.replaceAll("%1", nextID.toString());
      account = Account(
          index: nextIndex,
          name: nextName,
          lastAccess: 0,
          selected: false,
          address: NanoUtil.seedToAddress(seed, nextIndex));
      await txn.rawInsert(
          'INSERT INTO Accounts (name, acct_index, last_accessed, selected, address) values(?, ?, ?, ?, ?)',
          [
            account.name,
            account.index,
            account.lastAccess,
            account.selected ? 1 : 0,
            account.address
          ]);
    });
    return account;
  }

  Future<int> deleteAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawDelete(
        'DELETE FROM Accounts WHERE acct_index = ?', [account.index]);
  }

  Future<int> saveAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawInsert(
        'INSERT INTO Accounts (name, acct_index, last_accessed, selected) values(?, ?, ?, ?)',
        [
          account.name,
          account.index,
          account.lastAccess,
          account.selected ? 1 : 0
        ]);
  }

  Future<int> changeAccountName(Account account, String name) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE Accounts SET name = ? WHERE acct_index = ?',
        [name, account.index]);
  }

  Future<void> changeAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.transaction((Transaction txn) async {
      await txn.rawUpdate('UPDATE Accounts set selected = 0');
      // Get access increment count
      List<Map> list = await txn
          .rawQuery('SELECT max(last_accessed) as last_access FROM Accounts');
      await txn.rawUpdate(
          'UPDATE Accounts set selected = ?, last_accessed = ? where acct_index = ?',
          [1, list[0]["last_access"] + 1, account.index]);
    });
  }

  Future<void> updateAccountBalance(Account account, String balance) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE Accounts set balance = ? where acct_index = ?',
        [balance, account.index]);
  }

  Future<Account> getSelectedAccount(String seed) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Accounts where selected = 1');
    if (list.length == 0) {
      return null;
    }
    String address =
        NanoUtil.seedToAddress(seed, list[0]["acct_index"]);
    Account account = Account(
        id: list[0]["id"],
        name: list[0]["name"],
        index: list[0]["acct_index"],
        selected: true,
        lastAccess: list[0]["last_accessed"],
        balance: list[0]["balance"],
        address: address);
    return account;
  }

  Future<Account> getMainAccount(String seed) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Accounts where acct_index = 0');
    if (list.length == 0) {
      return null;
    }
    String address =
        NanoUtil.seedToAddress(seed, list[0]["acct_index"]);
    Account account = Account(
        id: list[0]["id"],
        name: list[0]["name"],
        index: list[0]["acct_index"],
        selected: true,
        lastAccess: list[0]["last_accessed"],
        balance: list[0]["balance"],
        address: address);
    return account;
  }

  Future<void> dropAccounts() async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM ACCOUNTS');
  }
}
