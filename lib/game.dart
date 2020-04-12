import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/text_config.dart';
import 'package:flame/position.dart';
//import 'package:flame/anchor.dart';
import 'package:flutter/gestures.dart';
//import 'package:flame/util.dart';
import 'package:flame/palette.dart';
//import 'package:flame/audio_pool.dart';
import 'note.dart';
import 'dart:core';
//import 'note_animation.dart';
//import 'package:path_provider/path_provider.dart';
//import 'dart:io';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_document_picker/flutter_document_picker.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
//import 'package:clone_hero_mobile/menu.dart';


class MyGame extends BaseGame { // https://blog.geekyants.com/building-a-2d-game-in-flutter-a-comprehensive-guide-913f647846bc

  static int searchAmount = 8;
  static int targetFPS = 30;
  static Size dimensions;
  static double heightBeats;
  //static int targetOffset = 120;
  static int targetBuffer = 60; // wiggle room around the target line, in pixels
  static int targetHeight;
  static double targetBeats;
  //static double startOffsetTargetDist;
  //static double startOffsetMusic;
  //static double songSpeedMultiplier;
  static double noteSpeed; // beats per ms
  static int columnWidth;
  static PaletteEntry lineColor = PaletteEntry(Color(0x802d2d2d));

  //TextConfig config = TextConfig(fontSize: 48.0, fontFamily: 'Awesome Font', anchor: Anchor.rightBottom);
  TextConfig config = TextConfig(fontSize: 16.0, fontFamily: 'Awesome Font', color: Colors.white);

  //int startTime;
  //int lastMs = -1;
  double beatsSince = 0;
  List<Note> screenNotes;
  List<Note> allNotes;
  List<List<int>> tempoChanges;
  List<List<int>> timeChanges;
  int resolution;
  int lastNoteIndex = 0;
  int lastTempoIndex = 0;
  int lastTimechangeIndex = 0;
  double lastMspb;
  int lastTimechange;

  int score = 0;
  int misses = 0;
  //double maxSSMAChange = 0.003;
  //double songSpeedMultiplierAdaptive = 1.0;
  //bool startTimeHasBeenUpdated = false;

  MyGame(List<String> as, List<Note> an, List<List<int>> teC, List<List<int>> tiC, int res, int off){
    this.screenNotes = List<Note>();
    this.allNotes = an;
    this.tempoChanges = teC;
    this.timeChanges = tiC;
    this.resolution = res;
    //this.offset = off;

    lastMspb = bpmToMspb(tempoChanges[0][1]);
    lastTimechange = timeChanges[0][1];

    //this.noteIndex = 0;

    Flame.util.addGestureRecognizer(new MultiTapGestureRecognizer()..onTapDown = (int count, TapDownDetails evt) => handleInput(count, evt));

    AudioPlayer.logEnabled = false;
//    Flame.audio.loadAll(as);
    for(String s in as){
//      Flame.audio.play(s);
//      AudioPlayer ap = new AudioPlayer(mode: PlayerMode.LOW_LATENCY); // only in newer versions of the package
//      ap.play(s);
      new AudioPlayer().play(s, isLocal: false); // TODO is low_latency better? does it work with .ogg files? mode: PlayerMode.LOW_LATENCY
    }
    //this.startTime = DateTime.now().millisecondsSinceEpoch;

  }

  @override
  void update(double t){
    super.update(t);

    //int currentMs = DateTime.now().millisecondsSinceEpoch;

//    if(lastMs == -1){
//      lastMs = currentMs;
//    }
    //int deltaTime = currentMs - lastMs; // (DateTime.now().millisecondsSinceEpoch - startTime)*1.0; //*songSpeedMultiplier;

    double deltaTime = t*1000; // convert seconds to milliseconds
    double deltaBeats = deltaTime * (1.0/lastMspb) * resolution;
    beatsSince += deltaBeats;

    if(lastTimechangeIndex < timeChanges.length-1 && timeChanges[lastTimechangeIndex+1][0] <= beatsSince){
      lastTimechangeIndex += 1;
      lastTimechange = timeChanges[lastTimechangeIndex][1];
      print("changing to time signature #$lastTimechangeIndex");
    }
    if(lastTempoIndex < tempoChanges.length-1 && tempoChanges[lastTempoIndex+1][0] <= beatsSince){
      lastTempoIndex += 1;
      lastMspb = bpmToMspb(tempoChanges[lastTempoIndex][1]);
      print("changing to tempo #$lastTempoIndex");
    }

    //int notesAdded = 0;
    for(int i=0; i<searchAmount; i++){
      int searchIndex = lastNoteIndex + i;
      if(searchIndex >= allNotes.length+searchAmount){
        searchAmount = 0;
        print("song is over.");
        break;
      }
      Note n = allNotes[searchIndex];
      if(n.start <= beatsSince+targetBeats){
        screenNotes.add(n);
        lastNoteIndex++;
        //print("+adding a note");
      }
    }

    List<Note> notesToRemove = List<Note>();
    for(Note n in screenNotes){
      n.update(t);

      if(n.dead){
        notesToRemove.add(n);
        if(n.hit == false) // this one ran off the screen
          misses += 1;
      }
    }
    for(Note n in notesToRemove){
      screenNotes.remove(n);
    }

    //lastNoteIndex += notesAdded;
    //lastMs = DateTime.now().millisecondsSinceEpoch;
    //print("len notes: ${screenNotes.length}");
  }

  @override
  void render(Canvas c){
    super.render(c);

    for(int i=0; i<5; i++){ // column divider lines
      c.drawRect(Rect.fromLTWH(i*columnWidth.toDouble()-1, 0, 1, dimensions.height), lineColor.paint);
    }
    c.drawRect(Rect.fromLTWH(0, targetHeight.toDouble(), dimensions.width, 3), lineColor.paint);
    c.drawRect(Rect.fromLTWH(0, targetHeight.toDouble()-targetBuffer, dimensions.width, 1), lineColor.paint);
    c.drawRect(Rect.fromLTWH(0, targetHeight.toDouble()+targetBuffer, dimensions.width, -1), lineColor.paint);

    config.render(c, "Hits: $score\nMisses: $misses", Position(10,10));

    for(Note n in screenNotes){
      n.render(c);
    }
  }

  double bpmToMspb(int bpm){
    return 1000000.0/(bpm/60.0);
  }

  void handleInput(int count, TapDownDetails tap){
    double x = tap.globalPosition.dx;
    //double y = tap.globalPosition.dy;
    int column = ( (x/dimensions.width)*5 ).toInt();
    //print("@got a tap at ($x/${dimensions.width}, $y/${dimensions.height}) column: $column");

    for(Note n in screenNotes){
      if(n.hit == false && n.column == column && n.y+n.height > targetHeight-targetBuffer){
        n.hit = true;
        score += 1;

//        double difference = (n.y+n.height) - (targetHeight);
//        double differenceRatio = (difference/targetBuffer).abs();

//        if(difference < 0){ // hit too early (above target)
//          songSpeedMultiplierAdaptive *= (1+maxSSMAChange*differenceRatio);
//        } else { // hit too late
//          songSpeedMultiplierAdaptive *= (1-maxSSMAChange*differenceRatio);
//        }

        return;
        //print("@deleting a note");
      }
    }
    misses += 1;

  }





}

