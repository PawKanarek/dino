import 'dart:async';
import 'dart:io';

import 'package:dino/components/level.dart';
import 'package:dino/consts.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DinoGame extends FlameGame<Level>
    with
        SingleGameInstance,
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection {
  late JoystickComponent _joystick;
  late CameraComponent cam;
  bool isMobile = Platform.isAndroid || Platform.isIOS;
  int currentLevel = 0;

  DinoGame({
    super.world,
    super.camera,
  });

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  void loadNextLevel() {
    if (currentLevel < Consts.levelNames.length - 1) {
      currentLevel++;
    } else {
      // game finished
    }
  }

  @override
  FutureOr<void> onLoad() async {
    // loads all images into cache (this might be slow)
    await images.loadAllImages();
    _addJoystick();
    _addFps();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateJoystick();
    super.update(dt);
  }

  void _addJoystick() {
    if (!isMobile) {
      return;
    }

    _joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache("HUD/Knob.png")),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache("HUD/Joystick.png")),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    camera.add(_joystick);
  }

  void _updateJoystick() {
    if (!isMobile) {
      return;
    }

    switch (_joystick.direction) {
      case JoystickDirection.left:
        world.player.isLeftKeyPressed = true;
        break;
      case JoystickDirection.upLeft:
        world.player.isLeftKeyPressed = true;
        world.player.isUpOrSpacePressed = true;
        break;
      case JoystickDirection.downLeft:
        world.player.isLeftKeyPressed = true;
        break;
      case JoystickDirection.right:
        world.player.isRightKeyPressed = true;
        break;
      case JoystickDirection.upRight:
        world.player.isRightKeyPressed = true;
        world.player.isUpOrSpacePressed = true;
        break;
      case JoystickDirection.downRight:
        world.player.isRightKeyPressed = true;
        break;
      default:
        world.player.isLeftKeyPressed = false;
        world.player.isRightKeyPressed = false;
        world.player.isUpOrSpacePressed = false;
        break;
    }
  }

  void _addFps() {
    if (!kDebugMode) {
      return;
    }
    camera.add(FpsTextComponent());
  }
}
