import 'dart:async';

import 'package:dino/components/level.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';

class DinoGame extends Forge2DGame
    with KeyboardEvents, DragCallbacks, HasCollisionDetection {
  late JoystickComponent joystick;

  bool showJoystick = false; // Platform.isAndroid || Platform.isIOS;
  double fps = 0;
  bool isLeftKeyPressed = false;
  bool isRightKeyPressed = false;
  bool isDownKeyPressed = false;
  bool isUpOrSpacePressed = false;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    // loads all images into cache (this might be slow)
    await images.loadAllImages();
    camera.viewport.add(FpsTextComponent());
    camera.viewport.add(_joystick());
    camera.viewfinder.zoom = 10;
    add(Level(levelName: "level_01"));
    return super.onLoad();
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
