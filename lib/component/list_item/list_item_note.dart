import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListItemNote extends StatelessWidget {
  ListItemNote({this.text, this.onTapCallback, this.onLongPressCallback});

  final String text;
  final Function() onTapCallback;
  final Function() onLongPressCallback;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text.split("\n").first,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        maxLines: 1,
      ),
      trailing: Icon(Icons.navigate_next),
      onTap: () {
        onTapCallback();
      },
      onLongPress: () {
        onLongPressCallback();
      },
    );
  }
}
