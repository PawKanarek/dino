import 'dart:async';

import 'package:dino/components/level.dart';
import 'package:dino/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DinoGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late JoystickComponent joystick;
  late final CameraComponent cam;
  Player player = Player(characterName: "Mask Dude");
  bool showJoystick = false; // Platform.isAndroid || Platform.isIOS;
  double fps = 0;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    // loads all images into cache (this might be slow)
    await images.loadAllImages();

    final world = Level(
      player: player,
      levelName: "level_02",
    );
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
      hudComponents: showJoystick ? [_joystick()] : null,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    if (kDebugMode) {
      _renderFps(canvas);
    }

    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      _updateJoystick();
    }

    if (kDebugMode) {
      _calculateFps(dt);
    }

    super.update(dt);
  }

  void _calculateFps(double t) {
    fps = 1 / t;
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

  void _renderFps(Canvas canvas) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20.0,
    );

    final fpsText = TextSpan(
      text: 'FPS: ${fps.toStringAsFixed(2)}',
      style: textStyle,
    );

    final fpsPainter = TextPainter(
      text: fpsText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    fpsPainter.layout();
    fpsPainter.paint(canvas, const Offset(10, 10));
  }

  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
        player.isLeftKeyPressed = true;
        break;
      case JoystickDirection.upLeft:
        player.isLeftKeyPressed = true;
        player.isUpOrSpacePressed = true;
        break;
      case JoystickDirection.downLeft:
        player.isLeftKeyPressed = true;
        break;
      case JoystickDirection.right:
        player.isRightKeyPressed = true;
        break;
      case JoystickDirection.upRight:
        player.isRightKeyPressed = true;
        player.isUpOrSpacePressed = true;
        break;
      case JoystickDirection.downRight:
        player.isRightKeyPressed = true;
        break;
      default:
        player.isLeftKeyPressed = false;
        player.isRightKeyPressed = false;
        player.isUpOrSpacePressed = false;
        break;
    }
  }
}
