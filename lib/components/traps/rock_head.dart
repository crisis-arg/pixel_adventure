import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/traps/spikes.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum RockHeadState {
  idle,
  blink,
  bottomHit,
  topHit,
  leftHit,
  rightHit,
}

class RockHead extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  double offNeg;
  double offPos;
  bool isVertical;
  bool isCircular;
  bool forRange;
  RockHead({
    this.offNeg = 0,
    this.offPos = 0,
    this.isVertical = false,
    this.isCircular = false,
    this.forRange = false,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  double stepTime = 0.05;
  double rangeNeg = 0;
  double rangePos = 0;
  double tileSize = 16;
  double moveDirection = 1;
  double moveSpeed = 70;
  double circularX = 0;
  double circularY = 0;
  int movementPhase1 = 0;
  int movementPhase2 = 0;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation blinkAnimation;
  late final SpriteAnimation leftHitAnimation;
  late final SpriteAnimation rightHitanimation;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  CustomHitbox hitbox = CustomHitbox(
    offsetX: 2,
    offsetY: 2,
    width: 37,
    height: 37,
  );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Spikes) {
      current = RockHeadState.rightHit;
      await animationTicker?.completed;
      current = RockHeadState.idle;
      await Future.delayed(const Duration(milliseconds: 100));
      current = RockHeadState.blink;
      animationTicker?.reset();
      await animationTicker?.completed;
      current = RockHeadState.idle;
      await Future.delayed(const Duration(milliseconds: 500));
      current = RockHeadState.blink;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (isVertical && !isCircular) {
        _moveVertical(fixedDeltaTime);
      } else if (!isVertical && !isCircular) {
        _moveHorizontal(fixedDeltaTime);
      } else if (isCircular) {
        if (!forRange) {
          // print(check);
          _circularMovement1(fixedDeltaTime);
        } else {
          _circularMovement2(fixedDeltaTime);
        }
      }
      // _rockHeadState();
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  FutureOr<void> onLoad() {
    if (isCircular) {
      circularX = position.x;
      circularY = position.y;
      debugMode = true;
    }
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.active,
      ),
    );
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

    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 1);
    blinkAnimation = _spriteAnimation('Blink (42x42)', 4)..loop = false;
    rightHitanimation = _spriteAnimation('Right Hit (42x42)', 4)..loop = false;
    leftHitAnimation = _spriteAnimation('Left Hit (42x42)', 4)..loop = false;
    animations = {
      RockHeadState.idle: idleAnimation,
      RockHeadState.rightHit: rightHitanimation,
      RockHeadState.leftHit: leftHitAnimation,
      RockHeadState.blink: blinkAnimation,
    };
    current = RockHeadState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Rock Head/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(42),
      ),
    );
  }

  void _moveHorizontal(double dt) {
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

  void _moveVertical(double dt) {
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

  void _circularMovement1(double dt) {
    switch (movementPhase1) {
      case 0:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = -1;
        position.y += moveDirection * moveSpeed * dt;
        if (position.y <= rangeNeg) {
          moveSpeed = 70;
          position.y = rangeNeg;
          movementPhase1 = 1;
        }
        break;
      case 1:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = 1;
        position.x += moveDirection * moveSpeed * dt;
        if (position.x >= rangePos) {
          moveSpeed = 70;
          position.x = rangePos;
          movementPhase1 = 2;
        }
        break;
      case 2:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = 1;
        position.y += moveDirection * moveSpeed * dt;
        if (position.y >= circularY) {
          moveSpeed = 70;
          position.y = circularY;
          movementPhase1 = 3;
        }
        break;
      case 3:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = -1;
        position.x += moveDirection * moveSpeed * dt;
        if (position.x <= circularX) {
          moveSpeed = 70;
          position.x = circularX;
          movementPhase1 = 0;
        }
        break;
    }
  }

  void _circularMovement2(double dt) {
    switch (movementPhase2) {
      case 0:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = 1;
        position.y += moveDirection * moveSpeed * dt;
        if (position.y >= 155) {
          moveSpeed = 70;
          position.y = 155;
          movementPhase2 = 1;
        }
        break;

      case 1:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = -1;
        position.x += moveDirection * moveSpeed * dt;
        if (position.x <= 219) {
          moveSpeed = 70;
          position.x = 219;
          movementPhase2 = 2;
        }
        break;

      case 2:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = -1;
        position.y += moveDirection * moveSpeed * dt;
        if (position.y <= circularY) {
          moveSpeed = 70;
          position.y = circularY;
          movementPhase2 = 3;
        }
        break;

      case 3:
        moveSpeed = moveSpeed * 1.01;
        moveDirection = 1;
        position.x += moveDirection * moveSpeed * dt;
        if (position.x >= circularX) {
          moveSpeed = 70;
          position.x = circularX;
          movementPhase2 = 0;
        }
        break;
    }
  }
}
