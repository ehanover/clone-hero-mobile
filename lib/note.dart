//import 'package:flame/game.dart';
import 'dart:math';
import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';
//import 'package:flame/animation.dart';
//import 'package:flame/components/animation_component.dart';
//import 'package:flame/util.dart';
import 'dart:ui';
//import 'main.dart';
import 'package:clone_hero_mobile/game.dart';
import 'package:flame/animation.dart' as flameAnimation;
import 'package:flame/position.dart';

class Note extends PositionComponent {

  static List<PaletteEntry> allColors = [ PaletteEntry(Color(0xFF00FF00)), PaletteEntry(Color(0xFFF00000)), PaletteEntry(Color(0xFFFFFF60)), PaletteEntry(Color(0xFF1020ff)), PaletteEntry(Color(0xFFFFa020)) ];
  static double noteSize = 40;
  static int noteDrawGap = 3;

  static double animScale = 2.3;

  int column;
  int start;
  int length;
  //int resolution;
  //double speed;
  PaletteEntry color;
  bool hit;
  bool dead;

  double x;
  double y;

  flameAnimation.Animation anim; // https://github.com/luanpotter/flame/blob/master/doc/images.md#Animation

  Note(int start, int column, int length, int resolution){ // TODO remove resolution

    //print("note(): $start. $column. $length. $speed.");

    this.start = start;
    this.column = column;
    this.color = allColors[column];
    this.length = length;
    this.hit = false;
    this.dead = false;
    //this.resolution = resolution;


    //this.speed = MyGame.noteSpeed.toDouble();
    width = noteSize;
    height = max(noteSize, this.length).toDouble();
    //height = noteSize/3;

    //this.x = (width+2)*this.column; // this isn't right
    this.x = (this.column*MyGame.columnWidth) + (MyGame.columnWidth-noteSize)/2;
    this.y = -height;

    flameAnimation.Animation a = flameAnimation.Animation.sequenced('noteanim_explode1.png', 3, textureWidth: 240.0, stepTime: 0.04);
    a.loop = false;
    this.anim = a;

  }

  @override
  void resize(Size size){
    print("Note resize() called");
  }

  @override
  void update(double t){
    if(dead){
      return;
    }

    if(hit){
      anim.update(t);

      if(anim.done())
        dead = true;

    } else {
      //y += speed * t;
      //y += this.resolution * MyGame.noteSpeed * t * 1000; // noteSpeed = pixels/beat?
      y += MyGame.noteSpeed * t * 1000;
      //y += MyGame.noteSpeed * (160 / t);

      if (y > MyGame.dimensions.height) {
        dead = true;
      }
    }
  }

  @override
  void render(Canvas c){
    if(hit){
      anim.currentFrame.sprite.renderCentered(c, Position(x+width/2, y+height), size:Position(noteSize*animScale, noteSize*animScale));
    } else {
      //c.drawCircle(Offset(x, y), noteSize.toDouble(), color.paint);
      c.drawRect(Rect.fromLTWH(x, y, width, height), color.paint);
      c.drawRect(Rect.fromLTWH(x + noteDrawGap, y + noteDrawGap, width - noteDrawGap * 2, height - noteDrawGap * 2), BasicPalette.black.paint);
    }
  }

}