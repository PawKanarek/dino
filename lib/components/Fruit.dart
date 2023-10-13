import 'dart:async';

import 'package:dino/dino_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameReference<DinoGame>, CollisionCallbacks {
  final String fruit;
  bool _collidedWithPlayer = false;
  final double stepTime = 0.05;

  Fruit({
    this.fruit = 'Apple',
    super.position,
    super.size,
    super.removeOnFinish = true,
  }) {
    // debugMode = true;
  }

  void onCollidedWithPlayer() {
    if (_collidedWithPlayer) {
      return;
    }
    _collidedWithPlayer = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/Collected.png"),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );

    // animationTicker!.completed.whenComplete(() => removeFromParent());
  }

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
          position: Vector2(10, 10),
          size: Vector2(12, 12),
          collisionType: CollisionType.passive),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/$fruit.png"),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }
}
