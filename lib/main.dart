import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  List<Task> tasks = [
    Task(
      title: "nauka do kolokwium",
      deadline: "jutro",
      done: true,
      priority: Priority.High,
    ),
    Task(
      title: "podlać petunie",
      deadline: "dzisiaj",
      done: true,
      priority: Priority.Low,
    ),
    Task(
      title: "zrobić pranie",
      deadline: "w tym tygodniu",
      done: false,
      priority: Priority.Medium,
    ),
    Task(
      title: "wymienić olej w samochodzie",
      deadline: "w tym miesiącu",
      done: false,
      priority: Priority.High,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Center(child: Text("Krakflow"))),

        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Masz dziś ${tasks.length} zadania \n"
                "Wykonano do tej pory ${tasks.where((e) => e.done).length} zadania",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigoAccent,
                ),
              ),

              SizedBox(height: 32),
              Center(
                child: Text(
                  "Dzisiejsze zadania",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    IconData icon = task.done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked;

                    var priorityMsg = switch (task.priority) {
                      Priority.Low => 'niski',
                      Priority.Medium => 'średni',
                      Priority.High => 'wysoki',
                      _ => 'nieznany',
                    };
                    return Column(
                      children: [
                        TaskCard(
                          title: task.title,
                          subtitle:
                              "termin: ${task.deadline} | priorytet: $priorityMsg",
                          icon: icon,
                        ),
                        SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final Priority priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
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

enum Priority { Low, Medium, High }
