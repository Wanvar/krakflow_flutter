import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(title: "demo", home: TaskView());
  }
}

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  @override
  Widget build(BuildContext context) {
    var tasks = TaskRepository.tasks;

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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final Task? newTask = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(),
              ),
            );
            if (newTask != null) {
              setState(() {
                if(newTask.title.isNotEmpty && newTask.deadline.isNotEmpty)
                  TaskRepository.tasks.add(newTask);
              });
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
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

// class AddTaskScreen extends StatelessWidget {
//   const AddTaskScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Nowe zadanie"),
//       ),
//       body: Center(
//         child: Text("Tutaj będzie formularz dodawania taska"),
//       ),
//     );
//   }
//
//
// }

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  // controller dla priorytetu
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nowe zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "termin",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: strToPriority(priorityController.text),
                  done: false,

                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}
