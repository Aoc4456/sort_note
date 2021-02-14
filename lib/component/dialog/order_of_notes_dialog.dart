import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sort_note/repository/shared_preference.dart';

/// ノートの表示順を設定するダイアログ
class OrderOfNotesDialog extends StatelessWidget {
  OrderOfNotesDialog(this.setting, this.selectCallback);

  final String setting;
  final Function selectCallback;

  @override
  Widget build(BuildContext context) {
    print(setting);
    final dialog = SimpleDialog(
      children: [
        OrderOfNotesDialogOption(setting, 'text ASC', '本文の昇順', selectCallback),
        OrderOfNotesDialogOption(setting, 'text DESC', '本文の降順', selectCallback),
        OrderOfNotesDialogOption(
            setting, 'createdAt DESC', '作成日の新しい順', selectCallback),
        OrderOfNotesDialogOption(
            setting, 'createdAt ASC', '作成日の古い順', selectCallback),
        OrderOfNotesDialogOption(
            setting, 'updatedAt DESC', '変更日の新しい順', selectCallback),
        OrderOfNotesDialogOption(
            setting, 'updatedAt ASC', '変更日の古い順', selectCallback),
      ],
    );
    return dialog;
  }
}

class OrderOfNotesDialogOption extends StatelessWidget {
  OrderOfNotesDialogOption(
      this.savedSetting, this.thisSetting, this.text, this.onPressed);

  final String savedSetting;
  final String thisSetting;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      child: Row(
        children: [
          Opacity(
            opacity: savedSetting == thisSetting ? 1 : 0,
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.blue,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(
            text,
            style: TextStyle(fontSize: 18),
          )),
        ],
      ),
      onPressed: () {
        saveOrderOfNotesSetting(thisSetting);
        onPressed();
      },
    );
  }
}

Future showOrderOfNotesDialog(
    BuildContext context, Function selectCallback) async {
  final setting = await getOrderOfNotesSetting();
  await showDialog(
      context: context,
      builder: (_) {
        return OrderOfNotesDialog(setting, selectCallback);
      });
}
