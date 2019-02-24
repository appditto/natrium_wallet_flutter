import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';

class DBHelper{
  static const int DB_VERSION = 2;
  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "kalium.db");
    var theDb = await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(
    "CREATE TABLE Contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, monkey_path TEXT)");
    await db.execute(
    "CREATE TABLE Accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, acct_index INTEGER, selected INTEGER, last_accessed INTEGER)");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      // Add accounts table
      await db.execute(
      "CREATE TABLE Accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, acct_index INTEGER, selected INTEGER, last_accessed INTEGER)");
    }
  }

  // Contacts
  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts ORDER BY name');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(id: list[i]["id"], name: list[i]["name"], address: list[i]["address"], monkeyPath: list[i]["monkey_path"]));
    }
    return contacts;
  }

  Future<List<Contact>> getContactsWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts WHERE name LIKE \'%$pattern%\' ORDER BY LOWER(name)');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(id: list[i]["id"], name: list[i]["name"], address: list[i]["address"], monkeyPath: list[i]["monkey_path"]));
    }
    return contacts;
  }

  Future<Contact> getContactWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts WHERE address = ?', [address]);
    if (list.length > 0) {
      return Contact(id: list[0]["id"], name: list[0]["name"], address: list[0]["address"], monkeyPath: list[0]["monkey_path"]);
    }
    return null;
  }

  Future<Contact> getContactWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts WHERE name = ?', [name]);
    if (list.length > 0) {
      return Contact(id: list[0]["id"], name: list[0]["name"], address: list[0]["address"], monkeyPath: list[0]["monkey_path"]);
    }
    return null;
  }

  Future<bool> contactExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT count(*) FROM Contacts WHERE lower(name) = ?', [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> contactExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT count(*) FROM Contacts WHERE lower(address) = ?', [address.toLowerCase()]));
    return count > 0;
  }

  Future<int> saveContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.rawInsert('INSERT INTO Contacts (name, address) values(?, ?)', [contact.name, contact.address]);
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
    return await dbClient.rawDelete("DELETE FROM Contacts WHERE name = ? AND address = ?", [contact.name, contact.address]) > 0;
  }

  Future<bool> setMonkeyForContact(Contact contact, String monkeyPath) async {
    var dbClient = await db;
    return await dbClient.rawUpdate("UPDATE contacts SET monkey_path = ? WHERE address = ?", [monkeyPath, contact.address]) > 0;
  }

  // Accounts
  Future<List<Account>> getAccounts() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts ORDER BY last_accessed');
    List<Account> accounts = new List();
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(id: list[i]["id"], name: list[i]["name"], index: list[i]["acct_index"], lastAccess: list[i]["last_accessed"], selected: list[i]["selected"] == 1 ? true : false));
    }
    return accounts;
  }

  Future<int> getAccountsCount() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT count(*) as count FROM Accounts ORDER BY last_accessed');
    return list[0]["count"];
  }

  Future<int> getNextAccessCount() async {
    if (await getAccountsCount() == 0) {
      return 0;
    }
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT max(last_accessed) as last_access FROM Accounts');
    return list[0]["last_accessed"] + 1;
  }

  Future<void> saveAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawInsert('INSERT INTO Accounts (name, acct_index, last_accessed, selected) values(?, ?, ?, ?)', [account.name, account.index, account.lastAccess, account.selected ? 1 : 0]);
  }

  Future<void> updateLastAccess(Account account) async {
    var dbClient = await db;
    return await dbClient.rawUpdate('UPDATE Accounts set last_accessed = ? where id = ?', [await getNextAccessCount(), account.id]);
  }

  Future<void> changeAccount(Account account) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await dbClient.rawUpdate('UPDATE Account set selected = 0');
      await dbClient.rawUpdate('UPDATE Accounts set selected = ?, last_accessed = ? where id = ?', [1, await getNextAccessCount(), account.id]);
    });
  }

  Future<Account> getSelectedAccount() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts where selected = 1');
    if (list.length == 0) {
      return null;
    }
    Account account = Account(id: list[0]["id"], index: list[0]["acct_index"], selected: true, lastAccess: list[0]["last_accessed"]);
    return account;
  }

  Future<void> dropAccounts() async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM ACCOUNTS');
  }
}