import 'dart:async';
import 'dart:io';

import 'package:dino/actors/player.dart';
import 'package:dino/levels/level.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

class Dino extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late JoystickComponent joystick;
  late final CameraComponent cam;
  Player player = Player(character: "Mask Dude");
  bool showJoystick = Platform.isAndroid || Platform.isIOS;

  @override
  FutureOr<void> onLoad() async {
    // loads all images into cache (this might be slow)
    await images.loadAllImages();

    final world = Level(player: player, levelName: "level_01");
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
  void update(double dt) {
    if (showJoystick) {
      _updateJoystick();
    }

    super.update(dt);
  }

  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;
      default:
        player.playerDirection = PlayerDirection.none;
        break;
    }
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
}
