import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class FallingPlatforms extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure> {
  final double offNeg;
  final double offPos;

  FallingPlatforms({
    this.offNeg = 0,
    this.offPos = 0,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );
  final stepTime = 0.05;
  static const moveSpeed = 5;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  final hitbox = CustomHitbox(
    offsetX:0,
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
  void update(double dt) {
    _movement(dt);
    super.update(dt);
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
