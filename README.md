# Tugas 2 PPB C Implementasi Isar Database
| Name           | NRP        | Kelas     |
| ---            | ---        | ----------|
| Ivan Fairuz Adinata | 5025221167 | Pemrograman Perangkat Bergerak C |

Berikut ini merupakan langkah-langkah implementasi database Isar, dimulai dari instalasi, setup database, hingga mengaplikasikannya ke project flutter sehingga CRUD dapat berjalan dengan baik. Untuk memudahkan pembuatan UI, kita akan menggunakan project simple CRUD sebelumnya sehingga nantinya kita tinggal mengganti pendekatannya dari List ke Database.

## Clone Flutter Project
Link Github : https://github.com/mlikiwe/ppb-simplecrudtugas1.git  
Di project tersebut, telah terdapat fungsi CRUD dengan memanfaatkan list untuk melakukan To do List. Terdapat tiga file utama, yakni `main.dart`, `home_page.dart`, dan `todo_list.dart`. File `home_page.dart` akan memuat halaman utama kita, di mana di dalamnya terdapat method atau fungsi-fungsi dan widget yang membangun fungsionalitas dari suatu aplikasi to do list. Sementara itu, file `todo_list.dart` bisa dibilang adalah sebuah card untuk menampilkan sebuah item task beserta fitur-fitur di dalamnya, seperti edit, delete, dan mark as completed.

## Instalasi Isar DB
Kita memerlukan instalasi Isar Database di dalam project kita. Caranya cukup simple, kita hanya perlu untuk memasukkan dependencies nya kedalam `pubspec.yaml`. Pertama, kita dapat mengunjungi website Isar (seluruh link telah tersedia di paling bawah). Klik icon copy yang berada di samping headline ataupun dapat langsung ketik manual `isar: ^3.1.0+1`. 

Selain itu, kita memerlukan path provider yang juga dapat dikunjungi pada link di bawah. Path provider nantinya berfungsi untuk memberikan path direktori lokal perangkat tempat file bisa disimpan secara aman oleh aplikasi. Selain kedua dependencies di atas, kita juga perlu menambahkan `isar_flutter_libs`, `isar_generator`, dan `build_runner`. Khusus untuk `isar_generator` dan `build_runner`, kita harus tempatkan keduanya di bagian `dev_dependencies`. Kita juga harus menyesuaikan versi dari `isar_flutter_libs`, `isar_generator`, dan `build_runner` sesuai dengan versi isar, sebagai contoh adalah versi 3.1.0+1. Berikut merupakan tampilan akhir dari pubspec.yaml di project kita
``` yaml
...
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.5
  flutter_slidable: ^3.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter


  flutter_lints: ^5.0.0
  isar_generator: ^3.1.0+1
  build_runner: any
...
```

## Setup Database
Setelah selesai dengan dependencies, kita perlu membuat model/schema kita untuk mendefinisikan database milik kita nantinya. Dikarenakan Isar merupakan database nosql, maka kita akan membuat yang namanya Collection. Collection ini dapat kita anggap sebagai tabel apabila kita menggunakan MySQL dan database SQL lainnya. 
Pertama, kita buat folder baru yakni `models` yang di dalamnya terdapat file `todo.dart`

Pertama, kita akan membuat kelas, yaitu Todo yang akan menjadi schema kita. Agar Isar tahu bahwa class Todo merupakan collection, maka kita harus menambahkan `@Collection` tepat di atas class Todo. Kita juga perlu melakukan `import 'package:isar/isar.dart';`. Berikut merupakan tampilan awalnya.
``` dart
import 'package:isar/isar.dart';

@Collection()
class Todo {}

```
Di dalam class Todo, kita akan mendefinisikan atribut apa saja yang nantinya dibutuhkan. Dalam kasus ini, kita memerlukan `id`, `taskName`, dan`isCompleted`. Selain itu, kita bisa juga menambahkan `created_at` dan `updated_at`. Tambahkan seluruhnya ke dalam class Todo sehingga class Todo akan seperti ini
``` dart
class Todo {
  Id id = Isar.autoIncrement;

  String? taskName;

  bool isCompleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updateAt = DateTime.now();
}
```
Masing-masing atribut juga perlu kita definisikan tipe datanya seperti di atas. Untuk id, kita set `autoincrement` sehingga apabila kita menambahkan suatu task, maka id nya akan langsung terisi otomatis. Selain itu, kita set juga nilai isCompleted sebagai false karena saat tugas yang kita tambahkan pasti belum selesai.

