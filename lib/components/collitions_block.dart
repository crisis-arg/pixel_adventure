import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';

class CollisionsBlock extends PositionComponent with CollisionCallbacks {
  bool isFallingPlatform;
  bool isLift;
  bool isVertical;
  bool isPlatform;
  bool rockHead;
  bool isCircular;
  bool forRange;
  final double offNeg;
  final double offPos;
  CollisionsBlock({
    this.offNeg = 0,
    this.offPos = 0,
    this.isFallingPlatform = false,
    this.isLift = false,
    this.isVertical = false,
    this.isPlatform = false,
    this.rockHead = false,
    this.isCircular = false,
    this.forRange = false,
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
  double circularX = 0;
  double circularY = 0;
  int movementPhase1 = 0;
  int movementPhase2 = 0;
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

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    // if (isLift) {
    //   debugMode = true;
    // }
    if (isCircular) {
      circularX = position.x;
      circularY = position.y;
      moveSpeed = 70;
    }
    if (rockHead) {
      // debugMode = true;
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
    if (isVertical && !isCircular) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else if (!isVertical && !isCircular) {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    } else if (isCircular) {
      rangeNeg = position.y - offNeg * tileSize;
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
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (rockHead && isVertical && !isCircular) {
        _rockHeadVerticalMovement(fixedDeltaTime);
      } else if (rockHead && !isVertical && !isCircular) {
        _rockHeadHorizontalMovement(fixedDeltaTime);
      } else if (rockHead && isCircular) {
        if (!forRange) {
          _rockHeadCircularMovement1(fixedDeltaTime);
        } else {
          _rockHeadCircularMovement2(fixedDeltaTime);
        }
      }
      accumulatedTime -= fixedDeltaTime;
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

  void _rockHeadHorizontalMovement(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
      moveSpeed = 70;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
      moveSpeed = 70;
    }
    moveSpeed = moveSpeed * 1.01;
    position.x += moveDirection * moveSpeed * dt;
  }

  void _rockHeadVerticalMovement(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
      moveSpeed = 70;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
      moveSpeed = 70;
    }
    moveSpeed = moveSpeed * 1.01;
    position.y += moveDirection * moveSpeed * dt;
  }

  void _rockHeadCircularMovement1(double dt) {
    switch (movementPhase1) {
      case 0:
        moveSpeed = moveSpeed * 1.01;
        position.y -= moveSpeed * dt;
        if (position.y <= rangeNeg) {
          moveSpeed = 70;
          position.y = rangeNeg;
          movementPhase1 = 1;
        }
        break;
      case 1:
        moveSpeed = moveSpeed * 1.01;
        position.x += moveSpeed * dt;
        if (position.x >= rangePos) {
          moveSpeed = 70;
          position.x = rangePos;
          movementPhase1 = 2;
        }
        break;
      case 2:
        moveSpeed = moveSpeed * 1.01;
        position.y += moveSpeed * dt;
        if (position.y >= circularY) {
          moveSpeed = 70;
          position.y = circularY;
          movementPhase1 = 3;
        }
        break;
      case 3:
        moveSpeed = moveSpeed * 1.01;
        position.x -= moveSpeed * dt;
        if (position.x <= circularX) {
          moveSpeed = 70;
          position.x = circularX;
          movementPhase1 = 0;
        }
        break;
    }
  }

  void _rockHeadCircularMovement2(double dt) {
   switch (movementPhase2) {
      case 0:
        moveSpeed = moveSpeed * 1.01;
        position.y += moveSpeed * dt;
        if (position.y >= 160) {
          moveSpeed = 70;
          position.y = 160;
          movementPhase2 = 1;
        }
        break;

      case 1:
        moveSpeed = moveSpeed * 1.01;
        position.x -= moveSpeed * dt;
        if (position.x <= 224) {
          moveSpeed = 70;
          position.x = 224;
          movementPhase2 = 2;
        }
        break;

      case 2:
        moveSpeed = moveSpeed * 1.01;
        position.y -= moveSpeed * dt;
        if (position.y <= circularY) {
          moveSpeed = 70;
          position.y = circularY;
          movementPhase2 = 3;
        }
        break;

      case 3:
        moveSpeed = moveSpeed * 1.01;
        position.x += moveSpeed * dt;
        if (position.x >= circularX) {
          moveSpeed = 70;
          position.x = circularX;
          movementPhase2 = 0;
        }
        break;
    }
  }

  void _liftUp(double dt) {
    moveDirection = -1;
    if (position.y <= rangeNeg) {
      moveDirection = 0;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _liftDown(double dt) {
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
