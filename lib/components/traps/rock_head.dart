import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/collitions_block.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
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
  RockHead({
    this.offNeg = 0,
    this.offPos = 0,
    this.isVertical = false,
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
  double moveSpeed = 100;
  bool rockHeadHit = false;
  bool isPlayerhit = false;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation blinkAnimation;
  late final SpriteAnimation leftHitAnimation;
  late final SpriteAnimation rightHitanimation;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  CustomHitbox hitbox = CustomHitbox(
    offsetX: 2,
    offsetY: 5,
    width: 37,
    height: 32,
  );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is CollisionsBlock) {
      current = RockHeadState.rightHit;
      rockHeadHit = true;
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
  void onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Player && rockHeadHit && !isPlayerhit) {
      isPlayerhit = true;
      other.respawn();
      await Future.delayed(const Duration(seconds: 1));
      isPlayerhit = false;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    rockHeadHit = false;
    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!isVertical) {
        _moveHorizontal(fixedDeltaTime);
      }
      // _rockHeadState();
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
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
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
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

  // void _rockHeadState() async {
  //   RockHeadState rockHeadState = RockHeadState.idle;
  //   if (position.x >= rangePos) {
  //     rockHeadState = RockHeadState.rightHit;
  //   } else if (position.x <= rangeNeg) {
  //     rockHeadState = RockHeadState.leftHit;
  //   }
  //   current = rockHeadState;
  // }

  _moveHorizontal(double dt) async {
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
}
