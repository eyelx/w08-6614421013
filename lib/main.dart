import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เปิดฐานข้อมูลและสร้างตาราง Hamster
  final database = openDatabase(
    join(await getDatabasesPath(), 'hamster_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE hamsters(id INTEGER PRIMARY KEY, name TEXT, breed TEXT, age INTEGER, color TEXT, weight REAL, vaccinated INTEGER)',
      );
    },
    version: 1,
  );

  // ฟังก์ชันเพิ่มแฮมสเตอร์
  Future<void> insertHamster(Hamster hamster) async {
    final db = await database;
    await db.insert(
      'hamsters',
      hamster.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ฟังก์ชันดึงรายชื่อแฮมสเตอร์ทั้งหมด
  Future<List<Hamster>> hamsters() async {
    final db = await database;
    final List<Map<String, Object?>> hamsterMaps = await db.query('hamsters');
    return [
      for (final {'id': id, 'name': name, 'breed': breed, 'age': age, 'color': color, 'weight': weight, 'vaccinated': vaccinated} in hamsterMaps)
        Hamster(
          id: id as int,
          name: name as String,
          breed: breed as String,
          age: age as int,
          color: color as String,
          weight: (weight as num).toDouble(),
          vaccinated: (vaccinated as int) == 1,
        ),
    ];
  }

  // ฟังก์ชันอัปเดตแฮมสเตอร์
  Future<void> updateHamster(Hamster hamster) async {
    final db = await database;
    await db.update(
      'hamsters',
      hamster.toMap(),
      where: 'id = ?',
      whereArgs: [hamster.id],
    );
  }

  // ฟังก์ชันลบแฮมสเตอร์
  Future<void> deleteHamster(int id) async {
    final db = await database;
    await db.delete(
      'hamsters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // สร้างแฮมสเตอร์ตัวอย่าง
  var hammy = Hamster(
    id: 0,
    name: 'Hammy',
    breed: 'Syrian',
    age: 1,
    color: 'Golden',
    weight: 0.12,
    vaccinated: true,
  );

  await insertHamster(hammy);
  print(await hamsters());

  // อัปเดตอายุแฮมสเตอร์
  hammy = Hamster(
    id: hammy.id,
    name: hammy.name,
    breed: hammy.breed,
    age: hammy.age + 1,
    color: hammy.color,
    weight: hammy.weight,
    vaccinated: hammy.vaccinated,
  );
  await updateHamster(hammy);
  print(await hamsters());

  // ลบแฮมสเตอร์
  await deleteHamster(hammy.id);
  print(await hamsters());
}

class Hamster {
  final int id;
  final String name;
  final String breed;
  final int age;
  final String color;
  final double weight;
  final bool vaccinated;

  Hamster({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.color,
    required this.weight,
    required this.vaccinated,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'color': color,
      'weight': weight,
      'vaccinated': vaccinated ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Hamster{id: $id, name: $name, breed: $breed, age: $age, color: $color, weight: $weight, vaccinated: $vaccinated}';
  }
}
