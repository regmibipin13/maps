import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1/data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseHelper {
  static const DB_NAME = 'maps.db';
  static const DB_PATH =
      "/data/user/0/com.example.flutter_application_1/app_flutter";
  static const DIRECTORY_PATH =
      "/storage/emulated/0/Android/data/com.example.flutter_application_1/files";
  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'maps.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE details(
  id INTEGER PRIMARY KEY,
  latitude TEXT,
  longitude TEXT,
  type TEXT,
  price TEXT,
  details TEXT
)
''');
    await db.execute('''
CREATE TABLE photos(
  id INTEGER PRIMARY KEY,
  detailId INTEGER,
  name TEXT
)
''');
  }

  Future<List<Detail>> getDetails() async {
    // Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String path = join(documentsDirectory.path, 'maps.db');
    // databaseFactory.deleteDatabase(path);
    Database db = await instance.database;
    var details = await db.query('details', orderBy: 'id');
    List<Detail> detailList = details.isNotEmpty
        ? details.map((c) => Detail.fromMap(c)).toList()
        : [];
    return detailList;
  }

  Future<int> add(Detail detail) async {
    Database db = await instance.database;
    return await db.insert('details', detail.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    await db.delete('photos', where: 'detailId=?', whereArgs: [id]);
    return await db.delete('details', where: 'id=?', whereArgs: [id]);
  }

  Future<int> update(Detail detail) async {
    Database db = await instance.database;
    return await db.update('details', detail.toMap(),
        where: 'id=?', whereArgs: [detail.id]);
  }

  // For Photos
  Future<List<Photo>> getPhotos() async {
    Database db = await instance.database;
    var details = await db.query('photos', orderBy: 'id');
    List<Photo> detailList =
        details.isNotEmpty ? details.map((c) => Photo.fromMap(c)).toList() : [];
    return detailList;
  }

  Future<int> addPhoto(Photo detail) async {
    Database db = await instance.database;
    return await db.insert('photos', detail.toMap());
  }

  Future<int> removePhoto(Photo photo) async {
    Database db = await instance.database;
    return await db.delete('photos', where: 'name=?', whereArgs: [photo.name]);
  }

  Future<int> updatePhoto(Photo detail) async {
    Database db = await instance.database;
    return await db.update('photos', detail.toMap(),
        where: 'id=?', whereArgs: [detail.id]);
  }

  Future<List<Photo>> getDetailPhotos(int detailId) async {
    Database db = await instance.database;
    var photos = await db
        .rawQuery('SELECT * FROM photos WHERE detailId = ?', [detailId]);
    // print(photos);
    List<Photo> listPhotos =
        photos.isNotEmpty ? photos.map((e) => Photo.fromMap(e)).toList() : [];
    return listPhotos;
  }

  Future<bool> importDatabase() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    var status1 = await Permission.storage.status;

    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'maps.db');

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      file.copy(path);
      return true;
    } else {
      print("Picker Cancelled");
      return false;
    }
  }

  void exportDatabase() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    var status1 = await Permission.storage.status;

    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    try {
      File ourDbFile = File(DB_PATH + '/' + DB_NAME);
      Directory folderPathForDBFile = Directory(DIRECTORY_PATH);
      await folderPathForDBFile.create();
      await ourDbFile.copy("/storage/emulated/0/Download/maps.db");
    } catch (e) {
      print(e);
    }
  }
}
