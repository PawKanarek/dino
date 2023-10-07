import 'dart:async';

import 'package:dino/components/collision_block.dart';
import 'package:dino/components/player.dart';
import 'package:dino/consts.dart';
import 'package:dino/dino_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart';

// class Level extends Forge2DWorld with HasGameReference<DinoGame> {
//   Level({required this.levelName});

//   @override
//   FutureOr<void> onLoad() async {
//     return super.onLoad();
//   }

//   List<Component> createBoundaries() {
//     final visibleRect = game.camera.visibleWorldRect;
//     final topLeft = visibleRect.topLeft.toVector2();
//     final topRight = visibleRect.topRight.toVector2();
//     final bottomRight = visibleRect.bottomRight.toVector2();
//     final bottomLeft = visibleRect.bottomLeft.toVector2();

//     return [
//       Wall(topLeft, topRight),
//       Wall(topRight, bottomRight),
//       Wall(bottomLeft, bottomRight),
//       Wall(topLeft, bottomLeft),
//     ];
//   }
// }
