import 'dart:async';
import 'dart:math' as math;

import 'package:dino/components/collision_block.dart';
import 'package:dino/components/level.dart';
import 'package:dino/dino_game.dart';
import 'package:dino/consts.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<DinoGame>, KeyboardHandler {
  // late final RectangleHitbox hitbox;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  final double animationStepTime = 0.05;
  String characterName;
  static const double speeds = 1;
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
  Map<Rect, CollisionBlock> collisionBlocks = {};

  Level? level;

  Player({
    position,
    this.characterName = 'Ninja Frog',
  }) : super(
          position: position,
        ) {
    debugMode = true;
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
    // hitbox = RectangleHitbox(
    //   position: Vector2(10, 4),
    //   size: Vector2(14, 28),
    // );
    // add(hitbox);
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
      game.images
          .fromCache('Main Characters/$characterName/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: animationStepTime,
        textureSize: Vector2.all(32),
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
    Vector2 detectionSize = Vector2.all(Consts.tileSize) * 2;
    Vector2 areaTL = potentialPositon - detectionSize;
    Vector2 areaBR = potentialPositon + size + detectionSize;
    if (scale.x < 0) {
      areaTL.x -= width;
      areaBR.x -= width;
    }
    if (kDebugMode) {
      level?.debugArea.topLeftPosition = areaTL;
      level?.debugArea.size = Vector2(areaBR.x - areaTL.x, areaBR.y - areaTL.y);
    }

    // iterate trough each cell in detection area
    Vector2 cell = Vector2.zero();
    for (cell.y = areaTL.y; cell.y <= areaBR.y; cell.y++) {
      for (cell.x = areaTL.x; cell.x <= areaBR.x; cell.x++) {
        print("check block $cell");
        var block = collisionBlocks[cell];
        if (block != null) {
          print("block $block");
          Vector2 nearestPoint = Vector2.zero();
          nearestPoint.x = math.max(
              cell.x, math.min(potentialPositon.x, cell.x + block.width));
          nearestPoint.y = math.max(
              cell.y, math.min(potentialPositon.y, cell.y + block.height));

          Vector2 rayToNearest = nearestPoint - potentialPositon;
          var overlap = width - rayToNearest.length;
          // print("$nearestPoint, $rayToNearest, $overlap");
          if (overlap > 0) {
            potentialPositon =
                potentialPositon - rayToNearest.normalized() * overlap;
          }
        }
      }
    }

    position = potentialPositon;
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
