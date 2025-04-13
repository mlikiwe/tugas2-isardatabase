import 'package:isar/isar.dart';

part 'todo.g.dart';

@Collection()
class Todo {
  Id id = Isar.autoIncrement;

  String? taskName;

  bool isCompleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updateAt = DateTime.now();

  Todo copyWith({String? taskName}) {
    return Todo()
      ..id = id
      ..taskName = taskName ?? this.taskName
      ..isCompleted = isCompleted
      ..createdAt = createdAt
      ..updateAt = DateTime.now();
  }
}