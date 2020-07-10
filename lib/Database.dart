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

  //getter
  Future<Database> get database async {

    if (_database != null) {
      return _database;
    }

    // DBがなかったら作る
    _database = await initDB();
    return _database;
  }

  /*
   * DB作成用のメソッド。
   */
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // import 'package:path/path.dart'; が必要
    String path = join(documentsDirectory.path, "ItemDB.db");

    return await openDatabase(path, version: 5, onCreate: _createTable);
  }

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

  //登録用のメソッド。
  createItem(Item item) async {
    final db = await database;
    var res = await db.insert(_tableName, item.toMap());
    return res;
  }

  //一覧表示用のメソッド
  Future<List<Item>> getAllItems() async {
    final db = await database;
    var res = await db.query(_tableName);
    List<Item> list =
    res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];

    //日付の昇順でソート
    if (list != null){
      list.sort((a,b) => a.expirationDate.compareTo(b.expirationDate));
    }

    return list;
  }

  //削除用のメソッド
  deleteItem(int id) async {
    final db = await database;
    var res = db.delete(
        _tableName,
        where: "id = ?",
        whereArgs: [id]
    );
    return res;
  }
}
