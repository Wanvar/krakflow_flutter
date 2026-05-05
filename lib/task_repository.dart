class Task {
  final String title;
  final String deadline;
  bool done;
  final Priority priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}
enum Priority { Low, Medium, High }

Priority strToPriority(String str) {
  switch (str) {
    case "niski":
      return Priority.Low;
    case "średni":
      return Priority.Medium;
    case "wysoki":
      return Priority.High;
    default:
      return Priority.Low;
  }
}

String priorityToStr(Priority priority) {
  switch (priority) {
    case Priority.Low:
      return "niski";
    case Priority.Medium:
      return "średni";
    case Priority.High:
      return "wysoki";
    default:
      return "niski";
  }
}

class TaskRepository {
  static List<Task> tasks = [
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


}