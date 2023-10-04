import 'dart:async';

import 'package:dino/components/collision_block.dart';
import 'package:dino/dino_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<DinoGame>, KeyboardHandler, CollisionCallbacks {
  late final RectangleHitbox hitbox;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;
  String character;
  double moveSpeed = 100;
  double horizontalMovement = 0;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;
  bool isCollidingWithPlatform = false;
  List<CollisionBlock> collisionBlocks = [];
  Set<Side> collisionSides = {};
  Map<int, Set<Side>> currentCollisions = {};

  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(
          position: position,
        ) {
    debugMode = true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {
      var sides = _collisionCheck(other);
      collisionSides.addAll(sides);
      currentCollisions[other.hashCode] = sides;
      if (isCollidingWithPlatform && collisionSides.contains(Side.top)) {
        collisionSides.remove(Side.top);
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    var sides = currentCollisions[other.hashCode];
    if (sides != null) {
      collisionSides.removeAll(sides);
    }
    currentCollisions.remove(other.hashCode);

    super.onCollisionEnd(other);
  }

  // other way https://docs.flame-engine.org/latest/flame/inputs/keyboard_input.html
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyA)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyD)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return false;
  }

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    hitbox = RectangleHitbox();
    add(hitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    _updatePlayerState();
    super.update(dt);
  }

  Set<Side> _collisionCheck(PositionComponent other) {
    final playerRect = toRect();
    final blockRect = other.toRect();
    Set<Side> sides = {};
    if (playerRect.overlaps(blockRect)) {
      final playerCenter = playerRect.center;
      final blockCenter = blockRect.center;

      final deltaX = playerCenter.dx - blockCenter.dx;
      final deltaY = playerCenter.dy - blockCenter.dy;

      final playerHalfWidth = playerRect.width / 2;
      final playerHalfHeight = playerRect.height / 2;
      final blockHalfWidth = blockRect.width / 2;
      final blockHalfHeight = blockRect.height / 2;

      final overlapX = playerHalfWidth + blockHalfWidth - deltaX.abs();
      final overlapY = playerHalfHeight + blockHalfHeight - deltaY.abs();
      if (overlapX > overlapY) {
        if (deltaY > 0) {
          sides.add(Side.top);
        } else {
          sides.add(Side.bottom);
        }
      }
      if (overlapX < overlapY) {
        if (deltaX > 0) {
          sides.add(Side.left);
        } else {
          sides.add(Side.right);
        }
      }
    }
    return sides;
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11);
    runningAnimation = _spriteAnimation('Run', 12);

    // sets the List
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };

    current = PlayerState.running;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    final double hV = horizontalMovement * moveSpeed;
    final double vV = velocity.y + _graviy;

    if (vV > 0 && !collisionSides.contains(Side.bottom) ||
        (vV < 0 && !collisionSides.contains(Side.top))) {
      velocity.y = vV.clamp(-_jumpForce, _terminalVelocity);
      position.y += velocity.y * dt;
    }

    if (hV > 0 && !collisionSides.contains(Side.right) ||
        hV < 0 && !collisionSides.contains(Side.left)) {
      velocity.x = hV;
      position.x += velocity.x * dt;
    } else {
      velocity.x = 0;
    }
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    current = playerState;
  }

  final double _graviy = 9.8;
  final double _jumpForce = 460;
  final double _terminalVelocity = 300;
}

enum PlayerState { idle, running }

enum Side { left, right, top, bottom }
