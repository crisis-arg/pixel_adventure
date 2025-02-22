import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/Buttons/restart_button.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
// import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collitions_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/traps/Lift.dart';
import 'package:pixel_adventure/components/traps/chain.dart';
import 'package:pixel_adventure/components/traps/falling_platforms.dart';
import 'package:pixel_adventure/components/traps/fire.dart';
import 'package:pixel_adventure/components/traps/jump_pad.dart';
import 'package:pixel_adventure/components/traps/rock_head.dart';
import 'package:pixel_adventure/components/traps/saw.dart';
import 'package:pixel_adventure/components/traps/spikes.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Levels extends World with HasGameRef<PixelAdventure>, HasDecorator {
  final String levelName;
  final Player player;
  final String backgroundColor;
  late TiledComponent level;
  List<CollisionsBlock> collisionBlocks = [];

  Levels({
    required this.levelName,
    required this.player,
    required this.backgroundColor,
  });

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    // decorator?.addLast(Shadow3DDecorator(base: Vector2(100, 150)));
    _spawningObjects();
    _adCollisions();
    _scrollingBackground();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final background = ParallaxComponent(
      priority: -1,
      parallax: Parallax(
        size: Vector2(640, 320),
        [
          ParallaxLayer(
            ParallaxImage(
              game.images.fromCache('Background/$backgroundColor.png'),
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
          case 'Chain':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final chain = Chain(
              isVertical: isVertical,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(chain);
            break;
          case 'Lift':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final lift = Lift(
                isVertical: isVertical,
                offNeg: offNeg,
                offPos: offPos,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: spawnPoint.size);
            add(lift);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(checkpoint);
            break;
          case 'fallingPlatformSpawn':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final fallingPlatforms = FallingPlatforms(
              player: player,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(fallingPlatforms);
            break;
          case 'Fire':
            final fire = Fire(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fire);
            break;
          case 'jumpPad':
            final jumpPad = JumpPad(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: spawnPoint.size,
            );
            add(jumpPad);
            break;
          case 'Rock Head':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final isCircular = spawnPoint.properties.getValue('isCircular');
            final forRange = spawnPoint.properties.getValue('forRange');
            final rockHead = RockHead(
              offNeg: offNeg,
              offPos: offPos,
              isVertical: isVertical,
              isCircular: isCircular,
              forRange: forRange,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(rockHead);
            break;
          case 'spikes':
            final spikePosition =
                spawnPoint.properties.getValue('spikePosition');
            final spikes = Spikes(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
              spikePosition: spikePosition,
            );
            add(spikes);
            break;
          case 'Restart':
            final restart = RestartButton(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: spawnPoint.size,
            );
            add(restart);
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
          case 'fallingPlatforms':
            final offNeg = collision.properties.getValue('offNeg');
            final offPos = collision.properties.getValue('offPos');
            final isVertical = collision.properties.getValue('isVertical');
            final fallingplatform = CollisionsBlock(
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isVertical: isVertical,
              isFallingPlatform: true,
              isPlatform: true,
            );
            collisionBlocks.add(fallingplatform);
            add(fallingplatform);
            break;
          case 'Lift':
            final offNeg = collision.properties.getValue('offNeg');
            final offPos = collision.properties.getValue('offPos');
            final isVertical = collision.properties.getValue('isVertical');
            final lift = CollisionsBlock(
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isVertical: isVertical,
              isLift: true,
              isPlatform: true,
            );
            collisionBlocks.add(lift);
            add(lift);
            break;
          case 'rockHead':
            final offNeg = collision.properties.getValue('offNeg');
            final offPos = collision.properties.getValue('offPos');
            final isVertical = collision.properties.getValue('isVertical');
            final isCircular = collision.properties.getValue('isCircular');
            final forRange = collision.properties.getValue('forRange');
            final rockHead = CollisionsBlock(
              offNeg: offNeg,
              offPos: offPos,
              isVertical: isVertical,
              isCircular: isCircular,
              forRange:  forRange,
              position: Vector2(collision.x, collision.y),
              size: collision.size,
              rockHead: true,
            );
            collisionBlocks.add(rockHead);
            add(rockHead);
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
