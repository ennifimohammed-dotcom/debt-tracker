import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/debt.dart';

class DbHelper {
  static final DbHelper i = DbHelper._();
  DbHelper._();
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final p = join(await getDatabasesPath(), 'debts_v1.db');
    return openDatabase(p, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE debts (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          personName  TEXT    NOT NULL,
          amount      REAL    NOT NULL,
          paidAmount  REAL    DEFAULT 0,
          date        TEXT    NOT NULL,
          notes       TEXT,
          direction   INTEGER NOT NULL DEFAULT 0
        )
      ''');
    });
  }

  Future<int>        insert(Debt d) async => (await db).insert('debts', d.toMap()..remove('id'));
  Future<int>        update(Debt d) async => (await db).update('debts', d.toMap(), where: 'id=?', whereArgs: [d.id]);
  Future<int>        delete(int id) async => (await db).delete('debts', where: 'id=?', whereArgs: [id]);
  Future<List<Debt>> all()          async {
    final rows = await (await db).query('debts', orderBy: 'date DESC');
    return rows.map(Debt.fromMap).toList();
  }

  Future<Map<String, double>> summary() async {
    final list = await all();
    double iOweT = 0, iOweP = 0, theyT = 0, theyP = 0;
    for (final d in list) {
      if (d.direction == DebtDirection.iOwe) { iOweT += d.amount; iOweP += d.paidAmount; }
      else { theyT += d.amount; theyP += d.paidAmount; }
    }
    return {
      'iOweTotal': iOweT, 'iOwePaid': iOweP, 'iOweLeft': iOweT - iOweP,
      'theyTotal': theyT, 'theyPaid': theyP, 'theyLeft': theyT - theyP,
    };
  }
}
