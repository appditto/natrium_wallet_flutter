import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kalium_wallet_flutter/model/db/contact.dart';

class DBHelper{

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
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(
    "CREATE TABLE Contacts(id INTEGER PRIMARY KEY, name TEXT, address TEXT, monkey_path TEXT)");
  }
  
  // Retrieving credentials
  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts ORDER BY name');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(name: list[i]["name"], address: list[i]["address"], monkeyPath: list[i]["monkey_path"]));
    }
    return contacts;
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
}