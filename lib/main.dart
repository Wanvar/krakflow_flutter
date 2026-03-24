import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  List<Task> tasks = [
    Task(title: "test z programowania", deadline: "jutro"),
    Task(title: "podlać petunie", deadline: "dzisiaj"),
    Task(title: "zrobić pranie", deadline: "w tym tygodniu"),
    Task(title: "wymienić olej w samochodzie", deadline: "w tym miesiącu")
  ];


  @override
  Widget build(BuildContext context) {
    IconData icon = IconData(0xe146, fontFamily: 'MaterialIcons');

    return MaterialApp(
      home: Scaffold(

        appBar: AppBar(title: Center(child: Text("Krakflow"))),

        body:


        ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index){
              final task = tasks[index];
              return TaskCard(title: task.title, subtitle: task.deadline, icon: icon);
            }

          ),

      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  Task({required this.title, required this.deadline});
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

