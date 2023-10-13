import 'dart:async';
import 'package:dino/consts.dart';
import 'package:dino/dino_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Saw extends SpriteAnimationComponent
    with HasGameRef<DinoGame>, CollisionCallbacks {
  final bool isVertical;
  final double offsetNegative;
  final double offsetPositive;
  Saw({
    this.isVertical = false,
    this.offsetNegative = 0,
    this.offsetPositive = 0,
    super.position,
    super.size,
  }) {
    // debugMode = true;
    if (isVertical) {
      rangeNeg = position.y - offsetNegative * Consts.tileSize;
      rangePos = position.y + offsetPositive * Consts.tileSize;
    } else {
      rangeNeg = position.x - offsetNegative * Consts.tileSize;
      rangePos = position.x + offsetPositive * Consts.tileSize;
    }
  }

  static const moveSpeed = 80;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    add(
      CircleHitbox(
          position: Vector2(0, 0),
          radius: 16,
          collisionType: CollisionType.passive),
    );

    priority = -1;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Saw/On (38x38).png"),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.03,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertical(dt);
    } else {
      _moveHorizontal(dt);
    }

    super.update(dt);
  }

  void _moveHorizontal(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  void _moveVertical(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }
}
