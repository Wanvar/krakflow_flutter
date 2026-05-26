
import '../models/task.dart';
import 'dart:math' hide log;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

String _getRandPriority(Random rand) {
  final priorities = ["niski", "średni", "wysoki"];
  return priorities[rand.nextInt(priorities.length)];
}

String _getRandDeadline(Random rand) {
  final deadlines = [
    "dzisiaj",
    "jutro",
    "pojutrze",
    "w tym tygodniu",
    "w tym miesiącu",
    "za ponad miesiąc",
  ];
  return deadlines[rand.nextInt(deadlines.length)];
}

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";
  static Future<List<Task>> fetchTasks() async {
    log("$baseUrl/todos", name: "api service");
    final response = await http.get(
      Uri.parse("$baseUrl/todos"),
    );
    log(response.statusCode.toString(),  name: "api service");
    if (response.statusCode == 200) {
      Random rand = Random();
      final data = jsonDecode(response.body);
      final List todos = data["todos"];
      var ret = todos.map((todo) {
        return Task(
          id: todo["id"],
          title: todo["todo"],
          deadline: _getRandDeadline(rand), // brak w API → mockujemy
          done: todo["completed"],
          priority: _getRandPriority(rand)
        );
      }).toList();
      log(ret.length.toString(), name: "api service");
      return ret;
    } else {
      log("błąd odpowiedzi kod:${response.statusCode}",error: "http", name: "api service");
      throw Exception("Błąd pobierania danych");
    }
  }
}