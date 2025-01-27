import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size})
      : super(
          position: position,
          size: size,
        );

  final stepTime = 0.05;
  bool reachedCheckpoint = false;
  final hitbox = CustomHitbox(
    offsetX: 18,
    offsetY: 18,
    width: 12,
    height: 46,
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

    animation = animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !reachedCheckpoint) {
      _reachedCheckpoint();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: stepTime,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );
    Future.delayed(const Duration(milliseconds: 1300), () {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: stepTime,
          textureSize: Vector2.all(64),
        ),
      );
    });
    // final animationTicker = SpriteAnimationTicker(animation!);
  }
}
