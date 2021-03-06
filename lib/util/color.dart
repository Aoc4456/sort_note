import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// アプリ全体
const defaultThemeColor = Color(0xff1995AD);

// アプリのテーマカラーを取得
Color getThemeColor(BuildContext context) {
  return Theme.of(context).primaryColor;
}

// Scaffoldの背景色を取得
Color getScaffoldColor(BuildContext context) {
  return Theme.of(context).scaffoldBackgroundColor;
}

// 与えられたカラーに対して、白か黒のうち、見やすい方の色を返す
Color getWhiteOrBlack(Color color) {
  return color.computeLuminance() > 0.65 ? Colors.black87 : Colors.white;
}

Color getWhiteOrBlackByThemeColor(BuildContext context) {
  return getWhiteOrBlack(getThemeColor(context));
}

/// フォルダーの色関連

class FolderGradientMask extends StatelessWidget {
  FolderGradientMask({this.child});

  final Icon child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment.topLeft,
        colors: [Colors.white, child.color],
        radius: 0.9,
        tileMode: TileMode.clamp,
      ).createShader(bounds),
      child: child,
    );
  }
}

const defaultFolderColor = Color(0xffffc107);

/// String -> Color への変換
/// @hexString : 6桁の16進数文字列
Color stringToColor(String hexString) {
  return Color(int.parse("0xff$hexString"));
}

/// 0fxx 付きのColor文字列をColorに変換する
Color rawStringToColor(String string) {
  return Color(int.parse(string));
}

/// Color -> 6桁の16進数への変換
/// 例：Color(0xffcddc39) -> cddc39　へ
String colorToString(Color color) {
  final rawColorString = color.toString();
  return rawColorString.substring(10, 16);
}

/// Color -> 10桁の16進数への変換
/// 例：Color(0xffcddc39) -> 0xffcddc39　へ
String rawColorToString(Color color) {
  final rawColorString = color.toString();
  return rawColorString.substring(6, 16);
}
