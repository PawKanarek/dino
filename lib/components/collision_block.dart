import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  bool isPlatform;
  late final RectangleHitbox hitbox;

  CollisionBlock({
    position,
    size,
    this.isPlatform = false,
  }) : super(
          position: position,
          size: size,
        ) {
    debugMode = true;
  }

  @override
  FutureOr<void> onLoad() {
    hitbox = RectangleHitbox(
      isSolid: true,
      collisionType: CollisionType.passive,
    );
    add(hitbox);
    return super.onLoad();
  }
}
