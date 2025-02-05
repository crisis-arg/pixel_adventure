import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpPad extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  JumpPad({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  final double stepTime = 0.05;

  CustomHitbox hitbox = CustomHitbox(
    offsetX: 2,
    offsetY: 20,
    width: 28,
    height: 5,
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
        game.images.fromCache('Traps/Trampoline/Idle.png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: Vector2.all(28),
        ));
    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Player){
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Trampoline/Jump (28x28).png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: stepTime,
          textureSize: Vector2.all(28),
          loop: false,
        ));
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
