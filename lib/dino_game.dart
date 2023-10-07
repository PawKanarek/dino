import 'dart:async';

import 'package:dino/components/collision_block.dart';
import 'package:dino/components/level.dart';
import 'package:dino/components/player.dart';
import 'package:dino/consts.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DinoGame extends Forge2DGame
    with KeyboardEvents, DragCallbacks, HasCollisionDetection {
  late JoystickComponent joystick;

  bool showJoystick = false; // Platform.isAndroid || Platform.isIOS;
  bool isLeftKeyPressed = false;
  bool isRightKeyPressed = false;
  bool isDownKeyPressed = false;
  bool isUpOrSpacePressed = false;

  RectangleComponent debugArea = RectangleComponent();
  late TiledComponent level;
  final String levelName = "level_01";

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      images.fromCache('Main Characters/Ninja Frog/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.05,
        textureSize: Vector2.all(32),
      ),
    );
  }

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    // loads all images into cache (this might be slow)
    await images.loadAllImages();
    camera.viewport.add(FpsTextComponent());
    camera.viewport.add(_joystick());
    camera.viewfinder.zoom = 1;

    level = await TiledComponent.load(
        "$levelName.tmx", Vector2.all(Consts.tileSize));

    world.add(Ball(Vector2.zero()));
    world.addAll(createBoundaries());

    debugArea.debugMode = true;
    debugArea.paint = debugPaint;
    add(debugArea);
    var animations = SpriteAnimationGroupComponent(animations: {
      PlayerState.idle: _spriteAnimation("Idle", 11),
      PlayerState.running: _spriteAnimation('Run', 12),
      PlayerState.falling: _spriteAnimation("Fall", 1),
      PlayerState.jumping: _spriteAnimation("Jump", 1),
    });

    final tilesLayer = level.tileMap.getLayer<TileLayer>("background");
    if (tilesLayer?.tileData != null) {
      for (final tile in tilesLayer!.tileData!) {
        for (final innerTile in tile) {
          // ignore: avoid_print
          print(innerTile);
          // switch (tile) {
          //   default:
          //     var player = Player(
          //       characterName: "Mask Dude",
          //       initalPosition: Vector2(innerTile.tile. ., spawnPoint.y),
          //     );
          //     player.level = this;
          //     add(player);
          //     break;
          // }
        }
      }
    }

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("spawnPoints");

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'player':
            add(Player(
              characterName: "Mask Dude",
              initalPosition: Vector2(120, 1),
              animations: animations,
            ));
            break;
          default:
        }
      }
    }

    final collistionsLayer = level.tileMap.getLayer<ObjectGroup>('collisions');

    if (collistionsLayer != null) {
      for (final collision in collistionsLayer.objects) {
        switch (collision.class_) {
          case 'platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            add(block);
            break;
        }
      }
    }

    return super.onLoad();
  }

  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      _updateJoystick();
    }

    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // other way https://docs.flame-engine.org/latest/flame/inputs/keyboard_input.html
    isLeftKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyA)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    isRightKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyD)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    isUpOrSpacePressed = keysPressed.contains((LogicalKeyboardKey.keyW)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    isDownKeyPressed = keysPressed.contains((LogicalKeyboardKey.keyS)) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    return KeyEventResult.handled;
  }

  JoystickComponent _joystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache("HUD/Knob.png")),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache("HUD/Joystick.png")),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    return joystick;
  }

  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
        isLeftKeyPressed = true;
        break;
      case JoystickDirection.upLeft:
        isLeftKeyPressed = true;
        isUpOrSpacePressed = true;
        break;
      case JoystickDirection.downLeft:
        isLeftKeyPressed = true;
        break;
      case JoystickDirection.right:
        isRightKeyPressed = true;
        break;
      case JoystickDirection.upRight:
        isRightKeyPressed = true;
        isUpOrSpacePressed = true;
        break;
      case JoystickDirection.downRight:
        isRightKeyPressed = true;
        break;
      default:
        isLeftKeyPressed = false;
        isRightKeyPressed = false;
        isUpOrSpacePressed = false;
        break;
    }
  }
}

class Ball extends BodyComponent with TapCallbacks {
  Vector2? initialPosition;
  Ball(this.initialPosition);

  @override
  Body createBody() {
    var fixture = FixtureDef(
      CircleShape()..radius = 5,
      restitution: 0.8,
      density: 1.0,
      friction: 0.4,
    );

    var bodyDef = BodyDef(
      angularDamping: 0.8,
      position: initialPosition ?? Vector2.zero(),
      type: BodyType.dynamic,
    );

    return game.world.createBody(bodyDef)..createFixture(fixture);
  }

  @override
  void onTapDown(event) {
    body.applyLinearImpulse(Vector2.random() * 5000);
  }
}

class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return game.world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
