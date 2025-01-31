import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/collitions_block.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class FallingPlatforms extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  final Player player;

  FallingPlatforms({
    this.offNeg = 0,
    this.offPos = 0,
    required this.player,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );
  final stepTime = 0.05;
  static const moveSpeed = 5;
  static const tileSize = 16;
  Vector2 velocity = Vector2.zero();
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;
  final double _gravity = 9.8;
  late final CollisionsBlock platformsss;
  bool isPlayer = false;
  bool start = false;

  final hitbox = CustomHitbox(
    offsetX: 0,
    offsetY: 0,
    width: 32,
    height: 5,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.active,
      ),
    );

    rangeNeg = position.y - offNeg * tileSize;
    rangePos = position.y + offPos * tileSize;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/On (32x10).png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: stepTime,
        textureSize: Vector2(32, 10),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) async {
    _movement(dt);
    if (isPlayer) {
      await Future.delayed(const Duration(milliseconds: 500));
      applygravity(dt);
    }
    super.update(dt);
  }


  void applygravity(double dt) {
    velocity.y += _gravity;
    position.y += velocity.y * dt;
  }

  void _movement(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }
}
