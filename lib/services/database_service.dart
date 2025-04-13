import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tugas2isardb/models/todo.dart';

class DatabaseService {
  static late final Isar db;
  static Future<void> setup() async {
    final appDir = await getApplicationDocumentsDirectory();
    db = await Isar.open(
      [TodoSchema],
      directory: appDir.path,
    );
  }
}