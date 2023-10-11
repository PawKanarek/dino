import 'dart:async';

import 'package:dino/components/collision_block.dart';
import 'package:dino/dino_game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Player extends BodyComponent<DinoGame> {
  late final SpriteAnimationGroupComponent animations;
  // late final RectangleHitbox hitbox;
  final double animationStepTime = 0.05;
  String characterName;
  final Vector2 initalPosition;
  static const double speeds = 1;
  double moveSpeed = 100 * speeds;
  bool startJump = false;
  bool isJumping = false;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;
  bool isCollidingWithPlatform = false;
  Map<Rect, CollisionBlock> collisionBlocks = {};

  Player({
    this.characterName = 'Ninja Frog',
    required this.initalPosition,
  }) {
    // renderBody = false;
  }
  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(32, 32, Vector2.zero(), 0);
    final fixtureDef = FixtureDef(shape, friction: 0.3, density: 10);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: initalPosition,
      type: BodyType.dynamic,
    );
    return game.world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _loadAllAnimations();
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
    animations = SpriteAnimationGroupComponent(animations: {
      PlayerState.idle: _spriteAnimation("Idle", 11),
      PlayerState.running: _spriteAnimation('Run', 12),
      PlayerState.falling: _spriteAnimation("Fall", 1),
      PlayerState.jumping: _spriteAnimation("Jump", 1),
    });
    animations.current = PlayerState.idle;
    add(animations);
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
    velocity.x = game.isLeftKeyPressed ? -1 : (game.isRightKeyPressed ? 1 : 0);
    velocity.y = game.isUpOrSpacePressed ? -1 : (game.isDownKeyPressed ? 1 : 0);

    if (velocity.length2 > 0) {
      velocity = velocity.normalized() * moveSpeed;
    }

    // Vector2 potentialPositon = position + (velocity * dt);
    // position = potentialPositon;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && animations.scale.x > 0) {
      animations.flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && animations.scale.x < 0) {
      animations.flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    } else if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    animations.current = playerState;
  }
}

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
}

enum Side {
  left,
  top,
  right,
  bottom,
}
