import 'package:dino/dino.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  Dino game = Dino();
  runApp(
    GameWidget(game: kDebugMode ? Dino() : game),
  );
}
