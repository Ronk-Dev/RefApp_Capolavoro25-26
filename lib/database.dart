import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async 
  {
    //Creo la tabella per le società conosciute
    await db.execute('''
      CREATE TABLE societa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        presenteOnline BIT NOT NULL
      )
    ''');

    //Creo la tabella per i luoghi conosciuti
    await db.execute('''
      CREATE TABLE luoghi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        presenteOnline BIT NOT NULL
      )
    ''');

    //Creo la tabella per gli eventi
    await db.execute('''
      CREATE TABLE eventi 
      (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipologia TEXT NOT NULL,
        data TEXT,
        orario TEXT NOT NULL,
        luogo TEXT,
        descrizione TEXT,
        periodicita TEXT,
        sqCasa TEXT,
        sqOspiti TEXT,
        giorniReferto REAL,
        catPartita TEXT,
        rimborso FLOAT,
        pacco REAL,
        presenteOnline BIT NOT NULL
      )
    ''');

    //Creo la tabella per le note
    await db.execute('''
      CREATE TABLE note 
      (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipologia TEXT NOT NULL,
        nominativo TEXT,
        nota TEXT,
        amm BIT,
        esp BIT,
        presenteOnline BIT NOT NULL
      )
    ''');
  }
}