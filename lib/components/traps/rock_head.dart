import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum RockHeadState {
  idle,
  bottomHit,
  topHit,
  leftHit,
  rightHit,
}

class RockHead extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  double offNeg;
  double offPos;
  RockHead({
    this.offNeg = 0,
    this.offPos = 0,
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
  double moveSpeed = 20;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation leftHitAnimation;
  late final SpriteAnimation rightHitanimation;

  @override
  void update(double dt) {
    _moveHorizontal(dt);
    _rockHeadState();
    super.update(dt);
  }

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 1);
    rightHitanimation = _spriteAnimation('Right Hit (42x42)', 4)..loop = false;
    leftHitAnimation = _spriteAnimation('Left Hit (42x42)', 4)..loop = false;
    animations = {
      RockHeadState.idle: idleAnimation,
      RockHeadState.rightHit: rightHitanimation,
      RockHeadState.leftHit: leftHitAnimation,
    };
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

  void _rockHeadState() {
    RockHeadState rockHeadState = RockHeadState.idle;
    if (position.x >= rangePos) {
      rockHeadState = RockHeadState.rightHit;
    } else if (position.x <= rangeNeg) {
      rockHeadState = RockHeadState.leftHit;
    }
    current = rockHeadState;
  }

  _moveHorizontal(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
      moveSpeed = 15;
    } else if (position.x <= rangeNeg) {
      moveSpeed = 15;
      moveDirection = 1;
    }
    moveSpeed = moveSpeed * 1.02;
    if (moveSpeed < 20) {
      moveSpeed += 5;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}
