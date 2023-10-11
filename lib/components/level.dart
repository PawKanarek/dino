import 'dart:async';

import 'package:dino/components/collision_block.dart';
import 'package:dino/components/player.dart';
import 'package:dino/consts.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

class Level extends World {
  RectangleComponent debugArea = RectangleComponent();
  final Player player;
  late TiledComponent level;
  final String levelName;
  Map<Rect, CollisionBlock> collisionBlocks = {};

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
        "$levelName.tmx", Vector2.all(Consts.tileSize));

    add(level);
    debugArea.debugMode = true;
    debugArea.paint = debugPaint;
    add(debugArea);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("spawnPoints");

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.level = this;
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
            collisionBlocks[platform.toRect()] = platform;
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks[block.toRect()] = block;
            add(block);
            break;
        }
      }
      player.collisionBlocks = collisionBlocks;
    }

    return super.onLoad();
  }
}
