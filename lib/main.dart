import 'package:dino/components/level.dart';
import 'package:dino/consts.dart';
import 'package:dino/dino_game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final game = _createGame();
  runApp(
    GameWidget(
      game: kDebugMode ? _createGame() : game,
    ),
  );
}

DinoGame _createGame() {
  final world = Level(levelName: Consts.levelNames.first);
  return DinoGame(
    world: world,
    camera: CameraComponent(
      world: world,
    ),
  );
}
