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

  late RectangleHitbox fireOn = RectangleHitbox(
    position: Vector2(fireHitbox.offsetX, fireHitbox.offsetY),
    size: Vector2(fireHitbox.width, fireHitbox.height),
    collisionType: CollisionType.active,
  );

  final hitbox = CustomHitbox(
    offsetX: 0,
    offsetY: 16,
    width: 16,
    height: 16,
  );

  final fireHitbox = CustomHitbox(
    offsetX: 3,
    offsetY: 0,
    width: 10,
    height: 14,
  );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Player) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Fire/Hit (16x32).png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: stepTime,
          textureSize: Vector2(16, 32),
          loop: false,
        ),
      );
      await animationTicker?.completed;
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
      add(fireOn);
      animationTicker?.reset();
      await animationTicker?.completed;
      isFireon = false;
      remove(fireOn);
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
    if (other is Player && isFireon) {
      other.respawn();
    }
    super.onCollision(intersectionPoints, other);
  }

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
        textureSize: Vector2(16, 32),
      ),
    );

    return super.onLoad();
  }

  // Future<void> collidingWithPlayer() async {
  //   animationTicker?.reset();
  //   await animationTicker?.completed;
  // }
}
