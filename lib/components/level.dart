import 'dart:async';

import 'package:dino/components/Fruit.dart';
import 'package:dino/components/background_tile.dart';
import 'package:dino/components/collision_block.dart';
import 'package:dino/components/player.dart';
import 'package:dino/components/saw.dart';
import 'package:dino/consts.dart';
import 'package:dino/dino_game.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

class Level extends World with HasGameRef<DinoGame> {
  RectangleComponent debugRect = RectangleComponent();
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
    // debugArea.debugMode = true;
    debugRect.paint = debugPaint;
    add(debugRect);

    _spawnObjects();
    _addCollisions();
    _scorllingBackground();

    return super.onLoad();
  }

  void _scorllingBackground() {
    final backgroundLayer = level.tileMap.getLayer('background');

    final numTilesY = (game.size.y / Consts.bgTileSize).floor();
    final numTilesX = (game.size.x / Consts.bgTileSize).floor();

    if (backgroundLayer != null) {
      final bgColor = backgroundLayer.properties.getValue("BackgroundColor");

      for (double x = 0; x < numTilesX; x++) {
        for (double y = 0; y < numTilesY + 2; y++) {
          final backgroundTile = BackgroundTile(
            color: bgColor ?? "Gray",
            position: Vector2(x * Consts.bgTileSize,
                y * Consts.bgTileSize - Consts.bgTileSize),
          );
          add(backgroundTile);
        }
      }
    }
  }

  void _addCollisions() {
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
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("spawnPoints");

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.level = this;
            add(player);
            break;
          case 'Fruits':
            final fruit = Fruit(
                fruit: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue("isVertical");
            final offsetNegative =
                spawnPoint.properties.getValue("offsetNegative");
            final offsetPositive =
                spawnPoint.properties.getValue("offsetPositive");
            final saw = Saw(
              isVertical: isVertical,
              offsetNegative: offsetNegative,
              offsetPositive: offsetPositive,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          default:
        }
      }
    }
  }
}
