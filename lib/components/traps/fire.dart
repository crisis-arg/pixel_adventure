import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fire extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  Fire({position, size})
      : super(
          position: position,
          size: size,
        );

  final stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/Off.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );

    return super.onLoad();
  }
}
