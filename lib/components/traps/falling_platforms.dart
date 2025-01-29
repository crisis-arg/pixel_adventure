import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class FallingPlatforms extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure> {
  FallingPlatforms({position, size})
      : super(
          position: position,
          size: size,
        );

  final stepTime = 0.05;
  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/On (32x10).png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: stepTime,
        textureSize: Vector2(32, 10),
      ),
    );
    return super.onLoad();
  }
}
