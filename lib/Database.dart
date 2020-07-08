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

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // DBがなかったら作る
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // import 'package:path/path.dart'; が必要
    // なぜか サジェスチョンが出てこない
    String path = join(documentsDirectory.path, "ItemDB.db");

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    return await db.execute(
        "CREATE TABLE ITEM ("
            "id TEXT PRIMARY KEY,"
            "item_name TEXT,"
            "expiration_date TEXT,"
            ")"
    );
  }

  static final _tableName = "Item";

  createItem(Item item) async {
    final db = await database;
    var res = await db.insert(_tableName, item.toMap());
    return res;
  }

  getAllItems() async {
    final db = await database;
    var res = await db.query(_tableName);
    List<Item> list =
    res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];
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

  deleteItem(String id) async {
    final db = await database;
    var res = db.delete(
        _tableName,
        where: "id = ?",
        whereArgs: [id]
    );
    return res;
  }
}