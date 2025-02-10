import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class RockHead extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure> {
  RockHead({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Rock Head/Blink (42x42).png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: stepTime,
        textureSize: Vector2.all(42),
      ),
    );
    return super.onLoad();
  }
}
