import 'dart:async';

import 'package:dino/actors/player.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  Level({required this.levelName, required this.player});

  final Player player;
  late TiledComponent level;
  final String levelName;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    await add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("spawnPoints");

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          await add(player);
          break;
        default:
      }
    }

    return await super.onLoad();
  }
}
