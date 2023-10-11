import 'dart:async';

import 'package:dino/consts.dart';
import 'package:dino/dino_game.dart';
import 'package:flame/components.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<DinoGame> {
  final String color;
  BackgroundTile({
    this.color = "Gray",
    position,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    priority = -9999;
    size = Vector2.all(Consts.bgTileSize + 0.5); // offset to fix spacings
    sprite = Sprite(game.images.fromCache("Background/$color.png"));
    return super.onLoad();
  }

  final double scrollSpeed = 2;

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    int scrollHeight = (game.size.y / Consts.bgTileSize).floor();
    if (position.y > scrollHeight * Consts.bgTileSize) {
      position.y = -Consts.bgTileSize;
    }
    super.update(dt);
  }
}
