import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sort_note/util/color.dart';

class FolderSmallIcon extends StatelessWidget {
  FolderSmallIcon({this.enable = true});

  final bool enable;

  @override
  Widget build(BuildContext context) {
    return FolderGradientMask(
      child: Icon(
        Icons.folder_sharp,
        color: enable ? Colors.yellow[600] : Colors.grey,
      ),
    );
  }
}
