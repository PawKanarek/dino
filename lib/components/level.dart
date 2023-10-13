import 'dart:async';

import 'package:dino/components/Checkpoint.dart';
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

class Level extends World with HasGameReference<DinoGame> {
  RectangleComponent debugRect = RectangleComponent();
  late Player player;
  late TiledComponent level;
  final String levelName;
  Map<Rect, CollisionBlock> collisionBlocks = {};

  Level({required this.levelName});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      "$levelName.tmx",
      Vector2.all(Consts.tileSize),
    );

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

    if (backgroundLayer != null) {
      final bgColor = backgroundLayer.properties.getValue("BackgroundColor");

      final backgroundTile = BackgroundTile(
        color: bgColor ?? "Gray",
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }

  void _addCollisions() {
    final collistionsLayer = level.tileMap.getLayer<ObjectGroup>('collisions');

    if (collistionsLayer != null) {
      for (final block in collistionsLayer.objects) {
        switch (block.class_) {
          case 'platform':
            final platform = CollisionBlock(
              position: Vector2(block.x, block.y),
              size: Vector2(block.width, block.height),
              isPlatform: true,
            );
            collisionBlocks[platform.toRect()] = platform;
            add(platform);
            break;
          case 'checkpoint':
            final checkpoint = Checkpoint(
                position: Vector2(block.x, block.y),
                size: Vector2(block.width, block.height));
            add(checkpoint);
            break;
          default:
            final collision = CollisionBlock(
              position: Vector2(block.x, block.y),
              size: Vector2(block.width, block.height),
            );
            collisionBlocks[collision.toRect()] = collision;
            add(collision);
            break;
        }
      }
      player.collisionBlocks = collisionBlocks;
    }
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("spawnPoints");

    if (spawnPointsLayer != null) {
      for (final block in spawnPointsLayer.objects) {
        switch (block.class_) {
          case 'player':
            player = Player(characterName: "Mask Dude");
            player.position = Vector2(block.x, block.y);
            player.level = this;
            player.x = 1;
            add(player);
            break;
          case 'Fruits':
            final fruit = Fruit(
                fruit: block.name,
                position: Vector2(block.x, block.y),
                size: Vector2(block.width, block.height));
            add(fruit);
            break;
          case 'Saw':
            final isVertical = block.properties.getValue("isVertical");
            final offsetNegative = block.properties.getValue("offsetNegative");
            final offsetPositive = block.properties.getValue("offsetPositive");
            final saw = Saw(
              isVertical: isVertical,
              offsetNegative: offsetNegative,
              offsetPositive: offsetPositive,
              position: Vector2(block.x, block.y),
              size: Vector2(block.width, block.height),
            );
            add(saw);
            break;
          default:
        }
      }
    }
  }
}
