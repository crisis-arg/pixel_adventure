import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fire extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  Fire({position, size})
      : super(
          position: position,
          size: size,
        );

  final stepTime = 0.05;

  final hitbox = CustomHitbox(
    offsetX: 0,
    offsetY: 16,
    width: 16,
    height: 16,
  );

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
      add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.active,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/Off.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );

    return super.onLoad();
  }
}
