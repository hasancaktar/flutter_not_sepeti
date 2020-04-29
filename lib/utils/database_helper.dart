import 'dart:io';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  Future<Database> _initializeDatabase() async {
    var lock = Lock();
    Database _db;

    if (_db == null) {
      await lock.synchronized(() async {
        if (_db == null) {
          var databasePath = await getDatabasesPath();
          var path = join(databasePath, "appDB.db");
          print("OLUŞACAK DBNİN PATHİ : $path");
          var file = File(path);
          if (!await file.exists()) {
            ByteData data = await rootBundle.load(join("assets", "notlar.db"));
            List<int> bytes =
                data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            await File(path).writeAsBytes(bytes);
          }
          _db = await openDatabase(path);
        }
      });
    }
    return _db;
  }

  Future<List<Map<String, dynamic>>> kategorileriGetir() async {
    var db = await _getDatabase();
    var sonuc = await db.query("kategori");
    return sonuc;
  }

  Future<List<Kategori>> kategoriListesiniGetir() async {
    var kategorileriIcerenMapListesi = await kategorileriGetir();
    var kategoriListesi = await List<Kategori>();
    for (Map map in kategorileriIcerenMapListesi) {
      await kategoriListesi.add(Kategori.fromMap(map));
    }
    return kategoriListesi;
  }

  Future<int> kategoriEkle(Kategori kategori) async {
    var db = await _getDatabase();
    var sonuc = await db.insert("kategori", kategori.toMap());
    return sonuc;
  }

  Future<int> kategoriGuncelle(Kategori kategori) async{
    var db= await _getDatabase();
    var sonuc = await db.update("kategori", kategori.toMap(), where: 'kategoriID = ?', whereArgs: [kategori.kategoriID]);
    return sonuc;
  }
  Future<int> kategoriSil(int kategoriID) async{
    var db= await _getDatabase();
    var sonuc = await db.delete("kategori", where: 'kategoriID = ?', whereArgs: [kategoriID]);
    return sonuc;
  }

  Future<List<Map<String, dynamic>>> notlariGetir() async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        'select * from "not" inner join kategori on kategori.kategoriID = "not".kategoriID order by notID Desc;');
    return sonuc;
  }

  Future<List<Not>> notListesiniGeti() async {
    var notlarMapListesi = await notlariGetir();
    var notListesi = await List<Not>();
    for (Map map in notlarMapListesi) {
      await notListesi.add(Not.fromMap(map));
    }
    return notListesi;
  }

  Future<int> notEkle(Not not) async {
    var db = await _getDatabase();
    var sonuc = await db.insert("not", not.toMap());
    return sonuc;
  }

  Future<int> notGuncelle(Not not) async {
    var db = await _getDatabase();
    var sonuc = await db
        .update("not", not.toMap(), where: 'notID=?', whereArgs: [not.notID]);
    return sonuc;
  }

  Future<int> notSil(int notID) async {
    var db = await _getDatabase();
    var sonuc = await db.delete("not", where: "notID = ?", whereArgs: [notID]);
    return sonuc;
  }

  String dateFormat(DateTime tm) {
    DateTime today = DateTime.now();
    Duration oneDay = Duration(days: 1);
    Duration twoDay = Duration(days: 2);
    Duration oneWeek = Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = "ocak";
        break;
      case 2:
        month = "şubat";
        break;
      case 3:
        month = "mart";
        break;
      case 4:
        month = "nisan";
        break;
      case 5:
        month = "mayıs";
        break;
      case 6:
        month = "haziran";
        break;
      case 7:
        month = "temmuz";
        break;
      case 8:
        month = "ağustos";
        break;
      case 9:
        month = "eylül";
        break;
      case 10:
        month = "ekim";
        break;
      case 11:
        month = "kasım";
        break;
      case 12:
        month = "aralık";
        break;
    }
    Duration difference = today.difference(tm);
    if (difference.compareTo(oneDay) < 1) {
      return "bugün";
    } else if (difference.compareTo(twoDay) < 1) {
      return "dün";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "pazartesi";
        case 2:
          return "salı";
        case 3:
          return "çarşamba";
        case 4:
          return "perşembe";
        case 5:
          return "cuma";
        case 6:
          return "cumartesi";
        case 7:
          return "pazar";
      }
    } else if (tm.year == today.year) {
      return "${tm.day} $month";
    } else {
      return "${tm.day} $month ${tm.year}";
    }
    return "";
  }
}
