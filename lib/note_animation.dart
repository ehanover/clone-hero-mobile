import 'package:flutter/material.dart';
//import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as flameAnimation;
//import 'package:flame/components/animation_component.dart';
//import 'package:flame/game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/position.dart';

class NoteAnimation extends PositionComponent {
//class NoteAnimation extends AnimationComponent {

  flameAnimation.Animation anim;
  bool dead;

  NoteAnimation(double tx, double ty){
    //List<Sprite> sprites = [0, 1, 2].map((i) => new Sprite('player_${i}.png')).toList();
    //this.player = new AnimationComponent(64.0, 64.0, new Animation.spriteList(sprites, stepTime: 0.01));=

    flameAnimation.Animation a = flameAnimation.Animation.sequenced('noteanim_explode1.png', 3, textureWidth: 240.0, stepTime: 0.1);
    a.loop = false;
    this.anim = a;
    this.dead = false;

    this.x = tx;
    this.y = ty;

    this.width = 10;
    this.height = 10;
  }

  @override
  void resize(Size size){
    print("NoteAnimation resize() called");
  }

  @override
  void update(double dt){
    //super.update(dt);
    anim.update(dt);

    if(anim.done()) {
      this.dead = true;
      this.destroy();
    }

  }

  @override
  void render(Canvas c){
    if(this.dead)
      return;

    anim.currentFrame.sprite.renderCentered(c, Position(this.x, this.y));
  }


}