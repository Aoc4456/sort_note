import 'package:flutter/cupertino.dart';
import 'package:sort_note/model/folder.dart';
import 'package:sort_note/repository/database.dart';

// 2. モデルクラスで、ChangeNotifierを継承する
class FolderModel extends ChangeNotifier {
  var _folders = List<Folder>();
  List<Folder> get folders => _folders;

  var _noteCounts = Map<int, int>();
  Map<int, int> get noteCounts => _noteCounts;

  Future getFolders() async {
    _folders = await DBProvider.db.getAllFolders();
    return _folders;
  }

  Future getFoldersNotify() async {
    _folders = await DBProvider.db.getAllFolders();
    notifyListeners();
  }

  void addFolders(Folder folder) async {
    await DBProvider.db.insertFolder(folder);
    _folders = await DBProvider.db
        .getAllFolders(); // TODO ここ、データベースから取る必要はないかも？(フィールドに直接追加)
    notifyListeners();
  }

  void deleteFolder(int id, int priority) async {
    await DBProvider.db.deleteFolder(id.toString(), priority);
    _folders = await DBProvider.db.getAllFolders();
    notifyListeners();
  }

  Future<Map<int, int>> getNotesCount() async {
    _noteCounts = await DBProvider.db.getNotesCountByFolder();
    return _noteCounts;
  }

  void notifyNotesCount() async {
    _noteCounts = await DBProvider.db.getNotesCountByFolder();
    notifyListeners();
  }
}
