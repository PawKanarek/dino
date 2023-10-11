import 'dart:async';

import 'package:dino/components/collision_block.dart';
import 'package:dino/components/player.dart';
import 'package:dino/consts.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

class Level extends Forge2DWorld {
  RectangleComponent debugArea = RectangleComponent();
  late TiledComponent level;
  final String levelName;

  Level({required this.levelName});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
        "$levelName.tmx", Vector2.all(Consts.tileSize));

    debugArea.debugMode = true;
    debugArea.paint = debugPaint;
    add(debugArea);

    final tilesLayer = level.tileMap.getLayer<TileLayer>("background");
    if (tilesLayer != null) {
      for (final tile in tilesLayer.objects) {
        switch (tile.class_) {
          case 'player':
            var player = Player(
              characterName: "Mask Dude",
              initalPosition: Vector2(spawnPoint.x, spawnPoint.y),
            );
            player.level = this;
            add(player);
            break;
          default:
        }
      }
    }

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("spawnPoints");

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'player':
            var player = Player(
              characterName: "Mask Dude",
              initalPosition: Vector2(spawnPoint.x, spawnPoint.y),
            );
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
}
