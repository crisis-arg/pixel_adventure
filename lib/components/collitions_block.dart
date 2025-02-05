import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';

class CollisionsBlock extends PositionComponent with CollisionCallbacks {
  bool isFallingPlatform;
  bool isPlatform;
  final double offNeg;
  final double offPos;
  CollisionsBlock({
    this.offNeg = 0,
    this.offPos = 0,
    this.isFallingPlatform = false,
    this.isPlatform = false,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        ) {
    // debugMode = true;
  }
  static const moveSpeed = 5;
  static const tileSize = 16;
  double moveDirection = 1;
  final double _gravity = 9.8;
  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  bool isPlayerCollision = false;

  final hitbox = CustomHitbox(
    offsetX: 0,
    offsetY: -0.5,
    width: 32,
    height: 1,
  );

  @override
  FutureOr<void> onLoad() {
    if (isFallingPlatform) {
      debugMode = true;
      add(
        RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height),
          collisionType: CollisionType.active,
        ),
      );
    }

    rangeNeg = position.y - offNeg * tileSize;
    rangePos = position.y + offPos * tileSize;

    return super.onLoad();
  }

  @override
  void update(double dt) async {
    if (isFallingPlatform) {
      _movement(dt);
    }
    if (isPlayerCollision && isFallingPlatform) {
      await Future.delayed(const Duration(milliseconds: 500));
      applygravity(dt);
    }
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

  void applygravity(double dt) {
    velocity.y += _gravity;
    position.y += velocity.y * dt;
  }
}
