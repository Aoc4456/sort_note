import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:sort_note/component/icon/folder_small_icon.dart';
import 'package:sort_note/model/folder.dart';
import 'package:sort_note/util/color.dart';

import 'folder_detail_model.dart';

final folderProvider = ChangeNotifierProvider((ref) => FolderDetailModel());

class FolderDetailPage extends HookWidget {
  FolderDetailPage({this.folder, this.defaultColor});

  final Folder folder;
  final Color defaultColor;

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(folderProvider)
      ..setFolder(folder)
      ..defaultColor = defaultColor;
    final myController = TextEditingController(text: provider.inputText);

    return WillPopScope(
      onWillPop: () {
        provider.clear();
        Navigator.of(context).pop();
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              folder == null ? '新規作成' : 'フォルダー編集',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getWhiteOrBlackByThemeColor(context)),
            ),
            iconTheme:
                IconThemeData(color: getWhiteOrBlackByThemeColor(context)),
            actions: [
              Visibility(
                visible: folder != null,
                child: IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      size: 35,
                      color: getWhiteOrBlackByThemeColor(context),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text('フォルダーを削除しますか？'),
                              content: Text(
                                  'このフォルダーと、フォルダー内のすべてのノートが削除されます。この操作は取り消せません。'),
                              actions: [
                                // ボタン領域
                                FlatButton(
                                  child: Text(
                                    "キャンセル",
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                FlatButton(
                                  child: Text(
                                    "削除",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    await provider.deleteFolder(folder);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });
                    }),
              )
            ],
          ),
          body: OrientationBuilder(
            builder: (context, orientation) {
              var orientation = MediaQuery.of(context).orientation;
              if (orientation == Orientation.portrait) {
                return SingleChildScrollView(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                    child: Center(
                        child: Column(
                      children: [
                        Hero(
                            tag: folder == null
                                ? ''
                                : 'folderSmallIcon${folder.id}',
                            child: FolderSmallIcon(
                              color: provider.color,
                              size: 200,
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                          child: TextFormField(
                            controller: myController,
                            textAlign: TextAlign.center,
                            onChanged: provider.changeText,
                            maxLines: 1,
                            decoration: folder != null
                                ? null
                                : InputDecoration(hintText: 'フォルダー名を入力'),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400.0),
                          child: ColorPicker(
                            pickersEnabled: {
                              ColorPickerType.both: false,
                              ColorPickerType.primary: true,
                              ColorPickerType.accent: false,
                              ColorPickerType.bw: false,
                              ColorPickerType.custom: false,
                              ColorPickerType.wheel: false
                            },
                            enableShadesSelection: false,
                            hasBorder: true,
                            padding: EdgeInsets.all(20),
                            color: provider.color,
                            onColorChanged: (Color color) {
                              print(colorToString(color));
                              provider.selectColor(color);
                            },
                            heading: Text(
                              'フォルダーの色を変更できます',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                        ),
                        RaisedButton(
                          child: Text(
                            '保存',
                            style: TextStyle(
                                color: getWhiteOrBlack(getThemeColor(context)),
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (provider.inputText == null ||
                                provider.inputText.isEmpty) {
                              showEmptyTextToast();
                            } else {
                              await provider.onTapSave();
                              provider.clear();
                              Navigator.pop(context);
                            }
                          },
                          color: getThemeColor(context),
                        ),
                      ],
                    )),
                  ),
                );
              } else {
                // 横画面
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Hero(
                                    tag: folder == null
                                        ? ''
                                        : 'folderSmallIcon${folder.id}',
                                    child: FolderSmallIcon(
                                      color: provider.color,
                                      size: 200,
                                    )),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: myController,
                                    textAlign: TextAlign.center,
                                    onChanged: provider.changeText,
                                    maxLines: 1,
                                    decoration: folder != null
                                        ? null
                                        : InputDecoration(
                                            hintText: 'フォルダー名を入力'),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 400.0),
                                    child: ColorPicker(
                                      pickersEnabled: {
                                        ColorPickerType.both: false,
                                        ColorPickerType.primary: true,
                                        ColorPickerType.accent: false,
                                        ColorPickerType.bw: false,
                                        ColorPickerType.custom: false,
                                        ColorPickerType.wheel: false
                                      },
                                      enableShadesSelection: false,
                                      hasBorder: true,
                                      padding: EdgeInsets.all(20),
                                      color: provider.color,
                                      onColorChanged: (Color color) {
                                        print(colorToString(color));
                                        provider.selectColor(color);
                                      },
                                      heading: Text(
                                        'フォルダーの色を変更できます',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  child: const Text(
                                    '保存',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    if (provider.inputText == null ||
                                        provider.inputText.isEmpty) {
                                      showEmptyTextToast();
                                    } else {
                                      await provider.onTapSave();
                                      provider.clear();
                                      Navigator.pop(context);
                                    }
                                  },
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          )),
    );
  }

  void showEmptyTextToast() {
    Fluttertoast.showToast(
        msg: "フォルダ名を入力して下さい",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