Selanjutnya, tambahkan baris kode berikut di atas class Todo
``` dart
part 'todo.g.dart';
```
Baris kode tersebut berfungsi agar schema yang sudah kita buat, ketika di build akan disimpan kedalam file todo.g.dart sehingga kita nanti dapat berinteraksi dengannya.

## Run Code Generator
Jalankan perintah di bawah ini di terminal
``` bash
flutter pub run build_runner build
```
Perintah tersebut akan melakukan build schema kita dan akan menghasilkan file todo.g.dart yang didalamnya berisi detail tentang schema kita.

## Create Database Service
Di sini kita akan membauat static class untuk dapat berinteraksi dengan database kita. Pertama kita create folder baru di dalam folder libs yakni `services` dan didalamnya akan ditambahkan file `database_service.dart`. Tambahkan kode berikut
```dart
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
```
Kelas ini memiliki method yang bertanggung jawab untuk mengatur koneksi ke database Isar kita. Di sini, kita memanfaatkan `getApplicationDocumentsDirectory()` dari `path_provider` untuk mendapatkan direktori data aplikasi kita. Setelah database berhasil dibuka, ia disimpan dalam variabel statis `db`, sehingga dapat diakses tanpa perlu membuka koneksi berulang kali.

Untuk menggunakannya, tambahkan kode berikut di file `main.dart`.
```dart
...
void main() async {
  await setup();
  runApp(const MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.setup();
}
...
```
Di main, kita akan memanggil fungsi setup uang tadi kita telah buat. Sekarang, setup Isar database sudah selesai. Kita tinggal mengimplementasikannya ke fungsi CRUD di home_page kita.

## Implementasi Database Isar
Kita akan menggunakan fitur CRUD dari Isar yakni put dan delete. Kita akan hanya melakukan modifikasi di bagian file `home_page.dart` saja karena di sana terdapat method-method untuk kebutuhan CRUD.

Sebelum itu, sebelum kita tampilkan, data dari database akan disimpan di suatu list. Hapus List yang lama lalu buat list kosong bertipe Todo `List<Todo> toDoList = [];`. Lalu, kita akan melakukan fetch data dari database dengan pendekatan yang sedikit advance, yaitu dengan `watch` agar task kita selalu update otomatis. Buat fungsi `initState` yang di dalamnya terdapat kode berikut
``` dart
@override
  void initState() {
    super.initState();
    DatabaseService.db.todos.buildQuery<Todo>().watch(fireImmediately: true).listen((data) {
      setState(() {
        toDoList = data;
      });
    });
  }
```
Setiap ada perubahan database, fungsi `setState` akan memberi tahu flutter dan akan melakukan build ulang widget dengan data terbaru.

### Method `copyWith`
Tambahkan kode di bawah ini di bawah deklarasi atribut kita di `models/todo.dart`:
``` dart
Todo copyWith({String? taskName}) {
  return Todo()
    ..id = id
    ..taskName = taskName ?? this.taskName
    ..isCompleted = isCompleted
    ..createdAt = createdAt
    ..updateAt = DateTime.now();
}
```

