import 'package:flutter/material.dart';
//import 'package:flame/util.dart';
import 'package:flame/flame.dart';
//import 'package:flame/game.dart';
//import 'package:flame/palette.dart';
//import 'package:flame/audio_pool.dart';
//import 'note.dart';
//import 'package:path_provider/path_provider.dart';
//import 'dart:io';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_document_picker/flutter_document_picker.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:clone_hero_mobile/menu.dart';


//void main() => runApp(MyGame().widget);
void main() async {
  Flame.images.load("noteanim_explode1.png");


  runApp(MainScreen());
}

