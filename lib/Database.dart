import 'package:expiration_date_list/ItemModel.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  //getterらしい
  Future<Database> get database async {


    if (_database != null) {
      return _database;
    }

    // DBがなかったら作る
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // import 'package:path/path.dart'; が必要
    String path = join(documentsDirectory.path, "ItemDB.db");

    return await openDatabase(path, version: 5, onCreate: _createTable, onUpgrade: _onUpgrade);
  }

  //更新するときは33行目のversionにある番号を変えてから
//  void _onUpgrade(Database db, int oldVersion, int newVersion) {
//    if (oldVersion < newVersion) {
//      print("DB更新！！！");
//      db.execute(
//        // SQL文に適切な空白を入れないとエラーになる
//          "CREATE TABLE ITEM ( "
//              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
//              "item_name TEXT,"
//              "expiration_date TEXT "
//              ")"
//      );
//      print("DB更新！！！");
//    }
//  }

  Future<void> _createTable(Database db, int version) async {
    return await db.execute(
      // SQL文に適切な空白を入れないとエラーになる
        "CREATE TABLE ITEM ( "
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "item_name TEXT,"
            "expiration_date TEXT "
            ")"
    );
  }

  static final _tableName = "Item";

  createItem(Item item) async {
    final db = await database;
    var res = await db.insert(_tableName, item.toMap());
    return res;
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    var res = await db.query(_tableName);
    List<Item> list =
    res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];

    if (list != null){
      list.sort((a,b) => a.expirationDate.compareTo(b.expirationDate));
    }

    return list;
  }

  updateItem(Item item) async {
    final db = await database;
    var res  = await db.update(
        _tableName,
        item.toMap(),
        where: "id = ?",
        whereArgs: [item.id]
    );
    return res;
  }

  deleteItem(int id) async {
    final db = await database;
    var res = db.delete(
        _tableName,
        where: "id = ?",
        whereArgs: [id]
    );
    return res;
  }

  getItem(int id) async {
    final db = await database;
    var res =await  db.query("Item", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Item.fromMap(res.first) : Null ;
  }

  deleteTable() async {
    final db = await database;
    var res = db.delete(
        _tableName,
    );
    return res;

  }

  alterTable() async {
    final db = await database;
    var res = await db.execute("ALTER TABLE ITEM ALTER COLUMN id INTEGER");
    return res;
  }
}