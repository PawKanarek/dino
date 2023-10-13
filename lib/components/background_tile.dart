import 'dart:async';

import 'package:dino/consts.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;
  BackgroundTile({
    this.color = "Gray",
    super.position,
  });

  @override
  FutureOr<void> onLoad() async {
    priority = -9999;
    size = Vector2.all(Consts.bgTileSize);
    parallax = await game.loadParallax(
      [ParallaxImageData("Background/$color.png")],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );
  }

  final double scrollSpeed = 20;
}
