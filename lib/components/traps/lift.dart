import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Lift extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final bool isVertical;
  final double offNeg;
  final double offPos;

  Lift({
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  double stepTime = 0.05;

  static const moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;
  bool isPlayerOn = false;
  bool isPlayerOff = false;
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 0,
    offsetY: -2,
    width: 32,
    height: 5,
  );

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    if (isVertical) {
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
        game.images.fromCache('Traps/Platforms/Brown On (32x8).png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: stepTime,
          textureSize: Vector2(32, 8),
        ),
      );
    } else {
      add(
        RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height),
          collisionType: CollisionType.active,
        ),
      );
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Platforms/Grey On (32x8).png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: stepTime,
          textureSize: Vector2(32, 8),
        ),
      );
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      if (isPlayerOn) {
        _liftUp(dt);
      }else{
        _liftDown(dt);
      }
    } else if (!isVertical) {
      _moveHorizontal(dt);
    }

    super.update(dt);
  }

  _moveHorizontal(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  _liftUp(double dt) {
    moveDirection = -1;
     if (position.y <= rangeNeg) {
      moveDirection = 0;
    }
    position.y += moveDirection* moveSpeed * dt;
  }

  _liftDown(double dt) {
    moveDirection = 1;
     if (position.y >= rangePos) {
      moveDirection = 0;
    }
    position.y += moveDirection * moveSpeed * dt;
  } 
}
