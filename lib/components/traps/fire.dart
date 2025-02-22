import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fire extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Fire({position, size})
      : super(
          position: position,
          size: size,
        );

  final stepTime = 0.05;
  bool isFireon = false;
  bool playerHit = false;

  final hitbox = CustomHitbox(
    offsetX: 3,
    offsetY: 16,
    width: 10,
    height: 16,
  );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Player && !playerHit) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Fire/Hit (16x32).png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: stepTime,
          textureSize: Vector2(16, 32),
          loop: false,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Fire/On (16x32).png'),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: Vector2(16, 32),
          loop: false,
        ),
      );
      isFireon = true;
      await animationTicker?.completed;
      isFireon = false;
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Fire/Off.png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: Vector2(16, 32),
        ),
      );
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && isFireon && !playerHit) {
      other.respawn();
      playerHit = true;
      Future.delayed(const Duration(seconds: 1), () {
        playerHit = false;
      });
    }
    super.onCollision(intersectionPoints, other);
  }

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

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/Off.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2(16, 32),
      ),
    );

    return super.onLoad();
  }

}
