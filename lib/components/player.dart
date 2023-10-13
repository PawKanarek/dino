import 'dart:async';
import 'dart:ffi';
import 'dart:math' as math;

import 'package:dino/components/Checkpoint.dart';
import 'package:dino/components/Fruit.dart';
import 'package:dino/components/collision_block.dart';
import 'package:dino/components/level.dart';
import 'package:dino/components/saw.dart';
import 'package:dino/dino_game.dart';
import 'package:dino/consts.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationGroupComponent
    with
        HasGameReference<DinoGame>,
        KeyboardHandler,
        CollisionCallbacks,
        HasVisibility {
  late RectangleHitbox hitbox;
  final double animationStepTime = 0.05;
  String characterName;
  static const double speeds = 2;
  double moveSpeed = 100 * speeds;
  final double _graviy = 9.8 * speeds;
  final double _jumpForce = 300 * speeds;
  final double _terminalVelocity = 900 * speeds;

  bool isLeftKeyPressed = false;
  bool isRightKeyPressed = false;
  bool isDownKeyPressed = false;
  bool isUpOrSpacePressed = false;
  bool startJump = false;
  bool isJumping = false;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;
  bool isCollidingWithPlatform = false;
  bool reachedCheckpoint = false;
  Map<Rect, CollisionBlock> collisionBlocks = {};

  Level? level;

  late Vector2 startingPosition;

  Player({
    super.position,
    this.characterName = 'Ninja Frog',
  }) {
    // debugMode = true;
  }

  // other way https://docs.flame-engine.org/latest/flame/inputs/keyboard_input.html
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    isLeftKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyA)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    isRightKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyD)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    isUpOrSpacePressed = keysPressed.contains((LogicalKeyboardKey.keyW)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    isDownKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyS)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    return false;
  }

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    hitbox = RectangleHitbox(
      position: Vector2(10, 4),
      size: Vector2(14, 28),
    );
    add(hitbox);
    return super.onLoad();
  }

  bool gotHit = false;

  DateTime time = DateTime.now();
  @override
  void update(double dt) {
    if (!gotHit && !reachedCheckpoint) {
      time = DateTime.now();
      _updatePlayerMovement(dt);
      _updatePlayerState();
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    // sets the List
    animations = {
      PlayerState.idle: _spriteAnimation("Idle", 11),
      PlayerState.running: _spriteAnimation('Run', 12),
      PlayerState.falling: _spriteAnimation("Fall", 1),
      PlayerState.jumping: _spriteAnimation("Jump", 1),
      PlayerState.hit: _spriteAnimation("Hit", 7, loop: false),
      PlayerState.appearing: _specialSpriteAnimation(
        "Appearing",
        7,
        loop: false,
      ),
      PlayerState.disappearing:
          _specialSpriteAnimation("Disappearing", 7, loop: false),
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    int amount, {
    bool loop = true,
    int size = 32,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Main Characters/$characterName/$state (${size}x$size).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: animationStepTime,
        textureSize: Vector2(size.toDouble(), size.toDouble()),
        loop: loop,
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: animationStepTime,
        textureSize: Vector2.all(96),
        loop: loop,
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = isLeftKeyPressed ? -1 : (isRightKeyPressed ? 1 : 0);
    velocity.y = isUpOrSpacePressed ? -1 : (isDownKeyPressed ? 1 : 0);

    if (velocity.length2 > 0) {
      velocity = velocity.normalized() * moveSpeed;
    }

    // Extrac region of world cells that could have collision this frame
    Vector2 potentialPositon = position + (velocity * dt);
    // Vector2 detectionSize = Vector2.all(Consts.tileSize) * 2;
    // Vector2 areaTL = potentialPositon - detectionSize;
    // Vector2 areaBR = potentialPositon + size + detectionSize;
    // if (scale.x < 0) {
    //   areaTL.x -= width;
    //   areaBR.x -= width;
    // }
    // if (kDebugMode) {
    //   level?.debugArea.topLeftPosition = areaTL;
    //   level?.debugArea.size = Vector2(areaBR.x - areaTL.x, areaBR.y - areaTL.y);
    // }

    // // iterate trough each cell in detection area
    // Vector2 cell = Vector2.zero();
    // for (cell.y = areaTL.y; cell.y <= areaBR.y; cell.y++) {
    //   for (cell.x = areaTL.x; cell.x <= areaBR.x; cell.x++) {
    //     var block = collisionBlocks[cell];
    //     if (block != null) {
    //       Vector2 nearestPoint = Vector2.zero();
    //       nearestPoint.x = math.max(
    //           cell.x, math.min(potentialPositon.x, cell.x + block.width));
    //       nearestPoint.y = math.max(
    //           cell.y, math.min(potentialPositon.y, cell.y + block.height));

    //       Vector2 rayToNearest = nearestPoint - potentialPositon;
    //       var overlap = width - rayToNearest.length;
    //       // print("$nearestPoint, $rayToNearest, $overlap");
    //       if (overlap > 0) {
    //         potentialPositon =
    //             potentialPositon - rayToNearest.normalized() * overlap;
    //       }
    //     }
    //   }
    // }

    position = potentialPositon;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) other.onCollidedWithPlayer();
    if (other is Saw) _respawn();
    if (other is Checkpoint) _reachedCheckpoint();

    super.onCollisionStart(intersectionPoints, other);
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

  void _respawn() {
    gotHit = true;
    current = PlayerState.hit;
    final hitAnimation = animationTickers![PlayerState.hit]!;
    hitAnimation.completed.whenComplete(() {
      current = PlayerState.appearing;
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      hitAnimation.reset();
      final appearingAnimation = animationTickers![PlayerState.appearing]!;
      appearingAnimation.completed.whenComplete(() {
        position = startingPosition;
        current = PlayerState.idle;
        gotHit = false;
        appearingAnimation.reset();
      });
    });
  }

  void _reachedCheckpoint() {
    if (reachedCheckpoint) {
      return;
    }
    reachedCheckpoint = true;
    current = PlayerState.disappearing;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    final disapearingAnimation = animationTickers![PlayerState.disappearing]!;
    disapearingAnimation.completed.whenComplete(() {
      current = PlayerState.idle;
      game.loadNextLevel();
      reachedCheckpoint = false;
    });
  }
}

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing,
}

enum Side { left, top, right, bottom }
