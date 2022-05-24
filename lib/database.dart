import 'package:app/data_models/items.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseClass {
  Database? db;

  Future OpenDB() async {
    try {
      var dbpath = await getDatabasesPath();
      String path = join(dbpath, "cart.db");
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          this.db = db;
          createTables();
        },
      );
      return true;
    } catch (e) {
      print("ERROR IN OPEN DATABASE $e");
      return Future.error(e);
    }
  }

  createTables() async {
    try {
      var qry = "CREATE TABLE IF NOT EXISTS cart ( "
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "image Text,"
          "price REAL,";
    } catch (e) {}
  }

  Future getCartList() async {
    try {
      var list = await db?.rawQuery('SELECT * FROM cart', []);
      return list ?? [];
    } catch (e) {
      return Future.error(e);
    }
  }

  Future addToCart(ItemData data) async {
    await this.db?.transaction((txn) async {
      var qry =
          'INSERT INTO cart(id, name, price, image) VALUES(${data.itemId}, "${data.name}",${data.price}, "${data.imageUrl}")';
      int id1 = await txn.rawInsert(qry);
      return id1;
    });
  }

  Future removeFromCart(int ID) async {
    var qry = "DELETE FROM cart where id = ${ID}";
    return await this.db?.rawDelete(qry);
  }
}
