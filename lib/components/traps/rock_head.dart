import 'dart:async';

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
  RockHead({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;

  @override
  void update(double dt) {
    _rockHeadState();
    super.update(dt);
  }

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 1);
    animations = {
      RockHeadState.idle: idleAnimation,
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
    current = rockHeadState;
  }
}
