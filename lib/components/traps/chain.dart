import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Chain extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  bool isVertical;
  Chain({
    this.isVertical = false,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    if (isVertical) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Platforms/ChainV3.png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.05,
          textureSize: Vector2(8, 16),
        ),
      );
    }else{
       animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Platforms/ChainH.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.05,
        textureSize: Vector2(16, 8 ),
      ),
    );
    }
    return super.onLoad();
  }
}
