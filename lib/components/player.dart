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
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  final double stepTime = 0.05;
  String character;
  static const double speeds = 2;
  double moveSpeed = 100 * speeds;
  final double _graviy = 9.8 * speeds;
  final double _jumpForce = 300 * speeds;
  final double _terminalVelocity = 900 * speeds;

  double horizontalMovement = 0;
  bool startJump = false;
  bool isJumping = false;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;
  bool isCollidingWithPlatform = false;
  List<CollisionBlock> collisionBlocks = [];
  Set<Side> collidedPlayerSides = {};
  Map<int, Set<Side>> collidedObjects = {};
  PlayerHitbox hitbox_2 =
      PlayerHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(
          position: position,
        ) {
    debugMode = true;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    print("delay: ${DateTime.now().difference(time)}");
    if (other is CollisionBlock) {
      var newSides = _collisionSides(other);
      var currentSides = collidedObjects[other.hashCode];
      if (currentSides != null && !currentSides.containsAll(newSides)) {
        // colision sides beetwen object and player has changed
        collidedPlayerSides.remove(currentSides);
      }
      collidedPlayerSides.addAll(newSides);
      collidedObjects[other.hashCode] = newSides;
      if (isCollidingWithPlatform && collidedPlayerSides.contains(Side.top)) {
        collidedPlayerSides.remove(Side.top);
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    var sides = collidedObjects[other.hashCode];
    if (sides != null) {
      collidedPlayerSides.removeAll(sides);
    }
    collidedObjects.remove(other.hashCode);

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

    final isUpOrSpace = keysPressed.contains((LogicalKeyboardKey.keyW)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    startJump = isUpOrSpace;

    return false;
  }

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    hitbox = RectangleHitbox(
      position: Vector2(hitbox_2.offsetX, hitbox_2.offsetY),
      size: Vector2(hitbox_2.width, hitbox_2.height),
    );
    add(hitbox);
    return super.onLoad();
  }

  DateTime time = DateTime.now();
  @override
  void update(double dt) {
    time = DateTime.now();
    _updatePlayerMovement(dt);
    _updatePlayerState();
    super.update(dt);
  }

  Set<Side> _collisionSides(PositionComponent other) {
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
    fallingAnimation = _spriteAnimation("Fall", 1);
    jumpingAnimation = _spriteAnimation("Jump", 1);

    // sets the List
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.jumping: jumpingAnimation,
    };

    current = PlayerState.idle;
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
    final double horizontalV = horizontalMovement * moveSpeed;
    double verticalV = 0;

    if (startJump && collidedPlayerSides.contains(Side.bottom)) {
      startJump = false;
      verticalV = -_jumpForce;
      isJumping = true;
    } else {
      verticalV = velocity.y + _graviy;
    }
    if (isJumping && verticalV >= 0) {
      isJumping = false;
    }

    if (isJumping) {
      velocity.y = verticalV;
      position.y += velocity.y * dt;
      print("jumping");
    } else if (verticalV > 0 && !collidedPlayerSides.contains(Side.bottom)) {
      // apply gravity
      velocity.y = verticalV.clamp(0, _terminalVelocity);
      position.y += velocity.y * dt;
      print("falling");
    } else {
      print("stay on ground");
      velocity.y = 0;
    }

    if (horizontalV > 0 && !collidedPlayerSides.contains(Side.right) ||
        horizontalV < 0 && !collidedPlayerSides.contains(Side.left)) {
      velocity.x = horizontalV;
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

    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    } else if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    current = playerState;
  }
}

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
}

enum Side { left, top, right, bottom }

class PlayerHitbox {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  PlayerHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}
