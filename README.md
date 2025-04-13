# Tugas 2 PPB C Implementasi Isar Database
| Name           | NRP        | Kelas     |
| ---            | ---        | ----------|
| Ivan Fairuz Adinata | 5025221167 | Pemrograman Perangkat Bergerak C |

Berikut ini merupakan langkah-langkah implementasi database Isar, dimulai dari instalasi, setup database, hingga mengaplikasikannya ke project flutter sehingga CRUD dapat berjalan dengan baik. Untuk memudahkan pembuatan UI, kita akan menggunakan project simple CRUD sebelumnya sehingga nantinya kita tinggal mengganti pendekatannya dari List ke Database.

## Clone Flutter Project
Link Github : https://github.com/mlikiwe/ppb-simplecrudtugas1.git

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

## Link Sumber
- isar : https://pub.dev/packages/isar
- path_provider : https://pub.dev/packages/path_provider
- Isar Quickstart : https://isar.dev/tutorials/quickstart.html
