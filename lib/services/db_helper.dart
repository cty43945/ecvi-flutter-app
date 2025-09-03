import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/animal.dart';
import '../models/certificate.dart';
import '../models/veterinarian.dart';
import '../models/contact.dart';
import '../models/address.dart';

/// Provides a simple wrapper around the SQLite database used to store
/// certificates and their associated animals.  The database file lives
/// within the app’s documents directory, so it persists across launches but
/// remains private to the app.
class DbHelper {
  static final DbHelper _instance = DbHelper._internal();

  factory DbHelper() => _instance;

  DbHelper._internal();

  Database? _database;

  /// Initializes the database if not already open.  Creates the tables
  /// necessary to store certificates and animals.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDir.path, 'ecvi.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Certificates table
        await db.execute('''
          CREATE TABLE certificates (
            id TEXT PRIMARY KEY,
            vet_license TEXT,
            vet_state TEXT,
            vet_first_name TEXT,
            vet_last_name TEXT,
            vet_accreditation TEXT,
            consignor_name TEXT,
            consignor_business TEXT,
            consignor_phone TEXT,
            consignor_email TEXT,
            origin_street TEXT,
            origin_city TEXT,
            origin_state TEXT,
            origin_postal_code TEXT,
            consignee_name TEXT,
            consignee_business TEXT,
            consignee_phone TEXT,
            consignee_email TEXT,
            destination_street TEXT,
            destination_city TEXT,
            destination_state TEXT,
            destination_postal_code TEXT,
            movement_purpose TEXT,
            date_of_issue TEXT,
            statements TEXT,
            signature_path TEXT
          )
        ''');
        // Animals table
        await db.execute('''
          CREATE TABLE animals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            certificate_id TEXT,
            identifier TEXT,
            species TEXT,
            breed TEXT,
            sex TEXT,
            age TEXT,
            color TEXT,
            tests TEXT,
            FOREIGN KEY(certificate_id) REFERENCES certificates(id)
          )
        ''');
      },
    );
  }

  /// Inserts a certificate and its animals into the database.
  Future<void> insertCertificate(Certificate cert) async {
    final db = await database;
    await db.insert('certificates', cert.toMap());
    // insert animals
    for (final animal in cert.animals) {
      await db.insert('animals', animal.toMap(cert.id));
    }
  }

  /// Fetches all certificates, optionally filtering on completed ones.
  /// This does not return animals; call [getAnimalsForCertificate] to
  /// retrieve animals for a given certificate.
  Future<List<Certificate>> getCertificates() async {
    final db = await database;
    final maps = await db.query('certificates');
    return maps.map((row) {
      final vet = Veterinarian(
        firstName: row['vet_first_name'] as String,
        lastName: row['vet_last_name'] as String,
        licenseNumber: row['vet_license'] as String,
        licenseState: row['vet_state'] as String,
        accreditationNumber: row['vet_accreditation'] as String?,
      );
      final consignor = Contact(
        name: row['consignor_name'] as String,
        businessName: row['consignor_business'] as String?,
        phone: row['consignor_phone'] as String?,
        email: row['consignor_email'] as String?,
        address: Address(
          street: row['origin_street'] as String,
          city: row['origin_city'] as String,
          state: row['origin_state'] as String,
          postalCode: row['origin_postal_code'] as String,
        ),
      );
      final consignee = Contact(
        name: row['consignee_name'] as String,
        businessName: row['consignee_business'] as String?,
        phone: row['consignee_phone'] as String?,
        email: row['consignee_email'] as String?,
        address: Address(
          street: row['destination_street'] as String,
          city: row['destination_city'] as String,
          state: row['destination_state'] as String,
          postalCode: row['destination_postal_code'] as String,
        ),
      );
      return Certificate(
        id: row['id'] as String,
        veterinarian: vet,
        consignor: consignor,
        consignee: consignee,
        origin: consignor.address,
        destination: consignee.address,
        movementPurpose: row['movement_purpose'] as String,
        dateOfIssue: DateTime.parse(row['date_of_issue'] as String),
        statements: (row['statements'] as String).split('\n'),
        animals: const <Animal>[],
        signaturePath: row['signature_path'] as String?,
      );
    }).toList();
  }

  /// Retrieves the animals for a given certificate ID.
  Future<List<Animal>> getAnimalsForCertificate(String certId) async {
    final db = await database;
    final maps = await db.query('animals', where: 'certificate_id = ?', whereArgs: [certId]);
    return maps.map((row) {
      return Animal(
        identifier: row['identifier'] as String,
        species: row['species'] as String?,
        breed: row['breed'] as String?,
        sex: row['sex'] as String?,
        age: row['age'] as String?,
        color: row['color'] as String?,
        tests: row['tests'] != null ? (row['tests'] as String).split('\n') : null,
      );
    }).toList();
  }
}