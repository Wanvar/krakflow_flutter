import 'dart:developer';

import 'package:hive_ce/hive.dart';
import '../models/task.dart';
class TaskLocalDatabase {
// pobieramy box otworzony przez nas w main
  static Box get _box => Hive.box("tasks");
  static List<Task> getTasks() {
    log("pobrano elementy z bazy", name: "baza danych");
// zwraca wszystkie wartości zapisane w boxie
    return _box.values.map((item) {

      return Task.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }
  static Future<void> saveTasks(List<Task> tasks) async {
    await _box.clear();
// zapisuje zadanie pod kluczem równym jego id
    for (final task in tasks) {
      await _box.put(task.id, task.toMap());
    }
    log("zapisano elementy do bazy", name: "baza danych");
  }
  static Future<void> addTask(Task task) async {
    await _box.put(task.id, task.toMap());
    log("dodano zadanie: ${task.title}", name: "baza danych");
  }
  static Future<void> updateTask(Task task) async {

    await _box.put(task.id, task.toMap());
    log("zaktualizowana zadanie: ${task.title}", name: "baza danych");
  }

  static Future<void> deleteTask(int id) async {
// usuwa zadanie zapisane pod danym kluczem

    await _box.delete(id);
    log("usunięto zadanie o id: ${id}", name: "baza danych");
  }
  static Future<void> deleteAllTasks() async {

    await _box.clear();
    log("usunięto wszystkie zadania", name: "baza danych");
  }
  static bool isEmpty() {
    return _box.isEmpty;
  }
}