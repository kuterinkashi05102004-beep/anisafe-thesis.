  import 'package:path/path.dart';
  import 'package:sqflite/sqflite.dart';

  class DatabaseHelper {
    static Database? _database;

    DatabaseHelper._();

    static final DatabaseHelper instance = DatabaseHelper._();
    Future<Database> get database async {
      if (_database != null) return _database!;

      _database = await _initDatabase();

      return _database!;
    }



    Future<Database> _initDatabase() async {
      final databasePath = await getDatabasesPath();

      final path = join(databasePath, 'pet_monitor.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
      );
    }







      Future<void> _createDatabase(Database db, int version) async {
          // USERS TABLE
          await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              full_name TEXT,
              gender TEXT,
              age INTEGER,
              username TEXT UNIQUE,
              password TEXT
            )
          ''');


          // HEALTH RECORDS TABLE
          await db.execute('''
            CREATE TABLE patients(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  user_id INTEGER,
                  patient_name TEXT,
                  age TEXT,
                  species TEXT,
                  breed TEXT,
                  size TEXT,
                  sex TEXT,
                  birth_date TEXT,
                  color TEXT,
                  owner_name TEXT,
                  contact TEXT,
                  address TEXT,
                  photo_path TEXT,
                  FOREIGN KEY(user_id) REFERENCES users(id)
                )
          ''');


          await db.execute('''
            CREATE TABLE records(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              patient_id INTEGER,
              bpm INTEGER,
              spo2 INTEGER,
              temperature REAL,
              respiratory_rate INTEGER,
              date TEXT,
              time TEXT,
              log_type TEXT DEFAULT 'Manual',
              finding TEXT DEFAULT 'Normal',
              trigger_finding TEXT,
              rf_finding TEXT,
              FOREIGN KEY(patient_id) REFERENCES patients(id)
            )
          ''');

        }









    Future<int> insertUser({
      required String fullName,
      required String gender,
      required int age,
      required String username,
      required String password,
    }) async {
      final db = await database;

      return await db.insert(
        'users',
        {
          'full_name': fullName,
          'gender': gender,
          'age': age,
          'username': username,
          'password': password,
        },
      );
    }


    Future<int> insertPatient({
      required int userId,
      required String patientName,
      required String age,
      required String species,
      required String breed,
      required String size,
      required String sex,
      required String birthDate,
      required String color,
      required String ownerName,
      required String contact,
      required String address,
      required String photoPath,
    }) async {
      final db = await database;

      return await db.insert(
        'patients',
        {
          'user_id': userId,
          'patient_name': patientName,
          'age': age,
          'species': species,
          'breed': breed,
          'size': size,
          'sex': sex,
          'birth_date': birthDate,
          'color': color,
          'owner_name': ownerName,
          'contact': contact,
          'address': address,
          'photo_path': photoPath,
        },
      );
    }


    Future<int> updatePatient({
      required int patientId,
      required String patientName,
      required String age,
      required String species,
      required String breed,
      required String size,
      required String sex,
      required String birthDate,
      required String color,
      required String ownerName,
      required String contact,
      required String address,
      required String photoPath,
    }) async {
      final db = await database;

      return await db.update(
        'patients',
        {
          'patient_name': patientName,
          'age': age,
          'species': species,
          'breed': breed,
          'size': size,
          'sex': sex,
          'birth_date': birthDate,
          'color': color,
          'owner_name': ownerName,
          'contact': contact,
          'address': address,
          'photo_path': photoPath,
        },
        where: 'id = ?',
        whereArgs: [patientId],
      );
    }


    Future<Map<String, dynamic>?> loginUser({
      required String username,
      required String password,
    }) async {
      final db = await database;

      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first;
      }

      return null;
    }


    Future<int> insertRecord({
      required int patientId,
      required int bpm,
      required int spo2,
      required double temperature,
      required int respiratoryRate,
      required String date,
      required String time,
      String logType = 'Manual',
      String finding = 'Normal',
      String? triggerFinding,
      String? rfFinding,
    }) async {
      final db = await database;

      return await db.insert(
        'records',
        {
          'patient_id': patientId,
          'bpm': bpm,
          'spo2': spo2,
          'temperature': temperature,
          'respiratory_rate': respiratoryRate,
          'date': date,
          'time': time,
          'log_type': logType,
          'finding': finding,
          'trigger_finding': triggerFinding,
          'rf_finding': rfFinding,
        },
      );
    }

    Future<List<Map<String, dynamic>>> getHealthRecords({
      required int patientId,
    }) async {
      final db = await database;

      return await db.query(
        'records',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'id DESC',
      );
    }

    Future<Map<String, dynamic>?> getRecordById(int recordId) async {
      final db = await database;

      final result = await db.query(
        'records',
        where: 'id = ?',
        whereArgs: [recordId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first;
      }

      return null;
    }

    Future<List<Map<String, dynamic>>> getPatients( { required int userId, } ) async {
      final db = await database;

      return await db.query(
        'patients',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'patient_name ASC',
      );
    }


    Future<int> updatePatientPhoto({
      required int patientId,
      required String photoPath,
    }) async {
      final db = await database;

      return await db.update(
        'patients',
        {
          'photo_path': photoPath,
        },
        where: 'id = ?',
        whereArgs: [patientId],
      );
    }



    Future<String?> getPatientPhoto(int patientId) async {
      final db = await database;

      final result = await db.query(
        'patients',
        columns: ['photo_path'],
        where: 'id = ?',
        whereArgs: [patientId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first['photo_path'] as String?;
      }

      return null;
    }

    Future<int> deletePatient(int patientId) async {
      final db = await database;

      return await db.delete(
        'patients',
        where: 'id = ?',
        whereArgs: [patientId],
      );
    }


    Future<int> deleteHealthRecord(int recordId) async {
      final db = await database;

      return await db.delete(
        'records',
        where: 'id = ?',
        whereArgs: [recordId],
      );
    }

    

    
  }