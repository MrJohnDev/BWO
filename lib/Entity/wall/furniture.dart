import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/preload_assets.dart';
import '../../utils/sprite_controller.dart';
import '../Entity.dart';

class Furniture extends Entity {
  Sprite sprite;
  Sprite currentSprite;
  String imageId;
  final double zoom = 1;

  bool showLow = false;
  bool showCollisionBox = false;

  double width, height;

  Furniture(
      double newPosX, double newPosY, this.width, this.height, this.imageId)
      : super(newPosX.floor() * 16.0 + 8, (newPosY.ceil() + 1) * 16.0) {
    loadSprite();

    shadownSize = 1;
    //shadownLarge = PreloadAssets.getEffectSprite('shadown_square');
    shadownLarge = null;
    shadownOffset = Offset(0, 14);

    id = '_${newPosX.floor()}_${posY.ceil() + 1}';

    width *= 16;
    height *= 16;
    collisionBox = Rect.fromLTWH(x - 8, y - 16, width, height);
  }

  void loadSprite() {
    sprite = PreloadAssets.getFurnitureSprite(imageId);
    currentSprite = sprite;
    //sprite = await Sprite.loadSprite('walls/$_imgPath');
    //lowSprite = await Sprite.loadSprite('walls/low_$_imgPath');
  }

  void draw(Canvas c) {
    if (currentSprite == null) return;
    if (currentSprite.src == null) return;
    // Or originalSize
    var pivot =
        Offset((zoom * 16) / 2, (currentSprite.srcSize.y * 2) - height + 16);

    currentSprite.render(c,
        position: Vector2(x - pivot.dx, y - pivot.dy - z),
        size: Vector2.all(SpriteController.spriteSize * 2));

    //showCollisionBox = true;
    showCollisionBox ? debugDraw(c) : null;
  }

  bool isInside(int pointX, int pointY) {
    return pointX >= posX &&
        pointX < (posX + width ~/ 16) &&
        pointY >= posY - 1 &&
        pointY < (posY - 1 + height ~/ 16);
  }

  bool isIntersecting(
      double pointX, double pointY, double wPoint, double hPoint) {
    var r1 = Rectangle(
      pointX.floorToDouble() + 0.1,
      pointY.floorToDouble(),
      wPoint - 0.2,
      hPoint,
    );
    var r2 = Rectangle(
      posX.toDouble(),
      posY.toDouble() - 1,
      (width / 16),
      (height / 16) - 1,
    );

    return r1.intersects(r2);
  }

  @override
  String toString() {
    return """id:$imageId, x:$posX y:$posY""";
  }

  dynamic toObject() {
    return {
      'id': imageId,
      'x': posX,
      'y': posY - 1,
      'w': width / 16,
      'h': height / 16
    };
  }
}
