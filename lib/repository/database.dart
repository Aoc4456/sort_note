import 'package:path/path.dart';
import 'package:sort_note/model/folder.dart';
import 'package:sort_note/model/note.dart';
import 'package:sort_note/repository/shared_preference.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  static final _folderTableName = "folders";
  static final _noteTableName = "notes";

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDB();
      return _database;
    }
  }

  Future<Database> initDB() async {
    return await openDatabase(
        join(await getDatabasesPath(), 'sort_note_database.db'),
        onCreate: (db, version) async {
      await db.execute("CREATE TABLE folders("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "title TEXT, "
          "color TEXT,"
          "priority INTEGER)");
      await db.execute("CREATE TABLE notes("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "text TEXT, "
          "createdAt TEXT, "
          "updatedAt TEXT, "
          "folderId INTEGER, "
          "FOREIGN KEY(folderId) REFERENCES folders(id))");
    }, version: 1);
  }

  /**
   * フォルダーテーブル用　関数
   */

  /// 全てのフォルダーを取得
  Future<List<Folder>> getAllFolders() async {
    final db = await database;
    final List<Map<String, dynamic>> folders =
        await db.query(_folderTableName, orderBy: "priority ASC");
    return folders.map((folder) => Folder().fromMap(folder)).toList();
  }

  /// フォルダーを一件追加
  Future insertFolder(Folder folder) async {
    final db = await database;
    // db.insert の戻り値として、最後に挿入された行のIDを返す (今回は受け取らない)
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> priorityList =
          await txn.rawQuery('SELECT MAX(priority) FROM folders');
      final maxPriority = priorityList.first['MAX(priority)'];
      final newPriority = maxPriority == null ? 0 : maxPriority + 1;
      final newFolder = Folder(
          title: folder.title, color: folder.color, priority: newPriority);
      await txn.insert(_folderTableName, newFolder.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  // フォルダーを更新
  Future updateFolder(Folder folder) async {
    final db = await database;
    await db.update(_folderTableName, folder.toMap(),
        where: "id = ?", whereArgs: [folder.id]);
  }

  /// フォルダーを一件削除
  Future deleteFolder(String id, int priority) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_folderTableName, where: "id = ?", whereArgs: [id]);
      await txn.delete(_noteTableName, where: "folderId = ?", whereArgs: [id]);
      await txn.rawQuery(
          'UPDATE folders SET priority = priority - 1 WHERE priority > ?',
          [priority]);
    });
  }

  /// テーブル内で一番大きいpriorityを取得する
  Future getMaxPriority() async {
    final db = await database;
    return db.rawQuery('SELECT MAX priority FROM folders');
  }

  /**
   * フォルダー並び替え用
   */

  /// 範囲内のpriority を + 1 する
  Future incrementPriorityInRange(int from, int to) async {
    final db = await database;
    await db.rawQuery(
        'UPDATE folders SET priority = priority + 1 WHERE priority >= ? AND priority <= ?',
        [from, to]);
  }

  /// 範囲内のpriority を - 1 する
  Future decrementPriorityInRange(int from, int to) async {
    final db = await database;
    await db.rawQuery(
        'UPDATE folders SET priority = priority - 1 WHERE priority >= ? AND priority <= ?',
        [from, to]);
  }

  /// 指定のidのpriorityを更新する
  Future updatePriority(int id, int priority) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE folders SET priority = ? WHERE id = ?', [id, priority]);
  }

  /// ドラッグ & ドロップで位置を変えたとき
  Future onDragAndDrop(int id, int from, int to) async {
    final db = await database;
    if (from < to) {
      from = from + 1;
      db.transaction((txn) async {
        await txn.rawQuery(
            'UPDATE folders SET priority = priority - 1 WHERE priority >= ? AND priority <= ?',
            [from, to]);
        await txn.rawUpdate(
            'UPDATE folders SET priority = ? WHERE id = ?', [to, id]);
      });
    } else {
      final rangeFrom = to;
      final rangeTo = from - 1;
      db.transaction((txn) async {
        await txn.rawQuery(
            'UPDATE folders SET priority = priority + 1 WHERE priority >= ? AND priority <= ?',
            [rangeFrom, rangeTo]);
        await txn.rawUpdate(
            'UPDATE folders SET priority = ? WHERE id = ?', [to, id]);
      });
    }
  }

  /**
   * ノート テーブル用関数
   */

  /// そのフォルダ内の全てのノートを取得
  Future<List<Note>> getNotesInFolder(int folderId) async {
    final orderBySetting = await getOrderOfNotesSetting();
    final db = await database;
    final List<Map<String, dynamic>> notes = await db.query(_noteTableName,
        where: 'folderId = ?', whereArgs: [folderId], orderBy: orderBySetting);
    return notes.map((note) => Note().fromMap(note)).toList();
  }

  /// ノートを一件追加
  Future<int> insertNote(Note note) async {
    final db = await database;
    // db.insert の戻り値として、最後に挿入された行のIDを返す
    return await db.insert(_noteTableName, note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// ノートを一件更新
  Future updateNote(Note note) async {
    final db = await database;
    await db.update(_noteTableName, note.toMap(),
        where: "id = ?", whereArgs: [note.id]);
  }

  /// ノートを一件削除
  Future deleteNote(String id) async {
    final db = await database;
    await db.delete(_noteTableName, where: "id = ?", whereArgs: [id]);
  }

  // ノートの所属するフォルダーを変更
  Future moveAnotherFolder(int noteId, int newFolderId) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE notes SET folderId = ? WHERE id = ?', [newFolderId, noteId]);
  }

  // 複数のノートの、所属するフォルダーを一度に変更
  Future moveAnotherFolderMultipleNotes(
      List<int> noteIds, int newFolderId) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE notes SET folderId = ? WHERE id IN (${noteIds.join(', ')})',
        [newFolderId]);
  }

  // 複数のノートを一度に削除
  Future deleteMultipleNotes(List<int> noteIds) async {
    final db = await database;
    await db.rawDelete('DELETE FROM notes WHERE id IN (${noteIds.join(', ')})');
  }

  // フォルダーごとのノートの数を取得
  Future<Map<int, int>> getNotesCountByFolder() async {
    final db = await database;
    // テーブル全体
    final List<Map<String, dynamic>> notesCount = await db.rawQuery(
        'SELECT folderId, COUNT(*) from notes GROUP BY folderId order by folderId asc');
    Map<int, int> countMap = {};
    notesCount.forEach((count) {
      int folderId = count['folderId'];
      int notesCount = count['COUNT(*)'];
      countMap[folderId] = notesCount;
    });
    return countMap;
  }
}
