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
  String filter = "wszystkie";
  String selectedFilter = "wszystkie";

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = TaskRepository.tasks;
    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((task) => !task.done).toList();
    }

    return  Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Krakflow")),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Potwierdzenie"),
                      content: Text(
                        "Czy na pewno chcesz usunąć wszystkie zadania?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Anuluj"),
                        ),
                        TextButton(
                          onPressed: () {

                            setState(() {
                              TaskRepository.tasks.clear(); // usuwa wszystkie elementy z listy


                             });



                            Navigator.pop(context); // zamyka dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Usunięto wszystkie zadania!"),
                              ),
                            );

                          },

                          child: Text("Usuń"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Masz dziś ${TaskRepository.tasks.length} zadania \n"
                "Wykonano do tej pory ${TaskRepository.tasks.where((e) => e.done).length} zadania",
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
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = "wszystkie";
                        });
                      },
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.purple, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: selectedFilter == "wszystkie"
                            ? Colors.white
                            : Colors.purple,
                        backgroundColor: selectedFilter == "wszystkie"
                            ? Colors.purple
                            : Colors.transparent,
                      ),
                      child: Text("Wszystkie"),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = "do zrobienia";
                        });

                      },
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.purple, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: selectedFilter == "do zrobienia"
                            ? Colors.white
                            : Colors.purple,
                        backgroundColor: selectedFilter == "do zrobienia"
                            ? Colors.purple
                            : Colors.transparent,
                      ),
                      child: Text("Do zrobienia"),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = "wykonane";
                        });
                      },
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.purple, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: selectedFilter == "wykonane"
                            ? Colors.white
                            : Colors.purple,
                        backgroundColor: selectedFilter == "wykonane"
                            ? Colors.purple
                            : Colors.transparent,
                      ),
                      child: Text("Wykonane"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];

                    IconData icon = task.done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked;

                    var priorityMsg = switch (task.priority) {
                      Priority.Low => 'niski',
                      Priority.Medium => 'średni',
                      Priority.High => 'wysoki',
                      _ => 'nieznany',
                    };

                    return Dismissible(
                      key: ValueKey(task.title),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          TaskRepository.tasks.remove(task);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Zadanie ${task.title} usunięte"),
                            ),
                          );
                        });
                      },
                      child: Column(
                        children: [
                          TaskCard(
                            title: task.title,
                            subtitle:
                                "termin: ${task.deadline} | priorytet: $priorityMsg",
                            done: task.done,
                            onChanged: (value) {
                              setState(() {
                                task.done = value!;
                              });
                            },
                            onTap: () async {
                              final Task? updatedTask = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditTaskScreen(taskToUpdate: task),
                                ),
                              );
                              // ważne! pamiętamy o setState() do odświeżenia ekranu i akcji podmiany taska na nowy edytowany
                              if (updatedTask != null) {
                                setState(() {
                                  TaskRepository.tasks[index] = updatedTask;
                                });
                              }
                            },
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
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
              MaterialPageRoute(builder: (context) => AddTaskScreen()),
            );
            if (newTask != null &&
                newTask.title.isNotEmpty &&
                newTask.deadline.isNotEmpty) {
              setState(() {
                TaskRepository.tasks.add(newTask);
              });
            }
          },
          child: Icon(Icons.add),
        ),

    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: done ? Colors.grey : Colors.black54),
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

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

class EditTaskScreen extends StatelessWidget {
  final Task taskToUpdate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  EditTaskScreen({super.key, required this.taskToUpdate}) {
    titleController.text = taskToUpdate.title;
    deadlineController.text = taskToUpdate.deadline;
    priorityController.text = priorityToStr(taskToUpdate.priority);
  }

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
                  done: taskToUpdate.done,
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
