import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'services/task_sync_service.dart';
import 'services/task_local_database.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // inicjalizacja

  await Hive.openBox("tasks"); // otwarcie kontenera
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "demo", home: TaskView());
  }
}

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  String selectedFilter = "wszystkie";
  (int allTasks, int doneTasks, int todoTasks) taskCounter = (0, 0, 0);
  bool counterUpdated = false;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = loadTasks();
  }



  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  Future<List<Task>> loadTasksNoSync() async {
    return TaskLocalDatabase.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        onPressed: () async {
                          await TaskLocalDatabase.deleteAllTasks();
                          setState(() {
                            _tasksFuture = loadTasksNoSync();
                            taskCounter = (0,0,0);
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
              "Masz w sumie ${taskCounter.$1} zadań \n"
              "Wykonano do tej pory ${taskCounter.$2} zadania \n"
              "Masz do zrobienia ${taskCounter.$3} zadań \n",
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
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Nie udało się pobrać zdalnych zadań \n${snapshot.error}",
                          ),
                        ),
                      );
                    });
                  }


                  final allTasks = snapshot.data!;

                  if(!counterUpdated){
                    int all = allTasks.length;
                    int done = allTasks.where((task) => task.done).length;
                    int todo= allTasks.where((task) => !task.done).length;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        counterUpdated = true;
                        taskCounter = (all, done, todo);
                      });
                    });
                  }

                  List<Task> filteredTasks;

                  if (selectedFilter == "wykonane") {
                    filteredTasks = allTasks
                        .where((task) => task.done)
                        .toList();
                  } else if (selectedFilter == "do zrobienia") {
                    filteredTasks = allTasks
                        .where((task) => !task.done)
                        .toList();
                  } else {
                    filteredTasks = allTasks;
                  }



                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      // var priorityMsg = switch (task.priority) {
                      //   Priority.Low => 'niski',
                      //   Priority.Medium => 'średni',
                      //   Priority.High => 'wysoki',
                      //   _ => 'nieznany',
                      // };

                      return Dismissible(
                        key: ValueKey(task.title),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          await TaskLocalDatabase.deleteTask(task.id);
                          setState(() {
                            //database_tasks.remove(task);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Zadanie ${task.title} usunięte"),
                              ),
                            );

                            _tasksFuture = loadTasksNoSync();
                            counterUpdated = false;

                          });
                        },
                        child: Column(
                          children: [
                            TaskCard(
                              title: task.title,
                              subtitle:
                                  "termin: ${task.deadline} | priorytet: ${task.priority}",
                              done: task.done,
                              onChanged: (value) async {
                                final isDone = value ?? false;
                                final wasDone = task.done;
                                final updatedTask = Task(
                                  id: task.id,
                                  title: task.title,
                                  deadline: task.deadline,
                                  priority: task.priority,
                                  done: isDone,
                                );
                                await TaskLocalDatabase.updateTask(updatedTask);
                                if (!wasDone && isDone) {
                                  await NotificationService.showTaskDoneNotification(task.title);
                                }
                                setState(() {

                                  _tasksFuture = loadTasksNoSync();
                                  counterUpdated = false;
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
                                if (updatedTask != null) {
                                  await TaskLocalDatabase.updateTask(
                                    updatedTask,
                                  );
                                  setState(() {
                                    _tasksFuture = loadTasksNoSync();
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
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
            await TaskLocalDatabase.addTask(newTask);

            setState(() {
              _tasksFuture = loadTasksNoSync();
              counterUpdated = false;
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> addTask(Task task) async {
    await TaskLocalDatabase.addTask(task);
    await loadTasks();
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
                  id: (DateTime.now().millisecondsSinceEpoch).toUnsigned(32),
                  //klucz musi pasować do uint32
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
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
    priorityController.text = taskToUpdate.priority;
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
                  id: taskToUpdate.id,

                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
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
