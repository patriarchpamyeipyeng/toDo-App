import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// App entry point
void main() {
  runApp(const TodoApp());
}

// Root widget
class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

 class _TodoAppState extends State<TodoApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',

      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: isDarkMode
            ? Colors.black
            : const Color(0xFFF3F6FF),
      ),

      home: DashboardPage(
        toggleTheme: toggleTheme,
      ),
    );
  }
}

// ---------------- DASHBOARD PAGE ----------------
class DashboardPage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const DashboardPage({
    super.key,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
  alignment: Alignment.topRight,
  child: IconButton(
    icon: const Icon(Icons.dark_mode),
    onPressed: toggleTheme,
  ),
),
                const Icon(
                  Icons.task_alt,
                  size: 120,
                  color: Colors.indigo,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Stay productive and organized.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TodoHomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Open Tasks',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- TODO PAGE ----------------
class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  // Input controller
  final TextEditingController controller = TextEditingController();

  // Stores all tasks
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    clearTasks();
    loadTasks();
    
  }
  Future<void> clearTasks() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('tasks');
}

  // Add task
  void addTask() {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        tasks.add({
          'title': controller.text.trim(),
          'done': false,
          'date': DateTime.now().toString(),
        });
      });

      controller.clear();
      saveTasks();
    }
  }

  // Mark complete
  void toggleTask(int index) {
    setState(() {
      tasks[index]['done'] = !tasks[index]['done'];
    });

    saveTasks();
  }

  // Delete task
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });

    saveTasks();
  }

  // Edit task
  void editTask(int index) {
    controller.text = tasks[index]['title'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                tasks[index]['title'] = controller.text;
              });

              controller.clear();
              saveTasks();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Save tasks locally
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  // Load saved tasks
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedTasks = prefs.getString('tasks');

    if (savedTasks != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(
          jsonDecode(savedTasks),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks (${tasks.length})'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // Task input
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),

                          child: Card(
                            child: ListTile(
                              // Checkbox
                              leading: Checkbox(
                                value: tasks[index]['done'],
                                onChanged: (_) => toggleTask(index),
                              ),

                              // Task name
                              title: Text(
                                tasks[index]['title'],
                                style: TextStyle(
                                  decoration: tasks[index]['done']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),

                              // Due date
                   subtitle: Text(
  tasks[index]['date'] != null
      ? tasks[index]['date'].toString().split(' ')[0]
      : 'No date',
),

                              // Edit + Delete buttons
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => editTask(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        deleteTask(index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}