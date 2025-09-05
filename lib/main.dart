import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เปิดฐานข้อมูลและสร้างตาราง AnimalTreatment
  final database = openDatabase(
    join(await getDatabasesPath(), 'animal_treatment.db'),
    onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE treatments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animalName TEXT,
          species TEXT,
          age INTEGER,
          symptoms TEXT,
          treatment TEXT,
          doctor TEXT,
          date TEXT
        )
        ''');
    },
    version: 1,
  );

  // ฟังก์ชันเพิ่มข้อมูลการรักษา
  Future<void> insertTreatment(AnimalTreatment treatment) async {
    final db = await database;
    await db.insert(
      'treatments',
      treatment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ฟังก์ชันดึงข้อมูลการรักษาทั้งหมด
  Future<List<AnimalTreatment>> treatments() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('treatments');
    return maps.map((m) => AnimalTreatment.fromMap(m)).toList();
  }

  // ฟังก์ชันอัปเดตข้อมูลการรักษา
  Future<void> updateTreatment(AnimalTreatment treatment) async {
    final db = await database;
    await db.update(
      'treatments',
      treatment.toMap(),
      where: 'id = ?',
      whereArgs: [treatment.id],
    );
  }

  // ฟังก์ชันลบข้อมูลการรักษา
  Future<void> deleteTreatment(int id) async {
    final db = await database;
    await db.delete('treatments', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------------
  // ทดสอบการทำงาน
  // -------------------------

  // เพิ่มข้อมูลใหม่
  var record = AnimalTreatment(
    animalName: 'Lucky',
    species: 'Dog',
    age: 5,
    symptoms: 'ไข้, ซึม',
    treatment: 'ฉีดยาลดไข้ + ให้น้ำเกลือ',
    doctor: 'น.สพ. สมชาย',
    date: '2025-09-03',
  );
  await insertTreatment(record);

  // แสดงข้อมูลทั้งหมด
  print("📋 หลังจาก insert:");
  print(await treatments());

  // อัปเดตข้อมูล
  var allRecords = await treatments();
  var firstRecord = allRecords.first;
  var updatedRecord = AnimalTreatment(
    id: firstRecord.id,
    animalName: firstRecord.animalName,
    species: firstRecord.species,
    age: firstRecord.age,
    symptoms: firstRecord.symptoms,
    treatment: 'เปลี่ยนเป็นให้ยาปฏิชีวนะ + ให้น้ำเกลือ',
    doctor: firstRecord.doctor,
    date: firstRecord.date,
  );
  await updateTreatment(updatedRecord);

  print("✏️ หลังจาก update:");
  print(await treatments());

  // ลบข้อมูล
  await deleteTreatment(updatedRecord.id!);

  print("🗑 หลังจาก delete:");
  print(await treatments());
}

// -------------------------
// คลาสเก็บข้อมูลการรักษา
// -------------------------
class AnimalTreatment {
  final int? id; // ใช้ nullable เพราะ SQLite จะ generate ให้เอง
  final String animalName;
  final String species;
  final int age;
  final String symptoms;
  final String treatment;
  final String doctor;
  final String date;

  AnimalTreatment({
    this.id,
    required this.animalName,
    required this.species,
    required this.age,
    required this.symptoms,
    required this.treatment,
    required this.doctor,
    required this.date,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'animalName': animalName,
      'species': species,
      'age': age,
      'symptoms': symptoms,
      'treatment': treatment,
      'doctor': doctor,
      'date': date,
    };
  }

  factory AnimalTreatment.fromMap(Map<String, Object?> map) {
    return AnimalTreatment(
      id: map['id'] as int?,
      animalName: map['animalName'] as String,
      species: map['species'] as String,
      age: map['age'] as int,
      symptoms: map['symptoms'] as String,
      treatment: map['treatment'] as String,
      doctor: map['doctor'] as String,
      date: map['date'] as String,
    );
  }

  @override
  String toString() {
    return 'Treatment{id: $id, animalName: $animalName, species: $species, age: $age, symptoms: $symptoms, treatment: $treatment, doctor: $doctor, date: $date}';
  }
}
