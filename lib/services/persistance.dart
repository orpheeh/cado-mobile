import 'package:cado/services/project.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:latlong/latlong.dart';

class Persistance {
  Future<Database> createDb() async {
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      onCreate: (db, version) async {
        db.execute(
            "CREATE TABLE geopos(id INTEGER PRIMARY KEY AUTOINCREMENT, lat DOUBLE, lng DOUBLE, title TEXT, details TEXT, isForDelete INTEGER)");

        db.execute(
            "CREATE TABLE zones(id INTEGER PRIMARY KEY AUTOINCREMENT, lat DOUBLE, lng DOUBLE)");
        return db;
      },
      onUpgrade: (db, version, otherVersion) {
        db.execute('DROP TABLE geopos');
        db.execute('DROP TABLE zones');
        db.execute(
            "CREATE TABLE geopos(id INTEGER PRIMARY KEY AUTOINCREMENT, lat DOUBLE, lng DOUBLE, title TEXT, details TEXT, isForDelete INTEGER)");
        db.execute(
            "CREATE TABLE zones(id INTEGER PRIMARY KEY AUTOINCREMENT, lat DOUBLE, lng DOUBLE)");
      },
      version: 20,
    );
    return database;
  }

  Future<void> insertGoePosition(
      GeographicPosition geographicPosition, Database database) async {
    final Database db = await database;

    await db.insert(
      'geopos',
      geographicPosition.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertZone(
      List<Map<String, dynamic>> zone, Database database) async {
    final Database db = await database;

    await zone.forEach((latlng) async {
      await db.insert('zones', latlng,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> deleteGeoPosition(int id, Database database) async {
    final db = await database;

    await db.delete(
      'geopos',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteZone(Database database) async {
    final db = await database;

    await db.delete('zones');
  }

  Future<void> deleteAllGeoPosition(Database database) async {
    final Database db = await database;

    await db.delete('geopos', where: "isForDelete = ?", whereArgs: [0]);
  }

  Future<List<GeographicPosition>> geographicPositions(
      Database database) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('geopos');

    return List.generate(maps.length, (i) {
      return GeographicPosition(
        id: maps[i]['id'],
        title: maps[i]['title'],
        details: maps[i]['details'],
        isForDelete: maps[i]['isForDelete'] != 0,
        position: LatLng(maps[i]['lat'], maps[i]['lng']),
      );
    });
  }

  Future<List<Map<String, dynamic>>> zone(Database database) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('zones');

    return List.generate(maps.length, (i) {
      return <String, dynamic>{
        "lat": maps[i]['lat'],
        "lng": maps[i]['lng'],
      };
    });
  }
}
