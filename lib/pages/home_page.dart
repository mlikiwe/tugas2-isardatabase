import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tugas2isardb/models/todo.dart';
import 'package:tugas2isardb/services/database_service.dart';
import 'package:tugas2isardb/utils/todo_list.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  List<Todo> toDoList = [];

  StreamSubscription? toDoListStream;

  @override
  void initState() {
    super.initState();
    DatabaseService.db.todos.buildQuery<Todo>().watch(fireImmediately: true).listen((data) {
      setState(() {
        toDoList = data;
      });
    });
  }

  @override
  void dispose() {
    toDoListStream?.cancel();
    super.dispose();
  }

  void checkBoxChanged(Todo? todo) {
      todo?.isCompleted = !todo.isCompleted;
      DatabaseService.db.writeTxn(() async {
        await DatabaseService.db.todos.put(todo!);
      });
  }

  void saveNewTask() async {
    if(_controller.text.isNotEmpty) {
      Todo newTodo = Todo();
      newTodo = Todo().copyWith(
        taskName: _controller.text,
      );
      await DatabaseService.db.writeTxn(() async {
        await DatabaseService.db.todos.put(newTodo);
      });
    }
  }

  void deleteTask(int index) async {
    await DatabaseService.db.writeTxn(() async {
      await DatabaseService.db.todos.delete(toDoList[index].id);
    });
  }

  void sortTasks() {
    toDoList.sort((a, b) => a.isCompleted ? 1 : -1);
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task', style: TextStyle(fontFamily: 'Poppins'),),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter task name', labelStyle: TextStyle(fontFamily: 'Poppins')),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: 'Poppins', fontSize: 15)),
              onPressed: () {
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(fontFamily: 'Poppins'),),
              onPressed: () {
                saveNewTask();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Todo? todo) {
    _controller.text = todo?.taskName ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task', style: TextStyle(fontFamily: 'Poppins'),),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter task name', labelStyle: TextStyle(fontFamily: 'Poppins')),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: 'Poppins', fontSize: 15)),
              onPressed: () {
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(fontFamily: 'Poppins'),),
              onPressed: () async {
                if (_controller.text.isNotEmpty && todo != null) {
                  Todo updatedTodo = todo.copyWith(taskName: _controller.text);
                  int index = toDoList.indexOf(todo);
                  setState(() {
                    toDoList[index] = updatedTodo;
                  });
                  await DatabaseService.db.writeTxn(() async {
                    await DatabaseService.db.todos.put(updatedTodo);
                  });
                }
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List uncompletedTasks = toDoList.where((task) => task.isCompleted == false).toList();
    List completedTasks = toDoList.where((task) => task.isCompleted == true).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 199, 149, 0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                  right: 20,
                  bottom: 0,
                ),
                child: Text(
                  'Uncompleted Tasks',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ...uncompletedTasks.map((task) {
            int index = toDoList.indexOf(task);
            return TodoList(
              taskName: task.taskName ?? '',
              taskCompleted: task.isCompleted,
              onChanged: (value) => checkBoxChanged(toDoList[index]),
              deleteFunction: (context) => deleteTask(index),
              editFunction: (context) => _showEditTaskDialog(toDoList[index]),
            );
          }).toList(),
            Padding(
              padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
                bottom: 0,
              ),
              child: Text(
                'Completed Tasks',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...completedTasks.map((task) {
            int index = toDoList.indexOf(task);
            return TodoList(
              taskName: task.taskName ?? '',
              taskCompleted: task.isCompleted,
              onChanged: (value) => checkBoxChanged(toDoList[index]),
              deleteFunction: (context) => deleteTask(index),
              editFunction: (context) => _showEditTaskDialog(toDoList[index]),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 199, 149, 0),
      ),
    );
  }
}