### Modifikasi Method `saveNewTask`
Apabila kita lihat di Widget build paling bawah, widget Floating Action Button akan memanggil method `_showAddTaskDialog`. Kita lihat lagi, di method `_showAddTaskDialog` akan memanggil method `saveNewTask` ketika kita klik Save. Di method `saveNewTask`, kita akan mengganti isinya baris kode berikut:
``` dart
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
```
`if(_controller.text.isNotEmpty) {...}` Cek apakah controller text tidak empty\
`Todo newTodo = Todo();` Membuat objek Todo baru bernama newTodo\
`newTodo = Todo().copyWith(taskName: _controller.text,);` Masukkan controller text ke atribut `taskName` lalu masukkan ke objek newTodo dengan copyWith.\
`await DatabaseService.db.writeTxn(() async {await DatabaseService.db.todos.put(newTodo);});` Lakukan penulisan ke database dengan put

### Modifikasi Method `_showEditTaskDialog`
Method ini berfungsin untuk melakukan edit. Edit/Update di Isar memiliki satu fungsi yang sama yakni put, konsepnya, apabila index atau id dari item yang akan diedit null, maka akan dilakukan insert. Sedangkan, apabila id nya tidak null, maka akan dilakukan update.

Kita akan memodifikasi di bagian `onPressed` dari button save. Sebelumnya, ganti parameter method menjadi `(Todo? todo)`. Tambahkan baris kode `_controller.text = todo?.taskName ?? '';` di bagian paling atas fungsi. Lalu, ganti isi dari onPressed menjadi kode berikut:
``` dart
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
```
`if (_controller.text.isNotEmpty && todo != null)` Cek apakah controller text tidak empty dan todo juga tidak empty\
`Todo updatedTodo = todo.copyWith(taskName: _controller.text)` Membuat objek Todo dan mengisi atribut taskName dengan isi dari controler.text.\
`int index = toDoList.indexOf(todo)` Memperbarui index di List\
`setState(() {toDoList[index] = updatedTodo;})` Memperbarui List\
`await DatabaseService.db.writeTxn(() async {await DatabaseService.db.todos.put(updatedTodo);})` Simpan perubahannya pada database

### Modifikasi Method `deleteTask`
Ganti isi dari fungsi deleteTask menjadi kode berikut:
```dart
  void deleteTask(int index) async {
    await DatabaseService.db.writeTxn(() async {
      await DatabaseService.db.todos.delete(toDoList[index].id);
    });
  }
```
Kita akan memanfaatkan method delete dari isar untuk menghapus task dengan parameter index atau id dari task tersebut.

### Modifikasi Method Pendukung Lainnya
```dart
  void checkBoxChanged(Todo? todo) {
      todo?.isCompleted = !todo.isCompleted;
      DatabaseService.db.writeTxn(() async {
        await DatabaseService.db.todos.put(todo!);
      });
  }
```
Dengan method di atas, value dari boolean isCompleted akan otomatis berubah dari yang awalnya false ke true atau sebaliknya

``` dart
void sortTasks() {
    toDoList.sort((a, b) => a.isCompleted ? 1 : -1);
  }
```
Kita hanya perlu mengubah yang awalnya `a[1]` menggunakan indexing, kita ganti menjadi `a.isCompleted`

``` dart
    List uncompletedTasks = toDoList.where((task) => task.isCompleted == false).toList();
    List completedTasks = toDoList.where((task) => task.isCompleted == true).toList();
```
Ganti juga di bagian filter untuk List uncompleted dan completed sehingga seperti di atas.

``` dart
  return TodoList(
    taskName: task.taskName ?? '',
    taskCompleted: task.isCompleted,
    onChanged: (value) => checkBoxChanged(toDoList[index]),
    deleteFunction: (context) => deleteTask(index),
    editFunction: (context) => _showEditTaskDialog(toDoList[index]),
  );
```
Pada return value TodoList, sesuaikan parameter pada masing-masing fungsi yang telah kita edit sebelumnya. Lakukan untuk `uncompletedTask` dan `completedTask`

## Link Sumber
- isar : https://pub.dev/packages/isar
- path_provider : https://pub.dev/packages/path_provider
- Isar Quickstart : https://isar.dev/tutorials/quickstart.html
