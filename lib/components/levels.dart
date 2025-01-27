import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/rendering.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
// import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collitions_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Levels extends World with HasGameRef<PixelAdventure>, HasDecorator {
  final String levelName;
  final Player player;
  late TiledComponent level;
  List<CollisionsBlock> collisionBlocks = [];

  Levels({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    // decorator?.addLast(Shadow3DDecorator(base: Vector2(100, 150)));
    _spawningObjects();
    _adCollisions();
    _scrollingBackground('Green');

    return super.onLoad();
  }

  void _scrollingBackground(String backgroundName) {
    // final backGroundLayer = level.tileMap.getLayer('Background');
    // const tileSize = 64;

    // final numTilesY = (game.size.y / tileSize).floor();
    // final numTileX = (game.size.x / tileSize).floor();

    // if (backGroundLayer != null) {
    //   final backgroundColor =
    //       backGroundLayer.properties.getValue('BackgroundColor');
    //   for (double y = 0; y <= numTilesY; y++) {
    //     for (double x = 0; x <= numTileX; x++) {
    //       final backgroundTile = BackgroundTile(
    //         color: backgroundColor != null ? backgroundColor : 'Gray',
    //         position: Vector2(x * tileSize - tileSize, y * tileSize -tileSize ),
    //       );
    //       add(backgroundTile);
    //     }
    //   }
    // }

    final background = ParallaxComponent(
      priority: -1,
      parallax: Parallax(
        size: Vector2(640, 320),
        [
          ParallaxLayer(
            ParallaxImage(
              game.images.fromCache('Background/$backgroundName.png'),
              repeat: ImageRepeat.repeat,
              fill: LayerFill.none,
            ),
          ),
        ],
        baseVelocity: Vector2(0, -50),
      ),
    );
    add(background);
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(checkpoint);
            break;
          default:
        }
      }
    }
  }

  void _adCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionsBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionsBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionsBlocks = collisionBlocks;
  }
}
