import 'dart:async';

import 'package:dino/components/collision_block.dart';
import 'package:dino/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  final Player player;
  late TiledComponent level;
  final String levelName;
  List<CollisionBlock> collisionBlocks = [];

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("spawnPoints");

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
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
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
      player.collisionBlocks = collisionBlocks;
    }

    return super.onLoad();
  }
}
