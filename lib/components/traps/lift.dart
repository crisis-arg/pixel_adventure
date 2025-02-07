import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Lift extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  Lift({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Platforms/Brown Off.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2(32, 8),
      ),
    );
    return super.onLoad();
  }
}
