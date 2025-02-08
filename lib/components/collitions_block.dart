import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';

class CollisionsBlock extends PositionComponent with CollisionCallbacks {
  bool isFallingPlatform;
  bool isLift;
  bool isVertical;
  bool isPlatform;
  final double offNeg;
  final double offPos;
  CollisionsBlock({
    this.offNeg = 0,
    this.offPos = 0,
    this.isFallingPlatform = false,
    this.isLift = false,
    this.isVertical = false,
    this.isPlatform = false,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  double moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  final double _gravity = 9.8;
  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  bool isPlayerCollision = false;
  bool isPlayerOnLift = false;
  bool isPlayeroffLift = false;

  final hitbox = CustomHitbox(
    offsetX: 0,
    offsetY: -0.5,
    width: 32,
    height: 1,
  );

  CustomHitbox liftHitbox = CustomHitbox(
    offsetX: 0,
    offsetY: -2,
    width: 32,
    height: 5,
  );

  @override
  FutureOr<void> onLoad() {
    if (isLift) {
      debugMode = true;
    }
    if (isFallingPlatform) {
      moveSpeed = 5.0;
      add(
        RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height),
          collisionType: CollisionType.active,
        ),
      );
    }

    if (isLift && isVertical) {
      add(
        RectangleHitbox(
          position: Vector2(liftHitbox.offsetX, liftHitbox.offsetY),
          size: Vector2(liftHitbox.width, liftHitbox.height),
          collisionType: CollisionType.active,
        ),
      );
    }

    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) async {
    if (isVertical && isLift) {
      if (isPlayerOnLift) {
        _liftUp(dt);
      } else {
        _liftDown(dt);
      }
    } else if (!isVertical && isLift) {
      _horizontalMovement(dt);
    }

    if (isFallingPlatform) {
      _verticalMovement(dt);
    }
    if (isPlayerCollision && isFallingPlatform) {
      await Future.delayed(const Duration(milliseconds: 500));
      applygravity(dt);
    }
    super.update(dt);
  }

  void _verticalMovement(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _horizontalMovement(double dt) {
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

  void applygravity(double dt) {
    velocity.y += _gravity;
    position.y += velocity.y * dt;
  }
}
